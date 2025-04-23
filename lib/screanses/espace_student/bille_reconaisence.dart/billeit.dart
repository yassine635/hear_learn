import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hear_learn1/home/fonctionalite_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:palette_generator/palette_generator.dart';
 
class ReconBillet extends StatefulWidget {
  const ReconBillet({super.key});
 
  @override
  _ReconBilletState createState() => _ReconBilletState();
}
 
class _ReconBilletState extends State<ReconBillet> {
  File? _image;
  String _result = '';
  final FlutterTts tts = FlutterTts();
 
  @override
  void initState() {
    super.initState();
    tts.setLanguage("ar");
    tts.setSpeechRate(0.7);
    tts.setVolume(1.0);
    tts.setPitch(1.0);
 
    tts.speak(
      " مرحبًا بك. التقط صورة للتعرف على العملة. أنقر على الزر في الأسفل .إذا أردت الرجوع أنقر على اليمين في أعلى الشاشة",
    );
  }
 
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    await tts.speak(
      "ثبت الصورة لإلتقاطها، ثم اضغط على الجهة اليمنى من أسفل الشاشة",
    );
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
 
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final detectedText = await _detectText(imageFile);
      String billet = _analyzeBillet(detectedText);
 
      // 🚩 إذا لم يتم التعرف على "١٠٠٠ دينار" من النص، تحقق من اللون
      if (billet == 'أعد المحاولة') {
        final colorName = await getDominantColorName(imageFile);
        if (colorName == 'رمادي') {
          billet = '1000 دينار';
        }
      }
 
      setState(() {
        _image = imageFile;
        _result = billet;
      });
 
      await tts.speak(billet);
    }
  }
 
  Future<String> _detectText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    await textRecognizer.close();
    return recognizedText.text;
  }
 
  String _analyzeBillet(String text) {
    final lowerText = text.toLowerCase();
    final cleanText = text.replaceAll(RegExp(r'\D'), '');
 
    if (cleanText.contains('2000') || cleanText.contains('200'))
      return '2000 دينار';
    if (cleanText.contains('1000') ||
        cleanText.contains('100') ||
        lowerText.contains('الف دينار'))
      return '1000 دينار';
    if (cleanText.contains('500') ||
        cleanText.contains('50') ||
        lowerText.contains('خمسمائة دينار'))
      return '500 دينار';
 
    // if (cleanText.contains('100')) return '١٠٠ دينار';
    // if (cleanText.contains('50')) return '٥٠ دينار';
    //if (cleanText.contains('20')) return '٢٠ دينار';
    //if (cleanText.contains('10')) return '١٠ دينار';
    //if (cleanText.contains('5')) return '٥ دينار';
 
    if (lowerText.contains('دينار')) {
      if (lowerText.contains('الفين') && lowerText.contains('دينار'))
        return '٢٠٠٠ دينار';
      if (lowerText.contains('الف') && lowerText.contains('دينار'))
        return '١٠٠٠ دينار';
      if (lowerText.contains('خمسمائة') && lowerText.contains('دينار'))
        return '٥٠٠ دينار';
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
 
    if (r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200)
      return 'رمادي';
 
    return 'غير معروف';
  }
 
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text("التعرف على العملة"),
            backgroundColor: const Color.fromARGB(255, 204, 73, 227),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Fonctionalite(),
                  ),
                );
              },
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_image != null) Image.file(_image!, height: 200),
                const SizedBox(height: 20),
                Text(_result, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 300),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 158, 103, 150),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 4.0,
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("📷 فتح الكاميرا"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}