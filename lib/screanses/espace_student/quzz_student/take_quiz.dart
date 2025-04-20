import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/quiz_results.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/quizz_passthrow.dart';

class TakeQuizScreen extends StatefulWidget {
  final String quizId;

  TakeQuizScreen({required this.quizId});

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  late Future<DocumentSnapshot> quizData;
  String? selectedAnswer; // Track the selected answer
  bool quizSubmitted = false; // Track if the quiz has been submitted

  @override
  void initState() {
    super.initState();
    quizData = _fetchQuizData();
  }

  Future<DocumentSnapshot> _fetchQuizData() async {
    try {
      DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();
      if (quizSnapshot.exists) {
          Map<String, dynamic> quizData = quizSnapshot.data() as Map<String, dynamic>;
          if (quizData['did_the_quiz'] == true) {
            // Quiz has already been done, redirect
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPassThrough(), // Replace with the screen you want to show
                ),
              );
            });
          }
           return quizSnapshot;
      }
      else {
        throw Exception('Quiz document does not exist');
      }
    } catch (e) {
      if (e is Exception) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => QuizPassThrough()),
              );
            });}
      print('Error fetching quiz data: $e');
      rethrow;
    }
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _submitQuiz(String correctAnswer) async {
    if (selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an answer.')),
      );
      return;
    }

    bool isCorrect = selectedAnswer == correctAnswer;
    
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      await FirebaseFirestore.instance.collection('quiz_responses').add({
        'quizId': widget.quizId,
        'studentId': userId,
        'isCorrect': isCorrect,
        'timestamp': FieldValue.serverTimestamp(),
      });
       // Update the quiz document to set 'did_the_quiz' to true
      await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .update({
          'did_the_quiz': true,
        });

    } catch (e) {
      print('Error saving quiz response: $e');
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultsScreen(
            isCorrect: isCorrect,
            quizId: widget.quizId,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take Quiz'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: quizData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Quiz not found.'));
          }

          Map<String, dynamic> quiz =
              snapshot.data!.data() as Map<String, dynamic>;

          String question = quiz['question'] as String? ?? '';
          Map<String, dynamic> options =
              quiz['options'] as Map<String, dynamic>? ?? {};
          String correctAnswer = quiz['correctAnswer'] as String? ?? '';

          return Padding(
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
                    onChanged: quizSubmitted
                        ? null
                        : (value) {
                            _checkAnswer(value!);
                          },
                  );
                }).toList(),
                SizedBox(height: 20),
                if (!quizSubmitted)
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _submitQuiz(correctAnswer),
                      child: Text('Submit Quiz'),
                    ),
                  ),
                if (quizSubmitted)
                   Center(
                    child: Text('Quiz completed!'),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
