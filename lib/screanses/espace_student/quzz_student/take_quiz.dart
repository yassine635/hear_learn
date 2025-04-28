import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/quiz_results.dart';

class TakeQuizScreen extends StatefulWidget {
  final List<String> quizIds;

  const TakeQuizScreen({super.key, required this.quizIds});

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  int correctAnswers = 0;
  bool isLoading = true;
  late List<DocumentSnapshot> quizzes;

  @override
  void initState() {
    super.initState();
    _fetchAllQuizzes();
  }

  Future<void> _fetchAllQuizzes() async {
    try {
      quizzes = [];
      for (String id in widget.quizIds) {
        DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(id)
            .get();
        quizzes.add(quizSnapshot);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading quizzes: $e');
    }
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  Future<void> _submitQuiz() async {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an answer.')),
      );
      return;
    }

    final currentQuiz = quizzes[currentQuestionIndex];
    final correctAnswer = currentQuiz.get('correctAnswer');

    bool isCorrect = selectedAnswer == correctAnswer;
    if (isCorrect) {
      correctAnswers++;
    }

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance.collection('quiz_responses').add({
        'quizId': currentQuiz.id,
        'studentId': userId,
        'isCorrect': isCorrect,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving quiz response: $e');
    }

    if (currentQuestionIndex < quizzes.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            correctAnswers: correctAnswers,
            totalQuestions: quizzes.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Take Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final quiz = quizzes[currentQuestionIndex];
    final question = quiz.get('question') ?? '';
    final options = Map<String, dynamic>.from(quiz.get('options') ?? {});

    return Scaffold(
      appBar: AppBar(title: Text('Question ${currentQuestionIndex + 1}/${quizzes.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...options.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  _checkAnswer(value!);
                },
              );
            }).toList(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitQuiz,
                child: Text('Submit Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
