import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hear_learn1/STT_TTS/flutter/TextToSpeechService.dart';


class PDFToSpeechScreen extends StatefulWidget {
  @override
  _PDFToSpeechScreenState createState() => _PDFToSpeechScreenState();
}

class _PDFToSpeechScreenState extends State<PDFToSpeechScreen> {
  final TextToSpeechService ttsService = TextToSpeechService();
  String extractedText = "";
  String? savedFilePath;

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File pdfFile = File(result.files.single.path!);
      String text = await ttsService.extractTextFromPDF(pdfFile);
      setState(() {
        extractedText = text;
      });
    }
  }

  Future<void> textToMp3() async {
    if (extractedText.isNotEmpty) {
      String? wavPath = await ttsService.convertTextToSpeech(extractedText);
      if (wavPath != null) {
        String? mp3Path = await ttsService.convertWavToMp3(wavPath);
        if (mp3Path != null) {
          setState(() {
            savedFilePath = mp3Path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("MP3 saved at: $mp3Path")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF to Speech")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickPDF,
              child: Text("Pick PDF"),
            ),
            SizedBox(height: 20),
            extractedText.isNotEmpty
                ? Expanded(child: SingleChildScrollView(child: Text(extractedText)))
                : Text("No text extracted"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: textToMp3,
              child: Text("Convert to MP3"),
            ),
          ],
        ),
      ),
    );
  }
}
