import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TakeQuizScreen extends StatefulWidget {
  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  List<DocumentSnapshot> quizzes = [];
  int currentIndex = 0;
  String? selectedOption;
  bool isAnswered = false;
  bool isLoading = true;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      quizzes = snapshot.docs;
      isLoading = false;
    });
  }

  Future<void> submitAnswer(String selected) async {
    final quiz = quizzes[currentIndex];
    final correct = quiz['correctAnswer'];
    final teacherId = quiz['createdBy'];
    final quizId = quiz.id;
    final studentId = FirebaseAuth.instance.currentUser?.uid;

    setState(() {
      selectedOption = selected;
      isAnswered = true;
    });

    final isCorrect = selected == correct;
    if (isCorrect) correctAnswers++;

    try {
      await FirebaseFirestore.instance.collection('quiz_responses').add({
        'quizId': quizId,
        'studentId': studentId,
        'selectedAnswer': selected,
        'isCorrect': isCorrect,
        'teacherId': teacherId,
        'note': null,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCorrect
                ? "✅ Bonne réponse !"
                : "❌ Mauvaise réponse. Rép. correcte : ${correct.toUpperCase()}",
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait then go to next question or result
      await Future.delayed(Duration(seconds: 2));
      if (currentIndex < quizzes.length - 1) {
        nextQuestion();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizFinishedScreen(
              correctAnswers: correctAnswers,
              totalQuestions: quizzes.length,
            ),
          ),
        );
      }
    } catch (e) {
      print("Erreur d'enregistrement : \$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'enregistrement.")),
      );
    }
  }

  void nextQuestion() {
    setState(() {
      currentIndex++;
      selectedOption = null;
      isAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz Étudiant")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz Étudiant")),
        body: Center(child: Text("Aucun quiz disponible pour le moment.")),
      );
    }

    if (currentIndex >= quizzes.length) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz Étudiant")),
        body: Center(child: Text("🎉 Vous avez terminé tous les quiz !")),
      );
    }

    final quiz = quizzes[currentIndex];
    final question = quiz['question'];
    final options = quiz['options'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text("Quiz Étudiant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Question ${currentIndex + 1}/${quizzes.length}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(question, style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            ...options.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;
              final isSelected = selectedOption == key;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: isAnswered ? null : () => submitAnswer(key),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blueAccent : null,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("(${key.toUpperCase()}) $value"),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class QuizFinishedScreen extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;

  const QuizFinishedScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz terminé")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              "🎉 Vous avez terminé le test !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "✅ Bonnes réponses : $correctAnswers / $totalQuestions",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.home),
              label: Text("Retour à l'accueil"),
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, "/fonctionalite_screen");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(200, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
