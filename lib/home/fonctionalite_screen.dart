import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hear_learn1/screanses/espace_prof/create_quiz.dart';
import 'package:hear_learn1/screanses/espace_prof/teacher_quiz_dashboard.dart';
import 'package:hear_learn1/screanses/espace_student/take_quiz.dart';


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

  bool isStudent() => userType == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[700],
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
                  ? "Welcome Student"
                  : userType == 2
                      ? "Welcome Professor"
                      : "Loading...",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Shared
            _buildButton("Espace d'éducation", Icons.book, navigateToModule),

            // Teacher-only
            if (!isStudent())
              _buildButton("Créer un quiz", Icons.computer, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateQuizScreen()),
                );
              }),

            if (!isStudent())
              _buildButton("Gérer mes quiz", Icons.list_alt, () {
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
              _buildButton("Commencer le Quiz", Icons.quiz, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakeQuizScreen()),
                );
              }),

            if (isStudent())
              _buildButton("Reconnaissance couleur", Icons.color_lens, () {
                // Add functionality
              }),

            if (isStudent())
              _buildButton("Reconnaissance de billets", Icons.money, () {
                // Add functionality
              }),

            if (isStudent())
              _buildButton("Bouton d'urgence", Icons.phone, () {
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
        color: Colors.lightGreen,
        borderRadius: BorderRadius.circular(40),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.black,
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black, size: 40),
          title: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
