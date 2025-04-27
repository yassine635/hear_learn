import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/screanses/espace_student/quzz_student/quiz_results.dart';

class TakeQuizScreen extends StatefulWidget {
  final String quizId;

  const TakeQuizScreen({super.key, required this.quizId});

  @override
  _TakeQuizScreenState createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  late Future<DocumentSnapshot> quizData;
  String? selectedAnswer;
  bool quizSubmitted = false;

  @override
  void initState() {
    super.initState();
    quizData = _fetchQuizData();
  }

 Future<DocumentSnapshot> _fetchQuizData() async {
  try {
    final quizRef = FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId);
    final quizSnapshot = await quizRef.get();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final responseSnapshot = await FirebaseFirestore.instance
        .collection('quiz_responses')
        .where('quizId', isEqualTo: widget.quizId)
        .where('studentId', isEqualTo: userId)
        .get();

    if (responseSnapshot.docs.isNotEmpty) {
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultsScreen(
              isCorrect: responseSnapshot.docs.first.get('isCorrect'),
              quizId: widget.quizId,
            ),
          ),
        );
      });
    }

    return quizSnapshot;
  } catch (e) {
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
                }),
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