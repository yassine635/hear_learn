import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (user == null) return 0; // No user logged in

    String uid = user.uid;

    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(uid)
          .get();

      if (studentDoc.exists) return 1; // Student

      DocumentSnapshot profDoc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(uid)
          .get();

      if (profDoc.exists) return 2; // Professor

      return 0; // Not found in any collection
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

  bool whattype() {
    if (userType == 1) {
      return true;
    }else{
      return false;
    }
  }

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
            _buildButton("Espace d'éducation", Icons.book, navigateToModule,showForUser: true),
            _buildButton("Reconnaissance couleur", Icons.color_lens, () {},showForUser: whattype()),
            _buildButton("Reconnaissance de billets", Icons.money, () {},showForUser: whattype()),
            _buildButton("Bouton d'urgence", Icons.phone, () {
              Navigator.pushNamed(context, "/emergency");
            },showForUser: whattype()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    required bool showForUser, // Add the condition to show/hide button
  }) {
    // Only show the button if showForUser is true
    return showForUser
        ? Container(
            height: 80,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(40)
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              child: ListTile(
                leading: Icon(icon, color: Colors.black),
                title: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          )
        : Container(); // Return an empty container if the button should be hidden
  }
}
