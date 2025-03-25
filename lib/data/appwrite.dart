import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
class AppWrite {
  

  // University levels
  static List<String> L3_S1 = [
    "Système d'exploitation",
    "Interface Homme-Machine",
    "Software Engineering",
    "Compilation"
  ];

  static List<String> L3_S2 = [
    "App Mobile",
    "Sécurité",
    "DSS (Données et Structures de Stockage)",
    "Compilation"
  ];
  static List<String> L1_S1 = [
    "Système d'exploitation",
    "Interface Homme-Machine",
    "Software Engineering",
    "Compilation"
  ];

  static List<String> L1_S2 = [
    "App Mobile",
    "Sécurité",
    "DSS (Données et Structures de Stockage)",
    "Compilation"
  ];
  static List<String> L2_S1 = [
    "Système d'exploitation",
    "Interface Homme-Machine",
    "Software Engineering",
    "Compilation"
  ];

  static List<String> L2_S2 = [
    "App Mobile",
    "Sécurité",
    "DSS (Données et Structures de Stockage)",
    "Compilation"
  ];
  static List<String> M1_S1 = [
    "Système d'exploitation",
    "Interface Homme-Machine",
    "Software Engineering",
    "Compilation"
  ];

  static List<String> M1_S2 = [
    "App Mobile",
    "Sécurité",
    "DSS (Données et Structures de Stockage)",
    "Compilation"
  ];
  
  late Client client;
  late Storage storage;
  final String apiKey = "standard_dc08a10473dc69c449ec947ae67ad53cbf747eb7989c02a0684451015888535cf7c22798e49f397bb813d1ecd685b0ea28c3aa709abd5994a507f5488293dc400163f2675ec9ddd617978904e4b33a3ea52f8702ebe53a678b851d0e879a642c244f9a0e5a897ffb79952564d71f4ed0d4d3bf52c11008add6459bf59bb5aae5"; 
  AppWrite() {
    client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("67dc0ea70005df138bad") 
      .setSelfSigned(status: true); 

    storage = Storage(client);
  }

   Future<String?> uploadFile(PlatformFile file) async {
    try {
      if (file.bytes == null) {
        print("Error: File is empty.");
        return null;
      }

      final response = await storage.createFile(
        bucketId: "67dc114200333ba42c45", 
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: file.bytes!,
          filename: file.name,
        ),
        permissions: [
          Permission.read(Role.any()), // Allow public read access
          Permission.write(Role.any()), // Allow public write access
        ],
        
      );

      print("File uploaded successfully: ${response.$id}");
      return response.$id;  
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }
}
