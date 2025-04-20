import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/take_quiz.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/quiz_results.dart';

class QuizPassThrough extends StatefulWidget {
  @override
  _QuizPassThroughState createState() => _QuizPassThroughState();
}

class _QuizPassThroughState extends State<QuizPassThrough> {
  String? studentLevel;

  @override
  void initState() {
    super.initState();
    _getStudentLevel();
  }

  Future<void> _getStudentLevel() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(userId)
          .get();

      if (studentSnapshot.exists) {
        setState(() {
          studentLevel = studentSnapshot.get('niveau') as String?;
        });
      }
    } catch (e) {
      print('Error fetching student level: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quizzes"),
      ),
      body: studentLevel == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('quizzes').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No quizzes available."));
                }

                List<DocumentSnapshot> quizzes = snapshot.data!.docs;
                List<DocumentSnapshot> filteredQuizzes = [];

                return FutureBuilder(
                  future: Future.wait(quizzes.map((quiz) async {
                    String teacherId = quiz.get('createdBy');
                    String quizModule = quiz.get('quiz_module');

                    DocumentSnapshot teacherSnapshot =
                        await FirebaseFirestore.instance
                            .collection('utilisateurs')
                            .doc(teacherId)
                            .get();

                    if (teacherSnapshot.exists) {
                      List<dynamic> teacherLevels =
                          teacherSnapshot.get('niveaux');
                       List<dynamic> teacherModules = teacherSnapshot.get('modules');

                      if (teacherLevels.contains(studentLevel) && teacherModules.contains(quizModule)) {
                        filteredQuizzes.add(quiz);
                      }
                    }
                  })),
                  builder: (context, _) {
                    if (_.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (filteredQuizzes.isEmpty) {
                      return Center(child: Text('No quizzes available for your level.'));
                    }
                    return ListView.builder(
                      itemCount: filteredQuizzes.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot quiz = filteredQuizzes[index];
                        return ListTile(
                          title: Text(quiz.get('quiz_module')),
                          onTap: () {
                            print("========================> $quiz.id");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TakeQuizScreen(quizId: quiz.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
