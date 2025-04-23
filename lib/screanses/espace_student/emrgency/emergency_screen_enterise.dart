import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';

class EmergencyScreenEnterise extends StatelessWidget {
  final String uid; 
  EmergencyScreenEnterise({super.key, required this.uid});

  final GlobalKey<FormState> keyFormState = GlobalKey<FormState>();
  final TextEditingController familyController = TextEditingController();
  final TextEditingController friendController = TextEditingController();
  final TextEditingController choiceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[800],
        title: const Text(
          "Emergency Numbers",
          style: TextStyle(
            fontSize: 20,
            color: Colors.blueGrey,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: keyFormState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Please enter your emergency numbers"),
              const SizedBox(height: 20),
              _buildTextField(
                context,
                familyController,
                "Family Number",
                TFValidator: (val) => Cheker.isEmpty(val),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                context,
                friendController,
                "Friend Number",
                TFValidator: (val) => Cheker.isEmpty(val),
              ),
              const SizedBox(height: 15),
              _buildTextField(
                context,
                choiceController,
                "Custom Emergency Number",
                TFValidator: (val) => Cheker.isEmpty(val),
              ),
              const SizedBox(height: 30),
              _buildButton(context, "Save Numbers", Colors.purple, () async {
                if (keyFormState.currentState!.validate()) {
                  await Cheker.saveEmergencyNumbers(
                    uid: uid,
                    family: familyController.text.trim(),
                    friend: friendController.text.trim(),
                    choice: choiceController.text.trim(),
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Emergency numbers saved!")),
                  );
                  Navigator.pushReplacementNamed(context, "/emergency");
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    String? Function(String?)? TFValidator,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 255, 233),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        validator: TFValidator,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Build a custom button
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
