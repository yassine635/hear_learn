import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class UploadCourse extends StatefulWidget {
  final String module_name;
  UploadCourse({required this.module_name});
  @override
  _UploadCourseState createState() => _UploadCourseState();
}

class _UploadCourseState extends State<UploadCourse> {
  String? curent_techer_uid = FirebaseAuth.instance.currentUser?.uid;
  String? selectedlevel;
  String? selectedmodule;
  String deprtemnt = "";
  PlatformFile? selectedFile;
  List<dynamic> niveaux = [];
  List<dynamic> modulse = [];
  String? selectedType;
  List<String> typeoptions = ["cour", "td", "tp"];
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    if (curent_techer_uid != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(curent_techer_uid)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          niveaux = data["niveaux"];
          modulse = data["modules"];
          deprtemnt = data["departement"];
        });
      } else {
        print("User document not found.");
      }
    } else {
      print("User not signed in.");
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.single;
      });
      print("File selected: ${selectedFile!.name}");
    } else {
      print("No file selected");
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) {
      Get.snackbar("Erreur", "Veuillez sélectionner un fichier");
      return;
    }
    if (selectedlevel == null ||
        selectedmodule == null ||
        selectedType == null) {
      Get.snackbar(
          "Erreur", "Veuillez choisir le niveau et le module et le type");
      return;
    }
   
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          "_" +
          selectedFile!.name;
      var storageRef = FirebaseStorage.instance
          .ref()
          .child("espace_teacher_student/$fileName");
      UploadTask uploadTask = storageRef.putData(selectedFile!.bytes!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      String identifire = "${deprtemnt}_${selectedlevel}_${selectedmodule}_$selectedType";

      await FirebaseFirestore.instance.collection("urls").add({
        "file_id": downloadURL,
        "identifire": identifire,
        "file_name": selectedFile!.name,
        "uploaded_at": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Succès", "Fichier téléchargé avec succès");
    } catch (e) {
      print("Erreur lors de l'upload: $e");
      Get.snackbar("Erreur", "Le téléchargement a échoué");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Upload file ",
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.purple[800],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 50),
                  Expanded(
                    child: Text(
                      "Upload file to ${widget.module_name}",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              Icon(Icons.upload_file, size: 100, color: Colors.black),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: Icon(Icons.folder_open, color: Colors.black),
                label: Text("Select File",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.purple[400],
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedlevel,
                hint: const Text("Niveau:"),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedlevel = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Veuillez choisir un niveau" : null,
                items: niveaux.map((option) {
                  return DropdownMenuItem<String>(
                    value: option.toString(),
                    child: Text(option.toString()),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedmodule,
                hint: const Text("Module:"),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedmodule = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Veuillez choisir un module" : null,
                items: modulse.map((option) {
                  return DropdownMenuItem<String>(
                    value: option.toString(),
                    child: Text(option.toString()),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedType,
                hint: const Text("type:"),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Veuillez choisir un type" : null,
                items: typeoptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option.toString(),
                    child: Text(option.toString()),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: uploadFile,
                icon: Icon(Icons.cloud_upload, color: Colors.black),
                label: Text("Upload File",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.purple[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
