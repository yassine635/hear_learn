import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';

class Cour extends StatelessWidget {
  final VoidCallback onpressed;

  const Cour({
    super.key,
    required this.onpressed, // marked as required
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Cheker.second_color,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: 90,
      child: Align(
        alignment: Alignment.center,  // Align to the right for RTL
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextButton.icon(
            
            onPressed: onpressed,
            label: Text(
              "الدروس",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold
              ),
            ),
            icon: Icon(
              Icons.book,
              size: 30,
              color: Colors.black,
            ),
            // Change text direction to RTL
            style: ElevatedButton.styleFrom(
              
              textStyle: TextStyle(
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
