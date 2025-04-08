import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
   String familyNumber = "";
   String friendNumber = "";
   String customNumber = "";
  // Function to launch a phone call
  void callNumber(String number) async {
    

    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $number';
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstTime();
  }

  // Check if it's the first time the emergency numbers are set up
  void checkFirstTime() async {
    bool firstTime = await Cheker.isFirstTimeEmergency();
    if (firstTime) {
      Navigator.pushNamed(context, "/emergency_enterise");
    } else {
      // Get the emergency numbers and display or use them
      Map<String, String> emergencyNumbers = await Cheker.getEmergencyNumbers();

       familyNumber = emergencyNumbers['family'] ?? 'No number set';
       friendNumber = emergencyNumbers['friend'] ?? 'No number set';
       customNumber = emergencyNumbers['choice'] ?? 'No number set';

      // Print the numbers (you can use them for calling or displaying in the UI)
      print("Family Number: $familyNumber");
      print("Friend Number: $friendNumber");
      print("Custom Number: $customNumber");

      
    }
  }

  // Function to show emergency options (bottom sheet)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bouton d'Urgence"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          _buildButton(context, "famely", Colors.lightGreen,() =>callNumber(familyNumber)),
          SizedBox(height: 40,),
          _buildButton(context, "frend", Colors.lightGreen,() =>callNumber(friendNumber)),
          SizedBox(height: 40,),
          _buildButton(context, "custom number", Colors.lightGreen,() =>callNumber(customNumber)),
          SizedBox(height: 40,),
        ]),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color? color, VoidCallback onPressed) {
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
