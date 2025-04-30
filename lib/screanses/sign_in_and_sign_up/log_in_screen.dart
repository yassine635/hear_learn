import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailctr = TextEditingController();
  final mdpctr = TextEditingController();
  bool _isLoading = false;
  final GlobalKey<FormState> keyFormState = GlobalKey<FormState>();

  FlutterTts flutterTts = FlutterTts();
  Future<void> parler(String text) async {
    await flutterTts.setLanguage("ar");
    await flutterTts.setSpeechRate(0.75);
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  Future<void> signin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailctr.text.trim(),
        password: mdpctr.text.trim(),
      );
      FocusScope.of(context).unfocus();
      Navigator.pushNamed(context, "/fonctionalite_screen");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "يرجى إعادة إدخال بريدك الإلكتروني وكلمة المرور ",
           style: TextStyle(
                color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,

          ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? is_empty(String? val) {
    if (val == null || val.isEmpty) {
      return "لا يمكن أن يكون فارغا";
    }
    return null;
  }

  @override
  void dispose() {
    emailctr.dispose();
    mdpctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Scrollbar(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: keyFormState,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: AssetImage('images/Visually.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                              fontSize: 45, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                    
                        // Email TextField
                        buildTextField(
                          emailctr,
                          "بريد إلكتروني:",
                          isEmail: true,
                          TFValidator: (val) => is_empty(val),
                        ),
                        SizedBox(height: 10),
                    
                        // Password TextField
                        buildTextField(
                          mdpctr,
                          "كلمة المرور:",
                          isPassword: true,
                          TFValidator: (val) => is_empty(val),
                        ),
                        SizedBox(height: 20),
                    
                        // Login Button
                        _isLoading
                            ? CircularProgressIndicator()
                            : _buildButton(
                                "تسجيل الدخول",
                                Colors.purple[300],
                                () {
                                  if (keyFormState.currentState!.validate()) {
                                    signin();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "لا يمكن أن يكون حقل النص فارغًا",
                                          style: TextStyle(
                                              color: Colors.black, fontSize: 24),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    parler("لا يمكن أن يكون حقل النص فارغًا");
                                  }
                                },
                              ),
                        SizedBox(height: 20),
                    
                        // Signup as Teacher Button
                        _buildButton(
                          "التسجيل كمدرس",
                          Colors.purple[300],
                          () =>
                              Navigator.pushNamed(context, "/signup_prof_screen"),
                        ),
                        SizedBox(height: 10),
                    
                        // Signup as Student Button
                        _buildButton(
                          "التسجيل كطالب",
                          Colors.purple[300],
                          () =>
                              Navigator.pushNamed(context, "/signup_etud_screen"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hintText,
      {bool isPassword = false, bool isEmail = false, required String? Function(dynamic val) TFValidator}) {
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
        validator: TFValidator,
            
      ),
    );
  }

  Widget _buildButton(String text, Color? color, VoidCallback onPressed) {
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
