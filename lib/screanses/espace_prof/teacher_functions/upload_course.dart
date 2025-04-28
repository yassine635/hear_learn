import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadCourse extends StatefulWidget {
  const UploadCourse({
    super.key,
  });
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
  String uploadStatus = "";
  String module_name = "";
  String typemodule = "";

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
      } 
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
      
    } 
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) {
      setState(() {
        uploadStatus = "Aucun fichier sélectionné.";
      });
      return;
    }

    if (selectedlevel == null ||
        selectedmodule == null ||
        selectedType == null) {
      setState(() {
        uploadStatus = "يرجى ملء جميع الحقول.";
      });
      return;
    }

    try {
      setState(() {
        uploadStatus = "جاري التحميل..."; // Uploading...
      });

      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.name}";

      var storageRef = FirebaseStorage.instance
          .ref()
          .child("espace_teacher_student/$fileName");

     
      UploadTask uploadTask = storageRef.putData(selectedFile!.bytes!);
      TaskSnapshot snapshot = await uploadTask;

      
      String downloadURL = await snapshot.ref.getDownloadURL();
      String storagePath = snapshot.ref.fullPath;

     
      String identifire =
          "${deprtemnt}_${selectedlevel}_${selectedmodule}_$selectedType";

    
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection("urls").add({
        "file_id": downloadURL,
        "storage_path": storagePath,
        "identifire": identifire,
        "file_name": selectedFile!.name,
        "uploaded_at": FieldValue.serverTimestamp(),
      });

     
      String docId = docRef.id;

      
      await docRef.update({
        "docID": docId,
      });

      setState(() {
        uploadStatus = "Fichier Téléverser avec succès ✅";
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() {
        uploadStatus = "Erreur lors du téléchargement ❌";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final List data = args as List;
    module_name = data[1];
    selectedType = data[0];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("تحميل الملفات ",
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
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [

              Row(
                children: [
                  SizedBox(width: 50),
                  
                  Expanded(
                    child: Text(
                      "تحميل الملف إلى",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
              Text(
                    module_name,
                     style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
              Icon(Icons.upload_file, size: 100, color: Colors.black),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: Icon(Icons.folder_open, color: Colors.black),
                label: Text("حدد الملف",
                    style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.purple[400],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple, // Purple border
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: Text(
                  selectedFile != null
                      ? "${selectedFile!.name}:الملف محدد"
                      : "لم يتم تحديد أي ملف",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                  value: selectedlevel,
                  hint: const Text("مستوى:", textDirection: TextDirection.rtl),
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
                      value == null ? "الرجاء اختيار المستوى" : null,
                  items: niveaux.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.toString(),
                      child: Text(option.toString(), textDirection: TextDirection.rtl),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedmodule,
                  hint: const Text("الوحدة:", textDirection: TextDirection.rtl),
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
                      value == null ? "الرجاء اختيار الوحدة" : null,
                  items: modulse.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.toString(),
                      child: Text(option.toString(), textDirection: TextDirection.rtl),
                    );
                  }).toList(),
                ),

              SizedBox(height: 20),
              
              Text(
                uploadStatus,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: uploadStatus.contains("نجاح")
                      ? Colors.green
                      : uploadStatus.contains("خطأ")
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
              ElevatedButton.icon(
                onPressed: uploadFile,
                icon: Icon(Icons.cloud_upload, color: Colors.black),
                label: Text("تحميل الملف",
                    style: TextStyle(color: Colors.black, fontSize: 24,fontWeight: FontWeight.bold)),
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
