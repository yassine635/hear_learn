import 'dart:io';
import 'dart:ui' as ui;

import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:path_provider/path_provider.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';

class TextToSpeechService {
  final FlutterTts tts = FlutterTts();

  Future<String> extractTextUsingOCR(File pdfFile) async {
    String ocrExtractedText = "";

    try {
      final doc = await pdf_render.PdfDocument.openFile(pdfFile.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);

      for (int i = 0; i < doc.pageCount; i++) {
        final page = await doc.getPage(i + 1);

        final pageImage = await page.render(
          width: page.width.toInt(),
          height: page.height.toInt(),
          fullWidth: page.width.toDouble(),
          fullHeight: page.height.toDouble(),
        );

        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/page_$i.png';
        final imageFile = File(filePath);

        final imageBytes = await pageImage.createImageDetached();
        final byteData =
            await imageBytes.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();
        await imageFile.writeAsBytes(pngBytes);

        final inputImage = InputImage.fromFilePath(imageFile.path);
        final recognizedText = await textRecognizer.processImage(inputImage);
        ocrExtractedText += recognizedText.text + "\n";
      }

      await textRecognizer.close();

      return ocrExtractedText.trim();
    } catch (e) {
      return "❌ OCR failed: $e";
    }
  }

  /*Future<String?> convertWavToMp3(String wavPath) async {
    try {
      final mp3Path = wavPath.replaceAll('.wav', '.mp3');
      final command = '-i $wavPath -codec:a libmp3lame -qscale:a 2 $mp3Path';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();

      print("🔧 FFmpeg Log:\n$logs");
      print("convertWavToMp3");
      print("the file path:$mp3Path");
      print("WAV path: $wavPath");
     print("Expected MP3 path: $mp3Path");
      if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
        final mp3File = File(mp3Path);

        if (await mp3File.exists()) {
          return mp3Path;
        } else {
          print("⚠️ MP3 file was not created!");
        }
      } else {
        print("❌ FFmpeg conversion failed. Return code: $returnCode");
      }

      return null;
    } catch (e) {
      print("❌ MP3 conversion error: $e");
      return null;
    }
  }*/

  Future<String?> convertWavToMp3(String wavPath) async {
  try {
    // 1. Check if the WAV file exists and is not empty
    final wavFile = File(wavPath);
    if (!(await wavFile.exists())) {
      print("❌ WAV file not found at: $wavPath");
      return null;
    }

    final wavSize = await wavFile.length();
    if (wavSize == 0) {
      print("❌ WAV file is empty. Cannot convert.");
      return null;
    }

   
    final mp3Path = wavPath.replaceAll('.wav', '.mp3');

    
    final command = '-y -i $wavPath -codec:a libmp3lame -qscale:a 2 $mp3Path';

   
    print("🎯 WAV path: $wavPath");
    print("🎯 MP3 path: $mp3Path");
    print("🔧 FFmpeg command: $command");

    
    final session = await FFmpegKit.execute(command);

    
    final logs = await session.getAllLogsAsString();
    print("🔧 FFmpeg Log:\n$logs");

    final returnCode = await session.getReturnCode();
    print("📢 FFmpeg return code: $returnCode");

    // 7. Check if the command was successful
    if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
      final mp3File = File(mp3Path);
      if (await mp3File.exists()) {
        print("✅ MP3 file successfully created at: $mp3Path");
        return mp3Path;
      } else {
        print("⚠️ MP3 file was not created.");
      }
    } else {
      print("❌ FFmpeg conversion failed.");
    }

    return null;
  } catch (e) {
    print("❌ MP3 conversion error: $e");
    return null;
  }
}




  Future<String?> convertTextToSpeech(String text) async {
    try {
      // Prepare output path
      final dir = await getTemporaryDirectory();
      final wavPath = '${dir.path}/output.wav';

      print("📁 Output WAV path: $wavPath");

      // Set TTS settings
      await tts.setLanguage("ar");
      await tts.setSpeechRate(0.5);
      await tts.setPitch(1.0);
      await tts.awaitSynthCompletion(true); // Important for file saving!

      
      

      // Wait a moment to ensure file write
      await Future.delayed(Duration(seconds: 1));

      final file = File(wavPath);

      if (await file.exists()) {
        print("✅ WAV file created successfully");
        return wavPath;
      } else {
        print("❌ WAV file not found at: $wavPath");
        return null;
      }
    } catch (e) {
      print("❌ Error converting text to WAV: $e");
      return null;
    }
  }


  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      final document = syncfusion.PdfDocument(
        inputBytes: pdfFile.readAsBytesSync(),
      );

      String extractedText = "";

      for (int i = 0; i < document.pages.count; i++) {
        final text = syncfusion.PdfTextExtractor(document)
            .extractText(startPageIndex: i, endPageIndex: i);
        extractedText += text + "\n";
      }

      document.dispose();

      if (extractedText.trim().isEmpty) {
        return "__USE_OCR__"; // Signal to use OCR
      }

      return extractedText.trim();
    } catch (e) {
      print("❌ PDF text extraction failed: $e");
      return "__USE_OCR__";
    }
  }
 
}
