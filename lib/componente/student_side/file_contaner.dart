import 'package:flutter/material.dart';
import 'package:hear_learn1/screanses/espace_student/extract_read_flutter_tts/PDFToSpeechScreen.dart';

class FileContaner extends StatelessWidget {
  final String file_name;
  final String file_id;

  const FileContaner({
    super.key,
    required this.file_name,
    required this.file_id,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: TextButton.icon(
            onPressed: () {
              Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Pdftospeechscreen(
            downloader: file_id ,
          ),
        ),
      );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.purple.shade400, width: 2),
              ),
            ),
            icon: Icon(Icons.picture_as_pdf, color: Colors.black),
            label: Text(
              file_name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
