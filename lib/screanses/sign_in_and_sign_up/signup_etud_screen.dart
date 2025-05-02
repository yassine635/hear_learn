import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hear_learn1/data/cheker.dart';

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

  FlutterTts flutterTts = FlutterTts();
  Future<void> parler(String text) async {
    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.75);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

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
    if (!formKey.currentState!.validate()) {
      parler("هذه الحقول النصية إلزامية");
      return;
    }
    if (!mdpconfirmer()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "لقد أدخلت كلمتي مرور مختلفتين",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
      parler("لقد أدخلت كلمتي مرور مختلفتين");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("...جاري التسجيل")),
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
        const SnackBar(
          content: Text(
            "لقد قمت بالتسجيل بنجاح",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
      );
      parler("لقد قمت بالتسجيل بنجاح");

      Navigator.pop(context);
    } catch (e) {
      print("$e");
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

  String? splni(String? text) {
    if (text == null || text.isEmpty) {
      parler("الرجاء اختيار المستوى");
      return "الرجاء اختيار المستوى";
    }
    return null;
  }

  String? spl(String? text) {
    if (text == null || text.isEmpty) {
      parler("الرجاء اختيار التخصص");
      return "الرجاء اختيار التخصص";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                    const CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage('images/student.png'),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(npctr, "الاسم واللقب"),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: DropdownButtonFormField<String>(
                        value: selectedlevel,
                        hint: const Text("المستوى"),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide(
                                color: Cheker.first_color,
                                width: 1.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(
                                color: Cheker.first_color,
                                width: 1.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedlevel = value;
                          });
                        },
                        validator: (value) => splni(value),
                        items: levelOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: DropdownButtonFormField<String>(
                        value: selectedSpecialite,
                        hint: const Text("التخصص"),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:  BorderSide(
                                color: Cheker.first_color,
                                width: 1.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:  BorderSide(
                                color: Cheker.first_color,
                                width: 1.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedSpecialite = value;
                          });
                        },
                        validator: (value) => spl(value),
                        items: specialiteOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                      ),
                    ),
                    buildTextField(emailctr, "البريد الإلكتروني",
                        isEmail: true),
                    buildTextField(mdpctr, "كلمة المرور", isPassword: true),
                    buildTextField(confirmemdpctr, "تأكيد كلمة المرور",
                        isPassword: true),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Cheker.second_color
                            ),
                        ),
                        onPressed: signupetud,
                        child: const Text(
                          "التسجيل",
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
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText,
      {bool isPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        textDirection: TextDirection.rtl, 
        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide:  BorderSide(
                color: Cheker.first_color, width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:  BorderSide(
                color: Cheker.first_color, width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "هذا الحقل إجباري" : null,
      ),
    );
  }
}
