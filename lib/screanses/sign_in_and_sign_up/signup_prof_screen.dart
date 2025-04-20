import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hear_learn1/data/listyears.dart';

class SignUpProf extends StatefulWidget {
  const SignUpProf({super.key});

  @override
  State<SignUpProf> createState() => _SignupprofState();
}

class _SignupprofState extends State<SignUpProf> {
  final formKey = GlobalKey<FormState>();

  final npctr = TextEditingController();

  final emailctr = TextEditingController();
  final mdpctr = TextEditingController();
  final confirmmdpctr = TextEditingController();
  List<String> selectedLevels = [];
  String? selecteddepartement;
  List<String> selectedmodule = [];

  bool chekempty() {
    return (selecteddepartement?.isNotEmpty ?? true) &&
        selectedLevels.isNotEmpty;
  }

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

        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailctr.text.trim(),
          password: mdpctr.text.trim(),
        );

        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance
            .collection("utilisateurs")
            .doc(uid)
            .set({
          'uid': uid,
          'nom_prenom': npctr.text.trim(),
          'email': emailctr.text.trim(),
          'departement': selecteddepartement,
          'niveaux': selectedLevels,
          'modules':selectedmodule,
          'role': 'professeur',
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
    emailctr.dispose();
    mdpctr.dispose();
    confirmmdpctr.dispose();
    super.dispose();
  }

  void _showLevelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(selectedLevels);

        return StatefulBuilder(
          // ✅ This is the fix
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Choisir les niveaux"),
              content: SingleChildScrollView(
                child: Column(
                  children: list.levelOptions.map((level) {
                    return CheckboxListTile(
                      title: Text(level),
                      value: tempSelected.contains(level),
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          // ✅ Use this to update only the dialog
                          if (selected == true) {
                            tempSelected.add(level);
                          } else {
                            tempSelected.remove(level);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Annuler"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: Text("Valider"),
                  onPressed: () {
                    setState(() {
                      selectedLevels = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showmoduleDialog(BuildContext context, Map<String, List<String>> subjectsByGroup) {
  showDialog(
    context: context,
    builder: (context) {
      List<String> tempSelected = List.from(selectedmodule);

      return StatefulBuilder(
        builder: (context, setStateDialog) {
          // Ensure selecteddepartement and selectedLevels are not null or empty
          if (selecteddepartement == null || selectedLevels.isEmpty) {
            return AlertDialog(
              title: Text("Erreur"),
              content: Text("Veuillez sélectionner un département et un niveau."),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          }

          // Collect all modules for selected levels
          Set<String> allModules = {};
          for (String level in selectedLevels) {
            String key = "${selecteddepartement}_${level}_S1";
            if (subjectsByGroup.containsKey(key)) {
              allModules.addAll(subjectsByGroup[key]!);
            }
          }

          return AlertDialog(
            title: Text("Choisir les modules"),
            content: SingleChildScrollView(
              child: Column(
                children: allModules.map((module) {
                  return CheckboxListTile(
                    title: Text(module),
                    value: tempSelected.contains(module),
                    onChanged: (bool? selected) {
                      setStateDialog(() {
                        if (selected == true) {
                          tempSelected.add(module);
                        } else {
                          tempSelected.remove(module);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                child: Text("Annuler"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Valider"),
                onPressed: () {
                  setState(() {
                    selectedmodule = tempSelected;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: DropdownButtonFormField<String>(
                      value: selecteddepartement,
                      hint: const Text("departement:"),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 160, 46, 180),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 160, 46, 180),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selecteddepartement = value;
                        });
                      },
                      validator: (value) => value == null
                          ? "Veuillez choisir un departement"
                          : null,
                      items: list.departementOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () => _showLevelDialog(),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(255, 160, 46, 180),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              selectedLevels.isEmpty
                                  ? "Choisir un ou plusieurs niveaux"
                                  : selectedLevels.join(", "),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            if (chekempty()) {
                              _showmoduleDialog(context, list.subjectsByGroup);
                            } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('de département et le niveau ne peut pas être vide'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                            }

                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(255, 160, 46, 180),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              selectedLevels.isEmpty
                                  ? "Choisir un ou plusieurs module"
                                  : selectedLevels.join(", "),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(emailctr, "Email"),
                  const SizedBox(height: 10),
                  _buildTextField(mdpctr, "Mot de passe", isPassword: true),
                  const SizedBox(height: 10),
                  _buildTextField(confirmmdpctr, "Confirmer mot de passe",
                      isPassword: true),
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
