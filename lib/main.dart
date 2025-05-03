import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/SplashScreen.dart';

import 'package:hear_learn1/extract_read_flutter_tts/PDFToSpeechScreen.dart';
//import 'package:hear_learn1/data/auth.dart';
import 'package:hear_learn1/firebase_options.dart';
import 'package:hear_learn1/home/Home_student.dart';
import 'package:hear_learn1/screanses/espace_prof/teacher_functions/upload_course.dart';
import 'package:hear_learn1/screanses/espace_student/bille_reconaisence.dart/billeit.dart';
import 'package:hear_learn1/screanses/espace_student/filemanegment_cour_td_tp/contnue_module_student.dart';
import 'package:hear_learn1/screanses/espace_prof/teacher_functions/contnue_module_teacher.dart';
import 'package:hear_learn1/home/fonctionalite_screen.dart';
import 'package:hear_learn1/home/home.techer.dart';
import 'package:hear_learn1/screanses/espace_student/emrgency/emergency_screen.dart';
import 'package:hear_learn1/screanses/espace_student/emrgency/emergency_screen_enterise.dart';
import 'package:hear_learn1/screanses/espace_student/reconesonce_couleur/reconnaissence_couleur_sceen.dart';
import 'package:hear_learn1/screanses/sign_in_and_sign_up/log_in_screen.dart';
import 'package:hear_learn1/screanses/sign_in_and_sign_up/signup_etud_screen.dart';
import 'package:hear_learn1/screanses/sign_in_and_sign_up/signup_prof_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const hearlern());
}

class hearlern extends StatelessWidget {
  const hearlern({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "بصيرتي",
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/fonctionalite_screen": (context) => const Fonctionalite(),
        "/log_in_screen": (context) => const LoginScreen(),
        "/signup_prof_screen": (context) => const SignUpProf(),
        "/signup_etud_screen": (context) => const SignUpEtud(),
        "/contnu_module_student": (context) => Contnue_Module_Student(module: '',),
        "/contnu_module_teacher": (context) => Contnue_Module_Teacher(),
        //"/teacher_option": (context) => TeacherDashboard(type: '',),
        "/home_student": (context) => Home_student(),
        "/home_techer": (context) => Home_Teacher(),
        "/emergency": (context) => EmergencyScreen(),
        '/emergency_enterise': (context) {
              final uid = ModalRoute.of(context)!.settings.arguments as String;
              return EmergencyScreenEnterise(uid: uid);
           },
           "/_PDFToSpeechScreenState": (context) => Pdftospeechscreen(downloader: '',),
           "/reconnaissence_couleur_sceen": (context) => ReconnaissanceCouleur(),
           "/reconnaissence_billet_sceen": (context) => ReconBillet(),
           "/uploade": (context) => UploadCourse(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
