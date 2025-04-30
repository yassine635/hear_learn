import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  FlutterTts flutterTts = FlutterTts();
  Future<void> parler(String text) async {
    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.75);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  bool chekempty() {
    return (selecteddepartement?.isNotEmpty ?? true) &&
        selectedLevels.isNotEmpty;
  }

  Future<void> signup() async {
    if (formKey.currentState!.validate()) {
      if (!mdpconfirmer()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "لقد أدخلت كلمتي مرور مختلفتين",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
        parler("لقد أدخلت كلمتي مرور مختلفتين");
        return;
      }

      try {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("إرسال البيانات...")));
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
          'modules': selectedmodule,
          'role': 'professeur',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "لقد قمت بالتسجيل بنجاح",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );
        parler("لقد قمت بالتسجيل بنجاح");
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "لقد حدث خطأ ما",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
        parler("لقد حدث خطأ ما");
      }
    } else {
      parler("هذه الحقول النصية إلزامية");
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
                TextButton(
                    child: Text("إلغاء"),
                    onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  child: Text("تأكيد"),
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
    _showSelectionDialog("اختيار المستويات", selectedLevels, list.levelOptions,
        (newLevels) {
      setState(() {
        selectedLevels = newLevels;
      });
    });
  }

  void _showmoduleDialog(
      BuildContext context, Map<String, List<String>> subjectsByGroup) {
    if (selecteddepartement == null || selectedLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "يرجى اختيار القسم والمستوى",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
      parler("يرجى اختيار القسم والمستوى");
      return;
    }

    Set<String> allModules = {};
    for (String level in selectedLevels) {
      String key = "${selecteddepartement}_${level}_S1";
      if (subjectsByGroup.containsKey(key)) {
        allModules.addAll(subjectsByGroup[key]!);
      }
    }
    for (String level in selectedLevels) {
      String key = "${selecteddepartement}_${level}_S2";
      if (subjectsByGroup.containsKey(key)) {
        allModules.addAll(subjectsByGroup[key]!);
      }
    }

    _showSelectionDialog("اختيار الوحدات", selectedmodule, allModules.toList(),
        (newModules) {
      setState(() {
        selectedmodule = newModules;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                        radius: 60,
                        backgroundImage: AssetImage('images/Teacher.png')),
                    const SizedBox(height: 20),
                    buildTextField(npctr, "الاسم الكامل"),
                    const SizedBox(height: 10),
                    _buildDropdownField(
                      selecteddepartement,
                      "القسم",
                      list.departementOptions,
                      (value) {
                        setState(() {
                          selecteddepartement = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSelectableField(
                      "اختيار مستوى واحد أو أكثر",
                      selectedLevels,
                      _showLevelDialog,
                    ),
                    const SizedBox(height: 10),
                    _buildSelectableField(
                      "اختيار وحدة أو أكثر",
                      selectedmodule,
                      () => _showmoduleDialog(context, list.subjectsByGroup),
                    ),
                    const SizedBox(height: 10),
                    buildTextField(emailctr, "البريد الإلكتروني"),
                    const SizedBox(height: 10),
                    buildTextField(mdpctr, "كلمة المرور", isPassword: true),
                    const SizedBox(height: 10),
                    buildTextField(confirmmdpctr, "تأكيد كلمة المرور",
                        isPassword: true),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.purple[300])),
                        onPressed: signup,
                        child: const Text(
                          "التسجيل",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
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
        textDirection: TextDirection.rtl, // TextField content RTL
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
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
        validator: (value) =>
            value == null || value.isEmpty ? "هذا الحقل إجباري" : null,
      ),
    );
  }

  Widget _buildDropdownField(String? value, String label, List<String> options,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(label),
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
        onChanged: onChanged,
        validator: (value) => value == null ? "يرجى اختيار $label" : null,
        items: options.map((option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
      ),
    );
  }

  Widget _buildSelectableField(
      String label, List<String> selectedItems, Function onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () => onTap(),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(255, 160, 46, 180), width: 1.5),
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
