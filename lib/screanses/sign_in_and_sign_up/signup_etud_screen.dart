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
  final emailctr = TextEditingController();
  final mdpctr = TextEditingController();
  final confirmemdpctr = TextEditingController();

  
  String? selectedSpecialite;
  List<String> specialiteOptions = [
    'Informatique',
    'Math',
    'Science technique',
    'Science de la matière',
  ];

  
  String? selectedlevel;
  List<String> levelOptions = [
    'Licence1',
    'Licence2',
    'Licence3',
    'Master1',
    'Master2',
  ];

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
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailctr.text.trim(),
        password: mdpctr.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection("etudiants").doc(uid).set({
        'email': emailctr.text.trim(),
        'niveau': selectedlevel,
        'nom_prenom': npctr.text.trim(),
        'specialite': selectedSpecialite,
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
                  buildTextField(npctr, "Nom Prénom:"),

                  // 🔽 Niveau Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: DropdownButtonFormField<String>(
                      value: selectedlevel,
                      hint: const Text("Niveau:"),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedlevel = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Veuillez choisir un niveau" : null,
                      items: levelOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ),
                  ),

                  // 🔽 Specialité Dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: DropdownButtonFormField<String>(
                      value: selectedSpecialite,
                      hint: const Text("Spécialité:"),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedSpecialite = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Veuillez choisir une spécialité" : null,
                      items: specialiteOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ),
                  ),

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

  Widget buildTextField(TextEditingController controller, String hintText,
      {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Ce champ est obligatoire" : null,
      ),
    );
  }
}
