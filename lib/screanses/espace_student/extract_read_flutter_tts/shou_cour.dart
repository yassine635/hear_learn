import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/file_contaner.dart';

class ShouCour extends StatefulWidget {
  final String type;
 
  final List<String> filename;
  const ShouCour({super.key, required this.type, required this.filename});

  @override
  State<ShouCour> createState() => _ShouCourState();
}

class _ShouCourState extends State<ShouCour> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                          title: FileContaner(file_name:widget.filename[index],),
                          onTap: () {
                            
                          },
                        );
                      },
                    )
    );
  }
}
