import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/cour.dart';
import 'package:hear_learn1/componente/student_side/td.dart';
import 'package:hear_learn1/componente/student_side/tp.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:hear_learn1/extract_read_flutter_tts/show.dart';

class Contnue_Module_Student extends StatefulWidget {
  final String module;

  const Contnue_Module_Student({super.key, required this.module});

  @override
  State<Contnue_Module_Student> createState() => _Contnue_Module_StudentState();
}

class _Contnue_Module_StudentState extends State<Contnue_Module_Student> {
  String level = "";
  String specialite = "";
  Map<String, String> filesMap = {}; // ✅ New map: { file_name : file_id }

  bool isLoading = false;

  Future<void> fetchStudentAndFiles(String type) async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 🔍 Get student data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("etudiants")
          .doc(currentUser.uid)
          .get();

      level = userDoc.get("niveau");
      specialite = userDoc.get("specialite");

      String identifire = "${specialite}_${level}_${widget.module}_$type";
      

      // 📁 Get matching files
      QuerySnapshot urlsSnapshot = await FirebaseFirestore.instance
          .collection("urls")
          .where("identifire", isEqualTo: identifire)
          .orderBy("uploaded_at", descending: true)
          .get();

      Map<String, String> tempMap = {};
      for (var doc in urlsSnapshot.docs) {
        tempMap[doc.get("file_name")] = doc.get("file_id");
      }

      setState(() {
        filesMap = tempMap;
        isLoading = false;
      });
      
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Shou(
            type: type,
            filename: filesMap.keys.toList(),
            fileids: filesMap.values.toList(),
          ),
        ),
      );
    } catch (e) {
      print("Erreur lors du chargement: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.module,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
            ),
          ],
          backgroundColor: Cheker.first_color,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Cour(
                    onpressed: () => fetchStudentAndFiles("cour"),
                  ),
                  Td(
                    onpressed: () => fetchStudentAndFiles("td"),
                  ),
                  Tp(
                    onpressed: () => fetchStudentAndFiles("tp"),
                  ),
                ],
              ),
      ),
    );
  }
}
