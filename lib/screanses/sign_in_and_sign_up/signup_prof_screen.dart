import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpProf extends StatefulWidget {
  const SignUpProf({super.key});

  @override
  State<SignUpProf> createState() => _SignupprofState();
}

class _SignupprofState extends State<SignUpProf> {
  final formKey = GlobalKey<FormState>();

  final npctr = TextEditingController();
  final modulectr = TextEditingController();
  final emailctr = TextEditingController();
  final mdpctr = TextEditingController();
  final confirmmdpctr = TextEditingController();

  Future<void> signup() async {
    if (formKey.currentState!.validate()) {
      if (!mdpconfirmer()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vous avez saisi 2 mots de passe différents"),
          ),
        );
        return;
      }

      try {
       
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Envoi en cours...")),
        );

        FocusScope.of(context).unfocus();

        
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailctr.text.trim(),
          password: mdpctr.text.trim(),
        );

        String uid = userCredential.user!.uid;

        
        await FirebaseFirestore.instance.collection("utilisateurs").doc(uid).set({
          'uid': uid,
          'nom_prenom': npctr.text.trim(),
          'module': modulectr.text.trim(),
          'email': emailctr.text.trim(),
        });

        
        Navigator.pushNamed(context, "/");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}")),
        );
      }
    }
  }

  bool mdpconfirmer() {
    return mdpctr.text.trim() == confirmmdpctr.text.trim();
  }

  @override
  void dispose() {
    npctr.dispose();
    modulectr.dispose();
    emailctr.dispose();
    mdpctr.dispose();
    confirmmdpctr.dispose();
    super.dispose(); // Call super.dispose() at the end
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 222, 231),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage('images/Teacher.png'),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(npctr, "Nom Prenom"),
                  const SizedBox(height: 10),
                  _buildTextField(modulectr, "Module"),
                  const SizedBox(height: 10),
                  _buildTextField(emailctr, "Email"),
                  const SizedBox(height: 10),
                  _buildTextField(mdpctr, "Mot de passe", isPassword: true),
                  const SizedBox(height: 10),
                  _buildTextField(confirmmdpctr, "Confirmer mot de passe", isPassword: true),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.purple[300]),
                      ),
                      onPressed: signup, // Directly call signup()
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 160, 46, 180),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 160, 46, 180),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Remplissez ce champ";
        }
        return null;
      },
    );
  }
}
