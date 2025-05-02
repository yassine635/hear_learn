import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'edit_quiz_screen.dart';

class TeacherQuizDashboard extends StatelessWidget {
  final String teacherId;
  const TeacherQuizDashboard({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Cheker.first_color,
          title: const Text(
            "أسئلتي",
            style: TextStyle(
                color: Colors.black,
                fontWeight:FontWeight.bold,
                fontSize: 24
              ),
          ),
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
      
                return Container(
                  margin: EdgeInsets.symmetric(horizontal:10,vertical: 10 ),
                  decoration: BoxDecoration(
                      color:Colors.white, 
                      border: Border.all(
                        color: Cheker.second_color, 
                        width: 2, 
                      ),
                      borderRadius: BorderRadius.circular(10), 
                  ),
                  child: ExpansionTile(
                    title: Text(
                      question,
                      style: TextStyle(
                            color: Colors.black,
                            fontWeight:FontWeight.bold,
                            fontSize: 24
                          ),
                        ),
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
                                        studentData['nom_prenom'] ?? "Sans nom";
                        
                                    return Text("👤 طالب: $studentName");
                                  },
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "نتيجة: ${isCorrect ? '✅ صحيحة' : '❌ خطا'}"),
                                   
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit_note),
                                  tooltip: "تعيين نقطة",
                                  onPressed: () {
                                    _showNoteDialog(context, resp.id);
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      OverflowBar(
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
                            child: const Text("✏️ لتعديل"),
                          ),
                          TextButton(
                            onPressed: () => _confirmDelete(context, quizId),
                            child: const Text("🗑 حذف",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String quizId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل تريد حقًا حذف هذا الاختبار؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
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
                const SnackBar(content: Text("تم حذف السؤال بنجاح.")),
              );
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
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
        title: const Text("تعيين نقطه"),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: "التقييم / التعليق"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('quiz_responses')
                  .doc(responseId)
                  .update({'note': noteController.text});
              Navigator.pop(context);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }
}
