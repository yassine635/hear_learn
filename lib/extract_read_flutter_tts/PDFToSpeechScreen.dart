import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart' as pdf_render;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'dart:ui' as ui;

class Pdftospeechscreen extends StatefulWidget {
  final String downloader;
  const Pdftospeechscreen({super.key, required this.downloader});

  @override
  State<Pdftospeechscreen> createState() => _PdftospeechscreenState();
}

class _PdftospeechscreenState extends State<Pdftospeechscreen> {
  final FlutterTts tts = FlutterTts();
  bool isPlaying = false;
  bool isDownloading = true;
  String extractedText = "";
  double progress = 0.0;
  String status = "le début du téléchargement";

  // 🔁 For sentence-based playback
  List<String> textChunks = [];
  int currentChunkIndex = 0;

  @override
  void initState() {
    super.initState();
    textToSpeech();
  }

  List<String> splitTextIntoChunks(String text, int chunkSize) {
    List<String> chunks = [];
    int start = 0;

    while (start < text.length) {
      int end =
          (start + chunkSize < text.length) ? start + chunkSize : text.length;
      chunks.add(text.substring(start, end));
      start = end;
    }

    return chunks;
  }

  Future<String> downloaderTextExtractor() async {
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/temp.pdf';
      final dio = Dio();

      await dio.download(
        widget.downloader,
        savePath,
        onReceiveProgress: (count, total) {
          setState(() {
            progress = (count / total) * 100;
          });
        },
      );

      setState(() {
        status =
            "le telecharjement est terminer le fichier restera jusqu'à ce que vous quittiez cette page";
        isDownloading = false;
      });

      File pdfFile = File(savePath);
      String extracted = await extractTextFromPDF(pdfFile);
      if (extracted == "__USE_OCR__") {
        extracted = await extractTextUsingOCR(pdfFile);
      }
      return extracted;
    } catch (e) {
      print("❌ Download or extraction failed: $e");
      return "Erreur lors de l'extraction du texte.";
    }
  }

  Future<void> textToSpeech() async {
    extractedText = await downloaderTextExtractor();
    await detectGlobalLanguage(extractedText);
    textChunks = splitTextIntoChunks(extractedText, 200);

    currentChunkIndex = 0;

    setState(() {});
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
      return extractedText.trim().isEmpty
          ? "__USE_OCR__"
          : extractedText.trim();
    } catch (e) {
      return "__USE_OCR__";
    }
  }

  Future<String> extractTextUsingOCR(File pdfFile) async {
    String ocrExtractedText = "";
    final doc = await pdf_render.PdfDocument.openFile(pdfFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

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
  }

  Future<void> speakChunks() async {
    if (currentChunkIndex >= textChunks.length) {
      setState(() {
        isPlaying = false;
        currentChunkIndex = 0;
      });
      return;
    }

    await tts.setLanguage(detectedLang ?? "en-US");
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);

    await tts.speak(textChunks[currentChunkIndex]);

    tts.setCompletionHandler(() {
      if (isPlaying) {
        currentChunkIndex++;
        speakChunks();
      }
    });
  }

  Future<void> stop() async {
    await tts.stop();
  }

  String? detectedLang; 

  Future<void> detectGlobalLanguage(String fullText) async {
    final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    detectedLang = await languageIdentifier.identifyLanguage(fullText);
    print("Detected language: $detectedLang");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.purple[800],
        title: const Text(
          "text extraction",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (isPlaying) {
                await stop();
              }
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isDownloading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress / 100,
                          strokeWidth: 8,
                          color: Colors.white,
                        ),
                        Text(
                          '${progress.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      status,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 7,
                  child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        extractedText,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 100,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                        ),
                        onPressed: isDownloading
                            ? null
                            : () async {
                                if (isPlaying) {
                                  await stop();
                                  setState(() => isPlaying = false);
                                } else {
                                  setState(() => isPlaying = true);
                                  speakChunks();
                                }
                              },
                        icon: Icon(
                          isPlaying ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                        label: Text(
                          isPlaying ? "PAUSE" : "START",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
