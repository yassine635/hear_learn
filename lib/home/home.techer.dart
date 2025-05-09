import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/teacher_side/module.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:hear_learn1/data/listyears.dart';

class Home_Teacher extends StatelessWidget {
  const Home_Teacher({super.key});

  Future<List<String>> getSubjectsForTEACHER() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('utilisateurs')
        .doc(uid)
        .get();

    final data = snapshot.data() as Map<String, dynamic>;
    final String departement = data['departement'];
    final List<dynamic> niveaux = data['niveaux']; 

    
    List<String> allSubjects = [];

    for (String level in niveaux) {
      String key = "${departement.trim()}_${level.trim()}_S1";
      if (list.subjectsByGroup.containsKey(key)) {
        allSubjects.addAll(list.subjectsByGroup[key]!);
      }
      print(key);
      print(list.subjectsByGroup[key]);
    }

   
    return allSubjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("صفحة الاستاذ ",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: Cheker.first_color,
        actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
            ),
          ],
      ),
      body: FutureBuilder<List<String>>(
        future: getSubjectsForTEACHER(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("خطاء في تحميل"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لم يتم العثور على أي مادة"));
          }

          List<String> subjects = snapshot.data!;
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              return Module(module: subjects[index]);
            },
          );
        },
      ),
    );
  }
}
