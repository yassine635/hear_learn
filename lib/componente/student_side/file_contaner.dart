import 'package:flutter/material.dart';
import 'package:hear_learn1/extract_read_flutter_tts/PDFToSpeechScreen.dart';
import 'package:firebase_storage/firebase_storage.dart'; // for deleting storage file
import 'package:cloud_firestore/cloud_firestore.dart'; // for deleting firestore document

class FileContaner extends StatelessWidget {
  final String file_name;
  final String file_id;

  const FileContaner({
    super.key,
    required this.file_name,
    required this.file_id,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // get screen width

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: screenWidth * 0.9,
            child: Row(
              children: [
                Expanded( // make button take available space
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Pdftospeechscreen(
                            downloader: file_id,
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
                        side: BorderSide(color: Colors.purple.shade400, width: 2),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                    label: Text(
                      file_name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // small space between button and icon
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this file?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );

                    if (confirmDelete == true) {
                      await deleteFileFromFirebase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File deleted successfully!')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> deleteFileFromFirebase() async {
    try {
      // Delete from Firebase Storage
      await FirebaseStorage.instance.ref(file_id).delete();

      // Delete from Firestore
      await FirebaseFirestore.instance.collection('urls').doc(file_id).delete();
      
      print('File deleted successfully from storage and database!');
    } catch (e) {
      print('Error deleting file: $e');
    }
  }
}
