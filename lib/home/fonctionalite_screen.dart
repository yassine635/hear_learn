import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hear_learn1/screanses/espace_prof/quizz_teacher/create_quiz.dart';
import 'package:hear_learn1/screanses/espace_prof/quizz_teacher/teacher_quiz_dashboard.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/quizz_passthrow.dart';

import 'package:hear_learn1/data/cheker.dart';

class Fonctionalite extends StatefulWidget {
  const Fonctionalite({super.key});

  @override
  State<Fonctionalite> createState() => _FonctionaliteState();
}

class _FonctionaliteState extends State<Fonctionalite> {
  int? userType;

  @override
  void initState() {
    super.initState();
    fetchUserType();
    checkQuizzesDate();
  }

  Future<void> fetchUserType() async {
    int type = await getUserType();
    setState(() {
      userType = type;
    });
  }

  Future<int> getUserType() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    String uid = user.uid;

    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(uid)
          .get();

      if (studentDoc.exists) return 1;

      DocumentSnapshot profDoc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(uid)
          .get();

      if (profDoc.exists) return 2;

      return 0;
    } catch (e) {
      print("ERROR: $e");
      return 0;
    }
  }

  void navigateToModule() async {
    int type = await getUserType();
    if (type == 1) {
      Navigator.pushNamed(context, "/home_student");
    } else if (type == 2) {
      Navigator.pushNamed(context, "/home_techer");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User type not recognized")),
      );
    }
  }

  Future<void> checkQuizzesDate() async {
    try {
      final quizzesSnapshot =
          await FirebaseFirestore.instance.collection('quizzes').get();

      for (var doc in quizzesSnapshot.docs) {
        final quizData = doc.data();
        final addedAt = quizData['timestamp'] as Timestamp?;

        if (addedAt != null &&
            Cheker.isMoreThanThreeDaysAgo(addedAt.toDate())) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print('Error checking/deleting quizzes: $e');
    }
  }

  bool isStudent() => userType == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: const Text(
          "HearLearn",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushNamed(context, "/log_in_screen");
          },
          icon: const Icon(Icons.logout),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userType == 1
                  ? "مرحباً بالطالب"
                  : userType == 2
                      ? "مرحباً أستاذ"
                      : "تحميل...",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Shared
            _buildButton("فضاء التعليمي", Icons.book, navigateToModule),

            // Teacher-only
            if (!isStudent())
              _buildButton("انشاء اسئلة", Icons.computer, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateQuizScreen()),
                );
              }),

            if (!isStudent())
              _buildButton("دارة الاسئلة", Icons.list_alt, () {
                final teacherId = FirebaseAuth.instance.currentUser?.uid;

                if (teacherId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeacherQuizDashboard(teacherId: teacherId),
                    ),
                  );
                }
              }),

            // Student-only
            if (isStudent())
              _buildButton("بدءالاسئلة", Icons.quiz, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizPassThrough()),
                );
              }),

            if (isStudent())
              _buildButton("تعرف على الالوان", Icons.color_lens, () {
                Navigator.pushNamed(context, "/reconnaissence_couleur_sceen");
              }),

            if (isStudent())
              _buildButton("تعرف على نقود", Icons.money, () {
                Navigator.pushNamed(context, "/reconnaissence_billet_sceen");
              }),

            if (isStudent())
              _buildButton("زر الاستعجالات", Icons.phone, () {
                Navigator.pushNamed(context, "/emergency");
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(40),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[400],
          foregroundColor: Colors.black,
        ),
        child: Row(
            // Set RTL direction for row
          mainAxisAlignment: MainAxisAlignment.end, // Align content to the right
          children: [
            
            Icon(icon, color: Colors.black, size: 40), // Icon comes first on the right
            Spacer(),
            const SizedBox(width: 10),  // Space between icon and text
            Text(
              text,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
