import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hear_learn1/data/cheker.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  @override
  void initState() {
    super.initState();
    getTeacherData();
  }

  final TextEditingController questionController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  final teacherId = FirebaseAuth.instance.currentUser?.uid;
  List<dynamic>? modules;
  List<dynamic>? levels;
  String? correctAnswer;
  String? selectedModule;
  String? selectedlevel;
  String? departement;

  Future<void> getTeacherData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(teacherId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;
        modules = userData["modules"];
        levels = userData["niveaux"];
        departement = userData["departement"];
        setState(() {});
      } else {
        print(" No teacher found with ID $teacherId");
      }
    } catch (e) {
      print(" Error getting teacher data: $e");
    }
  }

  void saveQuiz() async {
    final question = questionController.text.trim();
    final optionA = optionAController.text.trim();
    final optionB = optionBController.text.trim();
    final optionC = optionCController.text.trim();
    final optionD = optionDController.text.trim();

    if (question.isEmpty ||
        optionA.isEmpty ||
        optionB.isEmpty ||
        optionC.isEmpty ||
        optionD.isEmpty ||
        correctAnswer == null ||
        teacherId == null ||
        selectedModule == null) {
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
        'createdBy': teacherId,
        'quiz_module': selectedModule,
        "quiz_specialite":departement,
        "quiz_level":selectedlevel,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم تسجيل الاختبار بنجاح!")),
      );

      questionController.clear();
      optionAController.clear();
      optionBController.clear();
      optionCController.clear();
      optionDController.clear();
      setState(() {
        correctAnswer = null;
        selectedModule = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'enregistrement: $e"),
        backgroundColor: Colors.green,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Cheker.first_color,
          title: Text(
            "انشاء سؤال",
              style: TextStyle(
                color: Colors.black,
                fontWeight:FontWeight.bold,
                fontSize: 24
              ),
            ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: questionController,
                decoration:
                    InputDecoration(labelText: "سؤال"),
              ),
              SizedBox(height: 16),
              TextField(
                controller: optionAController,
                decoration: InputDecoration(labelText: "الخيار أ"),
              ),
              TextField(
                controller: optionBController,
                decoration: InputDecoration(labelText: "الخيار ب"),
              ),
              TextField(
                controller: optionCController,
                decoration: InputDecoration(labelText: "الخيار ج"),
              ),
              TextField(
                controller: optionDController,
                decoration: InputDecoration(labelText: "الخيار د"),
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
                    InputDecoration(labelText: "اختر الإجابة الصحيحة"),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedModule,
                items: modules?.map((module) {
                  return DropdownMenuItem<String>(
                    value: module.toString(),
                    child: Text(module.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedModule = value;
                  });
                },
                decoration: InputDecoration(labelText: "اختر الوحدة"),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedlevel,
                items: levels?.map((level) {
                  return DropdownMenuItem<String>(
                    value: level.toString(),
                    child: Text(level.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedlevel = value;
                  });
                },
                decoration: InputDecoration(labelText: "اختر المستوى"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveQuiz,
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50)),
                child: Text("احفظ السؤال"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
