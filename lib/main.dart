import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/STT_TTS/TTS.DART/PDFToSpeechScreen.dart';

import 'package:hear_learn1/data/auth.dart';
import 'package:hear_learn1/firebase_options.dart';
import 'package:hear_learn1/home/Home_student.dart';
import 'package:hear_learn1/screanses/espace_student/contnue_module_student.dart';
import 'package:hear_learn1/screanses/espace_prof/teacher_functions/contnue_module_teacher.dart';
import 'package:hear_learn1/screanses/espace_prof/teacher_functions/teacher_dashboard.dart';
import 'package:hear_learn1/home/fonctionalite_screen.dart';
import 'package:hear_learn1/home/home.techer.dart';
import 'package:hear_learn1/screanses/espace_student/emrgency/emergency_screen.dart';
import 'package:hear_learn1/screanses/espace_student/emrgency/emergency_screen_enterise.dart';
import 'package:hear_learn1/screanses/sign_in_and_sign_up/log_in_screen.dart';
import 'package:hear_learn1/screanses/sign_in_and_sign_up/signup_etud_screen.dart';
import 'package:hear_learn1/screanses/sign_in_and_sign_up/signup_prof_screen.dart';
//import 'package:hear_learn1/tts_stt/PDFToSpeechScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, 
  );
  runApp(const hearlern());
}

class hearlern extends StatelessWidget {
  const hearlern({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => const Auth(),
        "/fonctionalite_screen": (context) => const Fonctionalite(),
        "/log_in_screen": (context) => const LoginScreen(),
        "/signup_prof_screen": (context) => const SignUpProf(),
        "/signup_etud_screen": (context) => const SignUpEtud(),
        "/contnu_module_student": (context) => Contnue_Module_Student(),
        "/contnu_module_teacher": (context) => Contnue_Module_Teacher(),
        "/teacher_option": (context) => TeacherDashboard(),
        "/home_student": (context) => Home_student(),
        "/home_techer": (context) => Home_Teacher(),
        "/emergency": (context) => EmergencyScreen(),
        '/emergency_enterise': (context) {
              final uid = ModalRoute.of(context)!.settings.arguments as String;
              return EmergencyScreenEnterise(uid: uid);
           },

           "/_PDFToSpeechScreenState": (context) => PDFToSpeechScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
