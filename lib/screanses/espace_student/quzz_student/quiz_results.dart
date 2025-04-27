import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuizResultsScreen extends StatefulWidget {
  final bool isCorrect;
  final String quizId;

  const QuizResultsScreen({super.key, required this.isCorrect, required this.quizId});
  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  late Future<DocumentSnapshot> quizData;
  @override
  void initState() {
    super.initState();
    quizData = _fetchQuizData();
  }

  Future<DocumentSnapshot> _fetchQuizData() async {
    try {
      return await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();
    } catch (e) {
      print('Error fetching quiz data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Quiz Results'),
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

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: widget.isCorrect ? Colors.green : Colors.red,
                  size: 100,
                ),
                SizedBox(height: 20),
                Text(
                  widget.isCorrect ? 'Correct!' : 'Incorrect!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                 SizedBox(height: 20),
                  Text(
                  "Question : $question",
                  style: TextStyle(fontSize: 20, ),
                ),
                SizedBox(height: 20),
                TextButton(
                  child: Text('Return to Quizzes'),
                  onPressed: () {
                    Navigator.pop(context); 
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}