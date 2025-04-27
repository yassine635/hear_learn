import 'package:flutter/material.dart';

class Td extends StatelessWidget {
  final VoidCallback onpressed; 
  const Td({
    super.key,
    required this.onpressed, 
  });
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
            onPressed: () {},
            label: Text(
              "td",
              style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              
              ),
            ),
            icon: Icon(Icons.menu_book,size: 30,color: Colors.black,),
          ),
        ),
      ),
    );
  }
}
