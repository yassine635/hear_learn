import 'package:shared_preferences/shared_preferences.dart';

class Cheker {

  // Check if it's the first time the emergency setup is being done
  static Future<bool> isFirstTimeEmergency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('emergency_setup_done') ?? true; 
  }

  // Save emergency numbers
  static Future<void> saveEmergencyNumbers({
    required String family,
    required String friend,
    required String choice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_family', family);
    await prefs.setString('emergency_friend', friend);
    await prefs.setString('emergency_choice', choice);
    await prefs.setBool('emergency_setup_done', false); 
  }

  // Get emergency numbers
  static Future<Map<String, String>> getEmergencyNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'family': prefs.getString('emergency_family') ?? '',
      'friend': prefs.getString('emergency_friend') ?? '',
      'choice': prefs.getString('emergency_choice') ?? '',
    };
  }

  // Validate if a value is empty
  static String? isEmpty(String? val) {
    if (val == null || val.isEmpty) {
      return "can't be empty";
    }
    return null;
  }
}
