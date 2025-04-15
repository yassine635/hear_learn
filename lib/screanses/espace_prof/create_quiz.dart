import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateQuizScreen extends StatefulWidget {
  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();

  String? correctAnswer;

  void saveQuiz() async {
    final question = questionController.text.trim();
    final optionA = optionAController.text.trim();
    final optionB = optionBController.text.trim();
    final optionC = optionCController.text.trim();
    final optionD = optionDController.text.trim();
    final teacherId = FirebaseAuth.instance.currentUser?.uid;

    if (question.isEmpty ||
        optionA.isEmpty ||
        optionB.isEmpty ||
        optionC.isEmpty ||
        optionD.isEmpty ||
        correctAnswer == null ||
        teacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('quizzes').add({
        'question': question,
        'options': {
          'a': optionA,
          'b': optionB,
          'c': optionC,
          'd': optionD,
        },
        'correctAnswer': correctAnswer,
        'createdBy': teacherId, // ✅ now dynamic
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Quiz enregistré avec succès!")),
      );

      questionController.clear();
      optionAController.clear();
      optionBController.clear();
      optionCController.clear();
      optionDController.clear();
      setState(() {
        correctAnswer = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'enregistrement: \$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Créer un Quiz"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration:
                  InputDecoration(labelText: "Question avec un espace vide"),
            ),
            SizedBox(height: 16),
            TextField(
              controller: optionAController,
              decoration: InputDecoration(labelText: "Option A"),
            ),
            TextField(
              controller: optionBController,
              decoration: InputDecoration(labelText: "Option B"),
            ),
            TextField(
              controller: optionCController,
              decoration: InputDecoration(labelText: "Option C"),
            ),
            TextField(
              controller: optionDController,
              decoration: InputDecoration(labelText: "Option D"),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: correctAnswer,
              items: ['a', 'b', 'c', 'd'].map((letter) {
                return DropdownMenuItem(
                  value: letter,
                  child: Text("Bonne réponse : ${letter.toUpperCase()}"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  correctAnswer = value;
                });
              },
              decoration:
                  InputDecoration(labelText: "Choisir la bonne réponse"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveQuiz,
              child: Text("Enregistrer le Quiz"),
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
