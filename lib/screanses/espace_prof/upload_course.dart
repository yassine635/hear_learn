import 'package:flutter/material.dart';


class UploadCourse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        title: Text("Upload file "),
        backgroundColor: Colors.lightGreen[800],
        ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 100, color: Colors.black,),
            SizedBox(height: 20),

            // Select File Button
            ElevatedButton.icon(
              onPressed: () {}, // No backend logic for now
              icon: Icon(Icons.folder_open,color: Colors.black,),
              label: Text(
                "Select File",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
                  ),
                ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.lightGreen[700],
              ),
            ),
            SizedBox(height: 20),

            // Upload File Button
            ElevatedButton.icon(
              onPressed: () {}, // No backend logic for now
              icon: Icon(Icons.cloud_upload,color: Colors.black,),
              label: Text(
                "Upload File",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
                   ),
                  ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.lightGreen[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
