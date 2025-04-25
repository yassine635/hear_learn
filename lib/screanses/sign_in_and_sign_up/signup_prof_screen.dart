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
    return (selecteddepartement?.isNotEmpty ?? true) && selectedLevels.isNotEmpty;
  }

  Future<void> signup() async {
    if (formKey.currentState!.validate()) {
      if (!mdpconfirmer()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vous avez saisi 2 mots de passe différents")),
        );
        return;
      }

      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Envoi en cours...")));
        FocusScope.of(context).unfocus();

        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailctr.text.trim(),
          password: mdpctr.text.trim(),
        );

        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection("utilisateurs").doc(uid).set({
          'uid': uid,
          'nom_prenom': npctr.text.trim(),
          'email': emailctr.text.trim(),
          'departement': selecteddepartement,
          'niveaux': selectedLevels,
          'modules': selectedmodule,
          'role': 'professeur',
        });

        Navigator.pushNamed(context, "/");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
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

  void _showSelectionDialog(
    String title,
    List<String> selectedItems,
    List<String> options,
    Function(List<String>) onItemsSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempSelected = List.from(selectedItems);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: tempSelected.contains(option),
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          if (selected == true) {
                            tempSelected.add(option);
                          } else {
                            tempSelected.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(child: Text("Annuler"), onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  child: Text("Valider"),
                  onPressed: () {
                    setState(() {
                      onItemsSelected(tempSelected);
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

  void _showLevelDialog() {
    _showSelectionDialog("Choisir les niveaux", selectedLevels, list.levelOptions, (newLevels) {
      setState(() {
        selectedLevels = newLevels;
      });
    });
  }

  void _showmoduleDialog(BuildContext context, Map<String, List<String>> subjectsByGroup) {
    if (selecteddepartement == null || selectedLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un département et un niveau')),
      );
      return;
    }

    Set<String> allModules = {};
    for (String level in selectedLevels) {
      String key = "${selecteddepartement}_${level}_S1";
      if (subjectsByGroup.containsKey(key)) {
        allModules.addAll(subjectsByGroup[key]!);
      }
    }

    _showSelectionDialog("Choisir les modules", selectedmodule, allModules.toList(), (newModules) {
      setState(() {
        selectedmodule = newModules;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 60, backgroundImage: AssetImage('images/Teacher.png')),
                  const SizedBox(height: 20),
                  _buildTextField(npctr, "Nom Prenom"),
                  const SizedBox(height: 10),
                  _buildDropdownField(
                    selecteddepartement,
                    "Département",
                    list.departementOptions,
                    (value) {
                      setState(() {
                        selecteddepartement = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildSelectableField(
                    "Choisir un ou plusieurs niveaux",
                    selectedLevels,
                    _showLevelDialog,
                  ),
                  const SizedBox(height: 10),
                  _buildSelectableField(
                    "Choisir un ou plusieurs modules",
                    selectedmodule,
                    () => _showmoduleDialog(context, list.subjectsByGroup),
                  ),
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
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.purple[300])),
                      onPressed: signup,
                      child: const Text(
                        "Sign Up",
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

  Widget _buildTextField(TextEditingController controller, String hintText, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
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
      validator: (value) => value == null || value.isEmpty ? "Remplissez ce champ" : null,
    );
  }

  Widget _buildDropdownField(String? value, String label, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(label),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 160, 46, 180), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: onChanged,
        validator: (value) => value == null ? "Veuillez choisir un $label" : null,
        items: options.map((option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
      ),
    );
  }

  Widget _buildSelectableField(String label, List<String> selectedItems, Function onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => onTap(),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 160, 46, 180), width: 1.5),
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
          ),
          child: Text(
            selectedItems.isEmpty ? label : selectedItems.join(', '),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
