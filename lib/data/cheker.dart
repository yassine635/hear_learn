import 'package:cloud_firestore/cloud_firestore.dart';


class Cheker {
  static Future<bool> isFirstTimeEmergency(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['first_time'] ?? true;
      } else {
        return true;
      }
    } catch (e) {
      print('Error fetching Firestore first_time flag: $e');
      return true;
    }
  }

  static Future<void> saveEmergencyNumbers({
    required String uid,
    required String family,
    required String friend,
    required String choice,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('etudiants').doc(uid).update({
        'num_family': family,
        'num_freind': friend,
        'num_custome': choice,
        'first_time': false,
      });
      
    } catch (e) {
      print("Error saving emergency numbers: $e");
    }
  }

  static Future<Map<String, String>> getEmergencyNumbers(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('etudiants')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'family': data['num_family'] ?? '',
          'friend': data['num_freind'] ?? '',
          'choice': data['num_custome'] ?? '',
        };
      } else {
        return {'family': '', 'friend': '', 'choice': ''};
      }
    } catch (e) {
      print("Error fetching emergency numbers: $e");
      return {'family': '', 'friend': '', 'choice': ''};
    }
  }

  static bool isMoreThanThreeDaysAgo(DateTime date) {
    DateTime threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
    return date.isBefore(threeDaysAgo);
  }

  static String? isEmpty(String? val) {
    if (val == null || val.isEmpty) {
      return "can't be empty";
    }
    return null;
  }
}
