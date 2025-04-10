import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String familyNumber = "";
  String friendNumber = "";
  String customNumber = "";
  String? uid;

  @override
  void initState() {
    super.initState();
    checkFirstTime();
  }

  // 🔔 Function to launch a phone call
  void callNumber(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $number';
    }
  }

  // 🔍 Check Firestore if it's first time setup
  void checkFirstTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    uid = user.uid;
    bool firstTime = await Cheker.isFirstTimeEmergency(uid!);

    if (firstTime) {
      // First time, go to the input screen
      Navigator.pushReplacementNamed(
        context,
        "/emergency_enterise",
        arguments: uid, 
      );
    } else {
      // Get emergency numbers from Firestore
      Map<String, String> emergencyNumbers = await Cheker.getEmergencyNumbers(uid!);

      setState(() {
        familyNumber = emergencyNumbers['family'] ?? 'No number set';
        friendNumber = emergencyNumbers['friend'] ?? 'No number set';
        customNumber = emergencyNumbers['choice'] ?? 'No number set';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bouton d'Urgence"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, "Family", Colors.lightGreen, () => callNumber(familyNumber)),
            const SizedBox(height: 30),
            _buildButton(context, "Friend", Colors.lightGreen, () => callNumber(friendNumber)),
            const SizedBox(height: 30),
            _buildButton(context, "Custom", Colors.lightGreen, () => callNumber(customNumber)),
            const SizedBox(height: 30),
            _buildButton(context, "Change Numbers", Colors.redAccent, () {
              Navigator.pushReplacementNamed(
                context,
                "/emergency_enterise",
                arguments: uid, // Pass uid when editing
              );
            }),
          ],
        ),
      ),
    );
  }

  // 🔘 Reusable button widget
  Widget _buildButton(
    BuildContext context,
    String text,
    Color? color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
