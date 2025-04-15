import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizResultsScreen extends StatelessWidget {
  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = FirebaseAuth.instance.currentUser?.uid;

    if (studentId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Mes Résultats")),
        body: const Center(child: Text("Utilisateur non connecté.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Résultats de Quiz")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quiz_responses')
            .where('studentId', isEqualTo: studentId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final responses = snapshot.data!.docs;

          if (responses.isEmpty) {
            return const Center(child: Text("Aucun résultat trouvé."));
          }

          return ListView.builder(
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final data = responses[index].data() as Map<String, dynamic>;
              final answer = data['selectedAnswer'];
              final isCorrect = data['isCorrect'] as bool;
              final note = data['note'] ?? "—";
              final quizId = data['quizId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('quizzes')
                    .doc(quizId)
                    .get(),
                builder: (context, quizSnapshot) {
                  if (!quizSnapshot.hasData) {
                    return const ListTile(title: Text("Chargement..."));
                  }

                  final quizData =
                      quizSnapshot.data!.data() as Map<String, dynamic>;
                  final question = quizData['question'];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(question),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Votre réponse : (${answer.toUpperCase()})"),
                          Text(
                              "Résultat : ${isCorrect ? '✅ Correct' : '❌ Incorrect'}"),
                          Text("Note du professeur : $note"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
