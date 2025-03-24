import 'package:flutter/material.dart';


class Module extends StatelessWidget {
  const Module({super.key, required this.module});
  final String module;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightGreenAccent,
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
            onPressed: () {
               Navigator.pushNamed(
                context,
                 "/contnu_module_teacher",
                 arguments: module
                 
              );
            },
            label: Text(
              module,
              style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              
              ),
            ),
            icon: Icon(Icons.folder,size: 30,color: Colors.black,),
          ),
        ),
      ),
    );
  }
}
