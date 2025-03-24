import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailctr = TextEditingController();
  final mdpctr = TextEditingController();
  bool _isLoading = false;

  Future<void> signin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailctr.text.trim(),
        password: mdpctr.text.trim(),
      );
      Navigator.pushNamed(context, "/fonctionalite_screen");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailctr.dispose();
    mdpctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100],
      body: Scrollbar(
        child: SafeArea(
          child: Center(
            // Centering the whole column
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centering items vertically
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Ensuring everything is centered
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage('images/Visually.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sign In",
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Email TextField
                  _buildTextField(emailctr, "Email :"),
                  SizedBox(height: 10),

                  // Password TextField
                  _buildTextField(mdpctr, "Mot de passe :", obscureText: true),
                  SizedBox(height: 20),

                  // Login Button
                  _isLoading
                      ? CircularProgressIndicator()
                      : _buildButton(
                          "Connexion", Colors.lightGreen[300], signin),
                  SizedBox(height: 20),

                  // Signup as Teacher Button
                  _buildButton(
                    "Inscrire comme enseignant(e)",
                    Colors.lightGreen[300],
                    () => Navigator.pushNamed(context, "/signup_prof_screen"),
                  ),
                  SizedBox(height: 10),

                  // Signup as Student Button
                  _buildButton(
                    "Inscrire comme étudiant(e)",
                    Colors.lightGreen[300],
                    () => Navigator.pushNamed(context, "/signup_etud_screen"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding:
          EdgeInsets.symmetric(horizontal: 20), // Centering text inside field
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 245, 255, 233),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color? color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9, // Centering the button
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
