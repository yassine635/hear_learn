import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:hear_learn1/extract_read_flutter_tts/PDFToSpeechScreen.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

import 'package:path_provider/path_provider.dart'; 
import 'dart:io'; 
 

class FileContaner extends StatefulWidget {
  final String file_name;
  final String file_id;
  final String storage_path; 
  final String docId; 

  const FileContaner({
    super.key,
    required this.file_name,
    required this.file_id,
    required this.storage_path,
    required this.docId,
  });

  @override
  _FileContanerState createState() => _FileContanerState();
}

class _FileContanerState extends State<FileContaner> {
  int? userType;

  @override
  void initState() {
    super.initState();
    fetchUserType();
  }

  Future<void> fetchUserType() async {
    int type = await getUserType();
    setState(() {
      userType = type;
    });
  }

  Future<int> getUserType() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    String uid = user.uid;

    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(uid)
          .get();

      if (studentDoc.exists) return 1;

      DocumentSnapshot profDoc = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(uid)
          .get();

      if (profDoc.exists) return 2;

      return 0;
    } catch (e) {
      print("ERROR: $e");
      return 0;
    }
  }

  
  Future<void> downloadFile(String storagePath, String fileName) async {
    try {
      
      final Directory? directory = await getExternalStorageDirectory();
      final String filePath = '${directory!.path}/$fileName';

      
      final Reference ref = FirebaseStorage.instance.ref(storagePath);
      final File file = File(filePath);

      
      await ref.writeToFile(file);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' تم تحمل الملف بنجاح')),
      );
    } catch (e) {
      print("Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(' حدث خطاء اثناء تحميل الملف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: screenWidth * 0.9,
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Pdftospeechscreen(
                            downloader: widget.file_id,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Cheker.second_color, width: 2),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                    label: Text(
                      widget.file_name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                if (userType == 1) 
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.blue),
                    onPressed: () {
                      downloadFile(widget.storage_path, widget.file_name);
                    },
                  )
                else if (userType == 2)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تاكيد الحذف'),
                            content: const Text('هل انت متاكد من حذف هذ ملف؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('لا'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await deleteFileFromFirebase(
                                      widget.storage_path, widget.docId);
                                  Navigator.pop(context);
                                },
                                child: const Text('نعم'),
                              ),
                            ],
                          ),
                        );
                      } else if (value == 'download') {
                        downloadFile(widget.storage_path, widget.file_name);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'download',
                        child: Text('تحميل'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  
  Future<void> deleteFileFromFirebase(String storagePath, String docId) async {
    try {
      
      await FirebaseStorage.instance.ref(storagePath).delete();

      
      await FirebaseFirestore.instance.collection('urls').doc(docId).delete();

      print('File deleted successfully!');
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
