import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/file_contaner.dart';

class Shou extends StatefulWidget {
  final String type;
  
  final List<String> filename;
  final List<String> fileids;
  const Shou({super.key, required this.type, required this.filename, required this.fileids, });

  @override
  State<Shou> createState() => _ShouCourState();
}

class _ShouCourState extends State<Shou> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[800],
        title: Text(
          widget.type,
          style: TextStyle(
            fontSize: 20,
            fontWeight:FontWeight.bold,
            color: Colors.white, 

          ),
        ),

      ),
      body: ListView.builder(
                      itemCount: widget.filename.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: FileContaner(file_name:widget.filename[index], file_id: widget.fileids[index],),
                          onTap: () {
                            
                          },
                        );
                      },
                    )
    );
  }
}
