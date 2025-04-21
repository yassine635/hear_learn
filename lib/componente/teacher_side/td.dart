import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/teacher_side/deposer.dart'; 

class Td extends StatelessWidget {
 final VoidCallback onpressed; // better type than just Function

  const Td({
    Key? key,
    required this.onpressed, // marked as required
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightGreen[600],
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
              onPressed: () {},
              label: Text(
                "td",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
              icon: Icon(Icons.menu_book, size: 30, color: Colors.black),
            ),

            
            Deposer(onpressed: onpressed,),
          ],
        ),
      ),
    );
  }
}
