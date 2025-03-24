import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/screanses/home/fonctionalite_screen.dart';
import 'package:hear_learn1/screanses/sign_in_and_sign_up/log_in_screen.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading spinner
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}")); // Show error message
          } else if (snapshot.hasData) {
            return Fonctionalite();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
