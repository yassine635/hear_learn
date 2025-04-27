import 'package:flutter/material.dart';

class Deposer extends StatelessWidget {
  final VoidCallback onpressed; // better type than just Function

  const Deposer({
    super.key,
    required this.onpressed, // marked as required
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onpressed,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        "اضف",
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
        ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 213, 146, 255),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}
