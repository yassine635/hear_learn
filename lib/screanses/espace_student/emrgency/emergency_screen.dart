import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

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

 
  void callNumber(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $number';
    }
  }

  
  void checkFirstTime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    uid = user.uid;
    bool firstTime = await Cheker.isFirstTimeEmergency(uid!);

    if (firstTime) {
      
      Navigator.pushReplacementNamed(
        context,
        "/emergency_enterise",
        arguments: uid, 
      );
    } else {
      
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "أزرار الطوارئ",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.right,
            ),
            
          backgroundColor: Cheker.first_color,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(context, "عائلة", Cheker.second_color, () => callNumber(familyNumber)),
              const SizedBox(height: 30),
              _buildButton(context, "صديق", Cheker.second_color, () => callNumber(friendNumber)),
              const SizedBox(height: 30),
              _buildButton(context, "مخصص", Cheker.second_color, () => callNumber(customNumber)),
              const SizedBox(height: 30),
              _buildButton(context, "تغيير الأرقام", Cheker.first_color, () {
                Navigator.pushNamed(
                  context,
                  "/emergency_enterise",
                  arguments: uid,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  
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
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
