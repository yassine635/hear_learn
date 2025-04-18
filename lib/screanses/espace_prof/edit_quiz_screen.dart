import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditQuizScreen extends StatefulWidget {
  final DocumentSnapshot quizDoc;

  const EditQuizScreen({super.key, required this.quizDoc});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  late TextEditingController questionController;
  late TextEditingController optionAController;
  late TextEditingController optionBController;
  late TextEditingController optionCController;
  late TextEditingController optionDController;
  String? correctAnswer;

  @override
  void initState() {
    super.initState();
    final data = widget.quizDoc.data() as Map<String, dynamic>;
    final options = data['options'] as Map<String, dynamic>;

    questionController = TextEditingController(text: data['question']);
    optionAController = TextEditingController(text: options['a']);
    optionBController = TextEditingController(text: options['b']);
    optionCController = TextEditingController(text: options['c']);
    optionDController = TextEditingController(text: options['d']);
    correctAnswer = data['correctAnswer'];
  }

  Future<void> saveEdits() async {
    final updatedQuestion = questionController.text.trim();
    final optionA = optionAController.text.trim();
    final optionB = optionBController.text.trim();
    final optionC = optionCController.text.trim();
    final optionD = optionDController.text.trim();

    if (updatedQuestion.isEmpty ||
        optionA.isEmpty ||
        optionB.isEmpty ||
        optionC.isEmpty ||
        optionD.isEmpty ||
        correctAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizDoc.id)
          .update({
        'question': updatedQuestion,
        'options': {
          'a': optionA,
          'b': optionB,
          'c': optionC,
          'd': optionD,
        },
        'correctAnswer': correctAnswer,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Quiz mis à jour avec succès.")),
      );
      Navigator.pop(context); // Go back after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier le Quiz")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(labelText: "Question"),
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
              decoration: InputDecoration(labelText: "Bonne réponse"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveEdits,
              child: Text("Enregistrer les modifications"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
