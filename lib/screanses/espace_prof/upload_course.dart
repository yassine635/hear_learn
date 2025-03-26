import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
 // Import your AppWriteService

class UploadCourse extends StatefulWidget {
  @override
  _UploadCourseState createState() => _UploadCourseState();
}

class _UploadCourseState extends State<UploadCourse> {
  PlatformFile? selectedFile;
  

  // Pick a file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true, // Important for cloud uploads
    );

    if (result != null) {
      setState(() {
        selectedFile = result.files.single;
      });
      print("File selected: ${selectedFile!.name}");
    } else {
      print("No file selected");
    }
  }

  // Upload file using AppWriteService
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        title: Text("Upload file"),
        backgroundColor: Colors.lightGreen[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 100, color: Colors.black),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: Icon(Icons.folder_open, color: Colors.black),
              label: Text("Select File",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.lightGreen[700],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:(){} ,
              icon: Icon(Icons.cloud_upload, color: Colors.black),
              label: Text("Upload File",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
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
