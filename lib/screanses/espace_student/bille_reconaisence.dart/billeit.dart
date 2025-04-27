import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
// ignore: unused_import
import 'package:path/path.dart';

class ReconBillet extends StatefulWidget {
  const ReconBillet({super.key});

  @override
  State<ReconBillet> createState() => _ReconBilletState();
}

class _ReconBilletState extends State<ReconBillet> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final FlutterTts tts = FlutterTts();
  String _resultText = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initTTS();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    _cameraController = CameraController(backCamera, ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() => _isCameraInitialized = true);
  }

  void _initTTS() {
    tts.setLanguage("ar-AR");
    tts.setSpeechRate(0.7);
    tts.setVolume(1.0);
    tts.setPitch(1.0);
    tts.speak("الكاميرا مفتوحة. اضغط على الشاشة لالتقاط صورة.");
  }

  Future<void> _takePictureAndAnalyze() async {
    if (!_isCameraInitialized || _cameraController!.value.isTakingPicture) {
      return;
    }

    final _ = await getTemporaryDirectory();
    final file = await _cameraController!.takePicture();
    final imageFile = File(file.path);

    final detectedText = await _detectText(imageFile);
    String billet = _analyzeBillet(detectedText);

    if (billet == 'أعد المحاولة') {
      final colorName = await getDominantColorName(imageFile);
      if (colorName == 'رمادي') {
        billet = '1000 دينار';
      }
    }

    setState(() {
      _resultText = billet;
    });

    await tts.speak(billet);
  }

  Future<String> _detectText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  String _analyzeBillet(String text) {
    final lowerText = text.toLowerCase();
    final cleanText = text.replaceAll(RegExp(r'\D'), '');

    if (cleanText.contains('2000')) return '2000 دينار';
    if (cleanText.contains('1000') ||
        cleanText.contains('100') ||
        lowerText.contains('الف دينار')) {
      return '1000 دينار';
    }
    if (cleanText.contains('500') || lowerText.contains('خمسمائة دينار')) {
      return '500 دينار';
    }

    if (lowerText.contains('دينار')) {
      if (lowerText.contains('الفين')) return '٢٠٠٠ دينار';
      if (lowerText.contains('الف')) return '١٠٠٠ دينار';
      if (lowerText.contains('خمسمائة')) return '٥٠٠ دينار';
    }

    return 'أعد المحاولة';
  }

  Future<String> getDominantColorName(File imageFile) async {
    final palette = await PaletteGenerator.fromImageProvider(
      FileImage(imageFile),
      maximumColorCount: 3,
    );
    final List<Color> colors = palette.colors.toList();
    if (colors.isEmpty) return 'غير معروف';

    final color = colors[0];
    final r = color.red, g = color.green, b = color.blue;

    if (r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200) {
      return 'رمادي';
    }

    return 'غير معروف';
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 253, 239, 255),
        appBar: AppBar(
          title: Text("reconnaissance de billets",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),),
          backgroundColor: Colors.purple[800],
        ),
        
          body: _isCameraInitialized
            ? Stack(
                children: [
                  // Make CameraPreview fill the available space
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _takePictureAndAnalyze,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                  // Show result text in center if available
                  if (_resultText.isNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _resultText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
