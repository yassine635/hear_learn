import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

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
  try {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    _cameraController = CameraController(backCamera, ResolutionPreset.high);

    await _cameraController!.initialize();
    setState(() => _isCameraInitialized = true);
  } on CameraException catch (e) {
    await tts.speak("لا يمكن فتح الكاميرا. تأكد من إعطاء الصلاحيات");
    print("Camera error: $e");
  }
}


  void _initTTS() {
    tts.setLanguage("ar-AR");
    tts.setSpeechRate(0.7);
    tts.setVolume(1.0);
    tts.setPitch(1.0);
    tts.speak("الكاميرا مفتوحة. اضغط على الشاشة لالتقاط صورة.");
  }

  Future<void> _takePictureAndAnalyze() async {
    if (!_isCameraInitialized || _cameraController!.value.isTakingPicture) return;

    final _ = await getTemporaryDirectory();
    final file = await _cameraController!.takePicture();
    final imageFile = File(file.path);

    final detectedText = await _detectText(imageFile);
    String billet = _analyzeBillet(detectedText);

    if (billet == 'أعد المحاولة') {
      final colorName = await getDominantColorName(imageFile);
      if (colorName == 'رمادي') {
        billet = '١٠٠٠ دينار';
      } else if (colorName == 'أزرق') {
        billet = '٥٠٠ دينار';
      } else if (colorName == 'أخضر') {
        billet = '٢٠٠٠ دينار';
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

  String convertArabicToEnglishNumbers(String input) {
    const arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    for (int i = 0; i < arabicDigits.length; i++) {
      input = input.replaceAll(arabicDigits[i], i.toString());
    }
    return input;
  }

  String _analyzeBillet(String text) {
    final lowerText = text.toLowerCase();
    final convertedText = convertArabicToEnglishNumbers(lowerText);
    final cleanText = convertedText.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanText.contains('2000')) return '٢٠٠٠ دينار';
    if (cleanText.contains('1000') || lowerText.contains('1000') || lowerText.contains('الف')) {
      return '١٠٠٠ دينار';
    }
    if (cleanText.contains('500') || lowerText.contains('500') || lowerText.contains('خمسمائة')) {
      return '٥٠٠ دينار';
    }

    // Extra Arabic word fallback
    if (lowerText.contains('دينار')) {
      if (lowerText.contains('الفين') || lowerText.contains('٢٠٠٠')) return '٢٠٠٠ دينار';
      if (lowerText.contains('الف') || lowerText.contains('١٠٠٠')) return '١٠٠٠ دينار';
      if (lowerText.contains('خمسمائة') || lowerText.contains('٥٠٠')) return '٥٠٠ دينار';
    }

    return 'أعد المحاولة';
  }

  Future<String> getDominantColorName(File imageFile) async {
    final palette = await PaletteGenerator.fromImageProvider(
      FileImage(imageFile),
      maximumColorCount: 5,
    );
    final List<Color> colors = palette.colors.toList();
    if (colors.isEmpty) return 'غير معروف';

    final color = colors[0];
    final r = color.red, g = color.green, b = color.blue;

   
    if (b > r && b > g) return 'أزرق';
    if (g > r && g > b) return 'أخضر';

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
          title: const Text(
            "التعرف على المال",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.purple[800],
        ),
        body: _isCameraInitialized
            ? Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _takePictureAndAnalyze,
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
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
