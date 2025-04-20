import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_quiz_screen.dart';

class TeacherQuizDashboard extends StatelessWidget {
  final String teacherId;
  const TeacherQuizDashboard({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Quiz"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('createdBy', isEqualTo: teacherId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quizzes = snapshot.data!.docs;

          if (quizzes.isEmpty) {
            return const Center(child: Text("Aucun quiz trouvé."));
          }

          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              final quizId = quiz.id;
              final question = quiz['question'];

              return ExpansionTile(
                title: Text(question),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('quiz_responses')
                        .where('quizId', isEqualTo: quizId)
                        .snapshots(),
                    builder: (context, responseSnapshot) {
                      if (!responseSnapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final responses = responseSnapshot.data!.docs;

                      if (responses.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Aucune réponse pour ce quiz."),
                        );
                      }

                      return Column(
                        children: responses.map((resp) {
                          final studentId = resp['studentId'];
                          final isCorrect = resp['isCorrect'] as bool;
                          

                          return ListTile(
                            title: FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('etudiants')
                                  .doc(studentId)
                                  .get(),
                              builder: (context, studentSnapshot) {
                                if (studentSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text("👤 Chargement...");
                                }

                                if (!studentSnapshot.hasData ||
                                    !studentSnapshot.data!.exists) {
                                  return Text(
                                      "👤 Étudiant inconnu ($studentId)");
                                }

                                final studentData = studentSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                final studentName =
                                    studentData['nom'] ?? "Sans nom";

                                return Text("👤 Étudiant: $studentName");
                              },
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Résultat: ${isCorrect ? '✅ Correct' : '❌ Faux'}"),
                               
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit_note),
                              tooltip: "Attribuer une note",
                              onPressed: () {
                                _showNoteDialog(context, resp.id);
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  ButtonBar(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditQuizScreen(quizDoc: quiz),
                            ),
                          );
                        },
                        child: const Text("✏️ Modifier"),
                      ),
                      TextButton(
                        onPressed: () => _confirmDelete(context, quizId),
                        child: const Text("🗑 Supprimer",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmer la suppression"),
        content: const Text("Voulez-vous vraiment supprimer ce quiz ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('quizzes')
                  .doc(quizId)
                  .delete();

              final responses = await FirebaseFirestore.instance
                  .collection('quiz_responses')
                  .where('quizId', isEqualTo: quizId)
                  .get();

              for (var doc in responses.docs) {
                await doc.reference.delete();
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Quiz supprimé avec succès.")),
              );
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(
      BuildContext context, String responseId) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Attribuer une note"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: "Note / Commentaire"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('quiz_responses')
                  .doc(responseId)
                  .update({'note': noteController.text});
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }
}
