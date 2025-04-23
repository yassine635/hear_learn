import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hear_learn1/STT_TTS/TTS.DART/TextToSpeechService.dart';

import 'package:share_plus/share_plus.dart';

class PDFToSpeechScreen extends StatefulWidget {
  const PDFToSpeechScreen({super.key});

  @override
  State<PDFToSpeechScreen> createState() => _PDFToSpeechScreenState();
}

class _PDFToSpeechScreenState extends State<PDFToSpeechScreen> {
  final TextToSpeechService ttsService = TextToSpeechService();
  String extractedText = "";
  bool isSpeaking = false;
  AudioPlayer? player;
  String? wavPathGlobal;

  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      // ✅ Call your function directly here
      final text = await TextToSpeechService.extractTextFromPDF(file);

      setState(() {
        extractedText = text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("📄 PDF Loaded and Text Extracted")),
      );
    }
  }

  Future<void> textToWav() async {
    if (extractedText.isNotEmpty) {
      wavPathGlobal = await ttsService.convertTextToSpeech(extractedText);
      print(wavPathGlobal);
      if (wavPathGlobal != null) {
        player = AudioPlayer();
        await player!.play(DeviceFileSource(wavPathGlobal!));
        setState(() => isSpeaking = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🔊 Playing WAV...")),
        );
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

  Future<void> togglePlayPause() async {
    if (player != null) {
      if (isSpeaking) {
        await player!.pause();
      } else {
        await player!.resume();
      }
      setState(() => isSpeaking = !isSpeaking);
    }
  }

  Future<void> stopPlayback() async {
    if (player != null) {
      await player!.stop();
      setState(() => isSpeaking = false);
    }
  }

  Future<void> shareWavFile() async {
    if (wavPathGlobal != null && File(wavPathGlobal!).existsSync()) {
      await Share.shareXFiles(
        [XFile(wavPathGlobal!)],
        text: "🎧 Check out this audio!",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ No WAV file to share")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📚 PDF to Speech"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: pickPDF,
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Pick PDF"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  extractedText.isNotEmpty
                      ? extractedText
                      : "No text extracted.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: textToWav,
              icon: Icon(Icons.volume_up),
              label: Text("Convert to WAV"),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: extractedText.isNotEmpty ? togglePlayPause : null,
              icon: Icon(isSpeaking ? Icons.pause : Icons.play_arrow),
              label: Text(isSpeaking ? "Pause" : "Play"),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: stopPlayback,
              icon: Icon(Icons.stop),
              label: Text("Stop"),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: shareWavFile,
              icon: Icon(Icons.share),
              label: Text("Share WAV"),
            ),
          ],
        ),
      ),
    );
  }
}
