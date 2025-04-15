import 'package:flutter/material.dart';
import 'upload_course.dart';

class TeacherDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Teacher interface"),
        backgroundColor: Colors.lightGreen[800],
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
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  "/_PDFToSpeechScreenState"
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
                backgroundColor: Colors.lightGreen[700],
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
                backgroundColor: Colors.lightGreen[700],
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
