import 'package:flutter/material.dart';

class FileContaner extends StatelessWidget {
  final String file_name;
  const FileContaner({super.key, required this.file_name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.purple[400],
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 80,
        child: Center(
          child: Text(
            file_name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
