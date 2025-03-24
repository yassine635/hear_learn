import 'package:appwrite/appwrite.dart';

class AppWrite {
  Client client = Client();

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
  // Constructor
  AppWrite() {
    client
        .setEndpoint("https://cloud.appwrite.io/v1")
        .setProject("67dc0ea70005df138bad")
        .setSelfSigned(status: true);
  }
}
