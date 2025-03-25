import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_text/pdf_text.dart';

class TextToSpeechService {
  final FlutterTts tts = FlutterTts();

  Future<String?> convertTextToSpeech(String text) async {
    try {
      // Get the temporary directory for saving the file
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/output.wav';

      // Speak and save the output as WAV (Check if your FlutterTTS supports this)
      await tts.synthesizeToFile(text, filePath);

      return filePath;  // Return the saved file path
    } catch (e) {
      return null;
    }
  }

  Future<String?> convertWavToMp3(String wavPath) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String mp3Path = '${tempDir.path}/output.mp3';

      // Convert WAV to MP3 using FFmpegKit
      await FFmpegKit.execute('-i $wavPath -codec:a libmp3lame $mp3Path');

      return mp3Path;  // Successfully converted to MP3
    } catch (e) {
      return null;
    }
  }

  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      final document = await PDFDoc.fromFile(pdfFile); // Load the PDF
      String extractedText = await document.text; // Extract text
      return extractedText.trim();
    } catch (e) {
      return "Error extracting text: $e";
    }
  }
}
