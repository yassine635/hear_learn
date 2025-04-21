import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';

class TextToSpeechService {
  final FlutterTts tts = FlutterTts();

  // 1️⃣ Extract text directly from PDF using Syncfusion
  static  Future<String> extractTextFromPDF(File pdfFile) async {
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

  // 2️⃣ Fallback: Extract text using OCR on each page as image
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

  // 3️⃣ Convert text to WAV using FlutterTTS
  Future<String?> convertTextToSpeech(String text) async {
    try {
      final dir = await getApplicationDocumentsDirectory(); // Permanent folder
      final wavPath = '${dir.path}/output.wav';

      await tts.setLanguage("en");
      await tts.setSpeechRate(0.5);
      await tts.setPitch(1.0);

      await tts.synthesizeToFile(text, wavPath);

      final file = File(wavPath);
      if (await file.exists()) {
        print("✅ WAV file created: $wavPath");
        return wavPath;
      } else {
        print("❌ Failed to create WAV file.");
        return null;
      }
    } catch (e) {
      print("❌ TTS Error: $e");
      return null;
    }
  }

  // 4️⃣ Convert WAV to MP3 using FFmpeg
  Future<String?> convertWavToMp3(String wavPath) async {
    try {
      final mp3Path = wavPath.replaceAll('.wav', '.mp3');
      final command = '-i $wavPath -codec:a libmp3lame -qscale:a 2 $mp3Path';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final logs = await session.getAllLogsAsString();

      print("🔧 FFmpeg Log:\n$logs");

      if (returnCode != null && ReturnCode.isSuccess(returnCode)) {
        final mp3File = File(mp3Path);
        if (await mp3File.exists()) {
          print("✅ MP3 file created: $mp3Path");
          return mp3Path;
        } else {
          print("⚠️ MP3 file was not created!");
        }
      } else {
        print("❌ FFmpeg conversion failed. Code: $returnCode");
      }

      return null;
    } catch (e) {
      print("❌ MP3 conversion error: $e");
      return null;
    }
  }
}
