import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';
import 'package:hear_learn1/screanses/espace_student/filemanegment_cour_td_tp/contnue_module_student.dart';

class Module extends StatelessWidget {
  const Module({super.key, required this.module});
  final String module;
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
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Contnue_Module_Student(module:module ,), 
                ),
              );
            },
            label: Text(
              module,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            icon: Icon(
              Icons.folder,
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
