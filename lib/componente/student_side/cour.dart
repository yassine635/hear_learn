import 'package:flutter/material.dart';

class Cour extends StatelessWidget {
  
  final VoidCallback onpressed; 

  const Cour({
    Key? key,
    required this.onpressed, // marked as required
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple[400],
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 90,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextButton.icon(
            onPressed: onpressed,
            label: Text(
              "cour",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
              ),
            ),
            icon: Icon(
              Icons.book,
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
