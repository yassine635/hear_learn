import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/teacher_side/deposer.dart';

class Cour extends StatelessWidget {
  final VoidCallback onpressed;
  final VoidCallback realonpressed; // better type than just Function

  const Cour({
    Key? key,
    required this.onpressed,
    required this.realonpressed, 
  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple[600],
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 90,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            TextButton.icon(
              onPressed: realonpressed,
              label: Text(
                "cour",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              icon: Icon(Icons.book, size: 30, color: Colors.black),
            ),
            Deposer(onpressed: onpressed,),
          ],
        ),
      ),
    );
  }
}
