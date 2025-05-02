import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/teacher_side/deposer.dart';
import 'package:hear_learn1/data/cheker.dart'; 

class Td extends StatelessWidget {
 final VoidCallback onpressed; // better type than just Function
 final VoidCallback realonpressed;
  const Td({
    super.key,
    required this.onpressed, required this.realonpressed, // marked as required
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
           
            TextButton.icon(
              onPressed: realonpressed,
              label: Text(
                "اعمال موجهة",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
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
