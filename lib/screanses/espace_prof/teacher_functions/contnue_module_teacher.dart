import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/teacher_side/cour.dart';
import 'package:hear_learn1/componente/teacher_side/td.dart';
import 'package:hear_learn1/componente/teacher_side/tp.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:hear_learn1/extract_read_flutter_tts/show.dart';

class Contnue_Module_Teacher extends StatefulWidget {
  const Contnue_Module_Teacher({super.key});

  @override
  State<Contnue_Module_Teacher> createState() => _Contnue_Module_TeacherState();
}

class _Contnue_Module_TeacherState extends State<Contnue_Module_Teacher> {
  List<String> niveaux = [];
  String departement = "";
  Map<String, String> filesMap = {};
  bool isLoading = false;

  late String module;

  Future<void> fetchTeacherAndFiles(String type) async {
    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 🔍 Get teacher data from "utilisateurs"
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("utilisateurs")
          .doc(currentUser.uid)
          .get();

      niveaux = List<String>.from(userDoc.get("niveaux"));
      departement = userDoc.get("departement");

      // 📁 Prepare map to store files
      Map<String, String> tempMap = {};

      // 📂 Fetch files for every level the teacher has
      for (String level in niveaux) {
        String identifire = "${departement}_${level}_${module}_$type";

        QuerySnapshot urlsSnapshot = await FirebaseFirestore.instance
            .collection("urls")
            .where("identifire", isEqualTo: identifire)
            .orderBy("uploaded_at", descending: true)
            .get();

        for (var doc in urlsSnapshot.docs) {
          tempMap[doc.get("file_name")] = doc.get("file_id");
        }
      }

      setState(() {
        filesMap = tempMap;
        isLoading = false;
      });

      // ✅ Navigate to shared 'show' page
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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    module = args is String ? args : "مادة غير معروفة";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(module,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
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
                  onpressed: () {
                      Navigator.pushNamed(context, "/uploade", arguments: ["cour",module],);
                    },
                  realonpressed: ()=> fetchTeacherAndFiles("cour")
                  ),
                Td(
                  onpressed: () {
                      Navigator.pushNamed(context, "/uploade", arguments: ["TD",module]);
                    }, 
                  realonpressed: () => fetchTeacherAndFiles("td")
                  ),
                Tp(
                  onpressed: () {
                      Navigator.pushNamed(context, "/uploade", arguments: ["TP",module]);
                    },
                   realonpressed: () => fetchTeacherAndFiles("tp")),
              ],
            ),
    );
  }
}
