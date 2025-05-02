import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/quizz_contaner.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/take_quiz.dart';

class QuizPassThrough extends StatelessWidget {
  const QuizPassThrough({super.key});

  Future<Map<String, dynamic>> _getStudentInfo() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    final studentSnapshot = await FirebaseFirestore.instance
        .collection('etudiants')
        .doc(userId)
        .get();

    if (!studentSnapshot.exists) throw Exception("Student not found");

    final data = studentSnapshot.data()!;
    return {
      'level': data['niveau'],
      'specialty': data['specialite'],
    };
  }

  Future<List<DocumentSnapshot>> _getQuizzesForStudent(
      String level, String specialty) async {
    final quizSnapshot =
        await FirebaseFirestore.instance.collection('quizzes').get();

    return quizSnapshot.docs.where((doc) {
      final quizData = doc.data();
      return quizData['quiz_level'] == level &&
          quizData['quiz_specialite'] == specialty;
    }).toList();
  }

  Future<List<String>> _getCompletedQuizIds(String studentId) async {
    final responses = await FirebaseFirestore.instance
        .collection('quiz_responses')
        .where('studentId', isEqualTo: studentId)
        .get();

    return responses.docs.map((doc) => doc['quizId'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( 
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الاختبارات المتاحة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Cheker.first_color,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _getStudentInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(child: Text('Failed to load student info'));
            }
      
            final level = snapshot.data!['level'];
            final specialty = snapshot.data!['specialty'];
      
            return FutureBuilder<List<DocumentSnapshot>>(
              future: _getQuizzesForStudent(level, specialty),
              builder: (context, quizSnapshot) {
                if (quizSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!quizSnapshot.hasData || quizSnapshot.hasError) {
                  return const Center(child: Text('Failed to load quizzes'));
                }
      
                final allQuizzes = quizSnapshot.data!;
                final userId = FirebaseAuth.instance.currentUser?.uid;
                return FutureBuilder<List<String>>(
                  future: _getCompletedQuizIds(userId!),
                  builder: (context, completedSnapshot) {
                    if (completedSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
      
                    final completedQuizIds = completedSnapshot.data ?? [];
                    final quizzesToShow = allQuizzes.where((quiz) {
                      return !completedQuizIds.contains(quiz.id);
                    }).toList();
      
                    if (quizzesToShow.isEmpty) {
                      return const Center(child: Text(
                        'لا توجد اختبارات متاحة',
                            style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 35,
                            color: Colors.black,
                          ),
                          )
                        );
                    }
      
                    final Map<String, List<String>> quizzesByModule = {};
                    for (var quiz in quizzesToShow) {
                      final module = quiz.get('quiz_module');
                      if (!quizzesByModule.containsKey(module)) {
                        quizzesByModule[module] = [];
                      }
                      quizzesByModule[module]!.add(quiz.id);
                    }
      
                    return ListView(
                      children: quizzesByModule.entries.map((entry) {
                        final module = entry.key;
                        final quizIds = entry.value;
      
                        return ListTile(
                          title: QuizzContaner(text:module,),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TakeQuizScreen(quizIds: quizIds),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
