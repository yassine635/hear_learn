import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hear_learn1/data/auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Auth()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(10), // space outside the green border
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2.0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SingleChildScrollView( // in case of small screens
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 190, 226, 255),
                      radius: 120,
                      child: Icon(
                        Icons.school,
                        size: 200,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'مرحبًا بك في تطبيقنا التعليمي',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.blue),
                    const Text(
                      'بـصـيــرتـي',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 60,
                        fontFamily: 'arab',
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const Divider(color: Colors.blue),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
