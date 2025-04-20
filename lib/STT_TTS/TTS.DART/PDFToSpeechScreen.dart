import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:hear_learn1/STT_TTS/TTS.DART/TextToSpeechService.dart';

class PDFToSpeechScreen extends StatefulWidget {
  @override
  _PDFToSpeechScreenState createState() => _PDFToSpeechScreenState();
}

class _PDFToSpeechScreenState extends State<PDFToSpeechScreen> {
  final TextToSpeechService ttsService = TextToSpeechService();
  String extractedText = "";
  String? savedFilePath;
  bool isSpeaking = false;

  Future<void> togglePlayPause() async {
    if (isSpeaking) {
      await ttsService.tts.pause();
      setState(() => isSpeaking = false);
    } else {
      await ttsService.tts.setSpeechRate(0.4);
      await ttsService.tts.setPitch(1.2);
      await ttsService.tts.speak(extractedText);
      setState(() => isSpeaking = true);
    }
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File pdfFile = File(result.files.single.path!);
      String text = await ttsService.extractTextFromPDF(pdfFile);

      if (text == "__USE_OCR__") {
        // Show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("📷 This file is scanned. Using OCR. Please wait...")),
        );

        // 👇 Call your OCR method here
        text = await ttsService.extractTextUsingOCR(pdfFile);
      }
      print("theextracted text:$extractedText");
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
        print(mp3Path);
        if (mp3Path != null) {
          final player = AudioPlayer();
          await player.play(DeviceFileSource(mp3Path));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🎧 Playing MP3...")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("⚠️ Failed to convert to MP3")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Failed to generate WAV file")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❗No text to convert")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF to Speech")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: pickPDF,
                child: Text("Pick PDF"),
              ),
              SizedBox(height: 20),
              extractedText.isNotEmpty
                  ? Expanded(
                      child: SingleChildScrollView(child: Text(extractedText)))
                  : Text("No text extracted"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: textToMp3,
                child: Text("Convert to MP3"),
              ),
              ElevatedButton.icon(
                onPressed: extractedText.isNotEmpty ? togglePlayPause : null,
                icon: Icon(isSpeaking ? Icons.pause : Icons.play_arrow),
                label: Text(isSpeaking ? "Pause" : "Play"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
