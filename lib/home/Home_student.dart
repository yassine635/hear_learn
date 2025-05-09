import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/module.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:hear_learn1/data/listyears.dart';

//import 'package:hear_learn1/screanses/teacher_dashboard.dart';

class Home_student extends StatelessWidget {
  const Home_student({super.key});

  Future<List<String>> getSubjectsForSTUDENT() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('etudiants').doc(uid).get();

    final data = snapshot.data() as Map<String, dynamic>;
    final String specialite = data['specialite'];
    final String niveau = data['niveau']; 

   
    List<String> allSubjects = [];

    String key = "${specialite.trim()}_${niveau.trim()}_S1";
    if (list.subjectsByGroup.containsKey(key)) {
      allSubjects.addAll(list.subjectsByGroup[key]!);
    }

    print(key);
    print(list.subjectsByGroup[key]);
    print(allSubjects);
    return allSubjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("صفحة الطلبة",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/fonctionalite_screen");
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
        backgroundColor: Cheker.first_color,
      ),
      body: Column(
        children: [
          
          FutureBuilder<List<String>>(
            future: getSubjectsForSTUDENT(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("خطأ في التحميل"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("لم يتم العثور على أي مادة"));
              }

              List<String> subjects = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return Module(module: subjects[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
