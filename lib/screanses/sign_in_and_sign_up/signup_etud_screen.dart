import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpEtud extends StatefulWidget {
  const SignUpEtud({super.key});

  @override
  State<SignUpEtud> createState() => _SignUpEtudState();
}

class _SignUpEtudState extends State<SignUpEtud> {
  final formKey = GlobalKey<FormState>();

  final npctr = TextEditingController();
  final niveauctr = TextEditingController();
  final specialitectr = TextEditingController();
  final emailctr = TextEditingController();
  final mdpctr = TextEditingController();
  final confirmemdpctr = TextEditingController();

  bool mdpconfirmer() {
    return mdpctr.text.trim() == confirmemdpctr.text.trim();
  }

  Future<void> signupetud() async {
    if (!formKey.currentState!.validate()) return;
    if (!mdpconfirmer()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enregistrement en cours...")),
    );
    FocusScope.of(context).unfocus();

    try {
      // Create User in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailctr.text.trim(),
        password: mdpctr.text.trim(),
      );

      String uid = userCredential.user!.uid; 

      // Store user details in Firestore with the same UID
      await FirebaseFirestore.instance.collection("etudiants").doc(uid).set({
        'email': emailctr.text.trim(),
        'niveau': niveauctr.text.trim(),
        'nom_prenom': npctr.text.trim(),
        'specialite': specialitectr.text.trim(),
        'first_time': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscription réussie !")),
      );

      Navigator.of(context).pushNamed("/");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  @override
  void dispose() {
    npctr.dispose();
    mdpctr.dispose();
    emailctr.dispose();
    niveauctr.dispose();
    specialitectr.dispose();
    confirmemdpctr.dispose();
    super.dispose();
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
                    backgroundImage: AssetImage('images/student.png'),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(npctr, "Nom Prenom:"),
                  buildTextField(niveauctr, "Niveau:"),
                  buildTextField(specialitectr, "Specialité:"),
                  buildTextField(emailctr, "Email:", isEmail: true),
                  buildTextField(mdpctr, "Mot de passe:", isPassword: true),
                  buildTextField(confirmemdpctr, "Confirmer mot de passe:", isPassword: true),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.purple[300]),
                      ),
                      onPressed: signupetud,
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
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

  Widget buildTextField(TextEditingController controller, String hintText, {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? "Ce champ est obligatoire" : null,
      ),
    );
  }
}
