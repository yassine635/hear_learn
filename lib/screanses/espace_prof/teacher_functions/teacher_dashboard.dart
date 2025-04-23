import 'package:flutter/material.dart';
import 'upload_course.dart';

class TeacherDashboard extends StatelessWidget {
  final String type;
  TeacherDashboard({required this.type});
  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final List data = args as List;
    final String type = data[0];
    final String module = data[1];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Teacher interface ",
        style: TextStyle(
          fontSize: 24,
          color: Colors.white
          ),
        ),
        backgroundColor: Colors.purple[800],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, Teacher!",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Row(
              children: [
                SizedBox(width: 60,),
                Expanded(
                  child: Text(
                    "uploade to $module,$type",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                SizedBox(width: 60,),
              ],
            ),
            
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UploadCourse(module_name: module),
                    ),
                );
              },
              icon: Icon(Icons.upload_file,color: Colors.black,),
              label: Text(
                "Upload file",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
                  ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 70),
                backgroundColor: Colors.purple[600],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.library_books,color: Colors.black,),
              label: Text(
                "Manage Courses(modifié)",
                  style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
                  ),
                ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 70),
                backgroundColor: Colors.purple[600],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
