import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/file_contaner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hear_learn1/data/cheker.dart'; // For deleting storage file

class Shou extends StatefulWidget {
  final String type;
  final List<String> filename;
  final List<String> fileids;  // Here fileids are the 'downloader' (file unique identifiers)

  const Shou({
    super.key,
    required this.type,
    required this.filename,
    required this.fileids,
  });

  @override
  State<Shou> createState() => _ShouCourState();
}

class _ShouCourState extends State<Shou> {
  // This function retrieves the storage path and document ID from Firestore based on downloader (file_id)
  Future<Map<String, String>> fetchFileDetails(String downloader) async {
    try {
      // Query Firestore to get the document for this downloader (file_id)
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('urls') // Assuming the collection is 'urls'
          .where('file_id', isEqualTo: downloader) // Fetch the document based on downloader
          .get();

      if (snapshot.docs.isNotEmpty) {
        // If the document exists, return the data (storage_path and docId)
        var document = snapshot.docs.first;
        return {
          'storage_path': document['storage_path'],
          'docId': document.id,
        };
      } else {
        return {}; // Return an empty map if no document found
      }
    } catch (e) {
      print('Error fetching file details: $e');
      return {}; // Return an empty map in case of error
    }
  }

  // This function deletes the file and document from Firebase
  Future<void> deleteFileFromFirebase(String storagePath, String docId) async {
    try {
      // Delete the file from Firebase Storage
      await FirebaseStorage.instance.ref(storagePath).delete();

      // Delete the Firestore document
      await FirebaseFirestore.instance.collection('urls').doc(docId).delete();

      // Notify the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully!')),
      );

      // After deletion, refresh the page by calling setState
      setState(() {
        // Remove the file from the lists
        widget.filename.removeAt(widget.filename.indexOf(storagePath));
        widget.fileids.removeAt(widget.fileids.indexOf(docId));
      });
    } catch (e) {
      print('Error deleting file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطاء في حذف الملف ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cheker.first_color,
        title: Text(
          widget.type,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.filename.length,
        itemBuilder: (context, index) {
          // Fetch the file details (storage_path and docId) asynchronously
          return FutureBuilder<Map<String, String>>(
            future: fetchFileDetails(widget.fileids[index]), // Passing downloader here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListTile(
                  title: Text("تحميل..."),
                );
              } else if (snapshot.hasError) {
                return ListTile(
                  title: Text("خطاء في سحب الملف من قاعدة اليبانات"),
                );
              } else if (snapshot.hasData) {
                var fileDetails = snapshot.data!;
                // Check if data is available
                if (fileDetails.isNotEmpty) {
                  // Pass storage_path and docId to FileContaner
                  return ListTile(
                    title: FileContaner(
                      file_name: widget.filename[index],
                      file_id: widget.fileids[index], // Using file_id (downloader) here
                      storage_path: fileDetails['storage_path']!,
                      docId: fileDetails['docId']!,
                    ),
                    onTap: () {
                      // Handle tap if needed
                    },
                  );
                } else {
                  return ListTile(
                    title: Text("لم يتم العثور على تفاصيل الملف"),
                  );
                }
              } else {
                return ListTile(
                  title: Text("بيانات غير متوفرة"),
                );
              }
            },
          );
        },
      ),
    );
  }
}
