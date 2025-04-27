import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:palette_generator/palette_generator.dart';

class ReconnaissanceCouleur extends StatefulWidget {
  @override
  _ReconnaissanceCouleurState createState() => _ReconnaissanceCouleurState();
}

class _ReconnaissanceCouleurState extends State<ReconnaissanceCouleur> {
  CameraController? cameraController;
  FlutterTts flutterTts = FlutterTts();
  String? imagepath;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    parler("انت في واجهة التعرف على الالوان اضغط على الشاشة لالتقاط الصورة");
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> parler(String text) async {
    await flutterTts.setSpeechRate(0.75);
    await flutterTts.setPitch(1.0); // Garde une voix naturelle
    await flutterTts.setVolume(1.0); // Volume au maximum
    await flutterTts.speak(text);
  }

  Future<void> prendrePhoto() async {
    try {
      final image = await cameraController!.takePicture();
      setState(() {
        imagepath = image.path;
      });
      print("Photo prise : ${image.path}");
      print("Photo prise2 : ${imagepath}");
      parler("تم التقاط الصورة");
      analyse_img(imagepath!);
    } catch (e) {
      print("Erreur lors de la capture : $e");
    }
  }

  Future analyse_img(String imgPath) async {
    final File imgfile = File(imgPath);
    final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
      FileImage(imgfile),
      maximumColorCount: 3,
    );
    List<Color> couleurs = palette.colors.toList();
    if (couleurs.isEmpty) {
      await parler("لم يتم التعرف على اي لون");
    } else {
      print("les couleur sont :");
      for (int i = 0; i < couleurs.length; i++) {
        print(
          "la couleur ${i + 1} est R=${couleurs[i].red} ,G=${couleurs[i].green} , B=${couleurs[i].blue} ",
        );
      }
      bool similaire = estSimilaire(couleurs);
      print("$similaire");
      if (similaire) {
        final nomCouleur = getColorName(couleurs[0]);
        parler("تم التعرف على اللون : $nomCouleur");
        print("coleur $nomCouleur");
      } else {
        List<String> nomcouleurs = [];
        for (int i = 0; i < 3; i++) {
          nomcouleurs.add(getColorName(couleurs[i]));
          await parler("تم التعرف على الالوان ${nomcouleurs.join(", ")}");
        }
      }
    }
  }

  double calculerDistance(Color c1, Color c2) {
    return sqrt(
      pow(c1.red - c2.red, 2) +
          pow(c1.green - c2.green, 2) +
          pow(c1.blue - c2.blue, 2),
    );
  }

  bool estSimilaire(List<Color> colors) {
    if (colors.length < 2) return true;
    for (int i = 0; i < colors.length - 1; i++) {
      if (calculerDistance(colors[i], colors[i + 1]) > 100) {
        return false;
      }
    }
    return true;
  }

  String getColorName(Color color) {
    int r = color.red;
    int g = color.green;
    int b = color.blue;

    // 🔴 ROUGE (de clair à foncé)
    if (r > 120 && g < 80 && b < 80) return "احمر";

    // 🟢 VERT (clair à foncé)
    if (g > 120 && r < 100 && b < 100) return "اخضر";

    // 🟡 JAUNE (de clair à foncé)
    if (r > 180 && g > 180 && b < 100) return "اصفر";

    // 🟠 ORANGE (de clair à foncé)
    if (r > 180 && g > 100 && g < 180 && b < 80) return "برتقالي";

    // 🔵 BLEU (de clair à foncé)
    if (b > 120 && r < 100 && g < 100) return "ازرق";

    // 🟣 VIOLET (de clair à foncé)
    if (r > 100 && b > 100 && g < 80) return "بنفسجي";

    // ⚫️ NOIR (de clair à foncé)
    if (r < 50 && g < 50 && b < 50) return "اسود";

    // ⚪️ BLANC (de clair à foncé)
    if (r > 200 && g > 200 && b > 200) return "ابيض";

    // 🟤 MARRON (de clair à foncé)
    if (r > 100 && g < 70 && b < 50) return "بني";

    // 🏾 BEIGE (de clair à foncé)
    if (r > 180 && g > 150 && b > 100) return "رملي فاتح";

    // 🔵🌙 BLEU NUIT (de clair à foncé)
    if (b > 100 && r < 50 && g < 50) return "ازرق داكن";

    // ⚪️ GRIS (de clair à foncé)
    if (r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200)
      return "رمادي";

    // 🎀 ROSE (de clair à foncé)
    if (r > 200 && g < 150 && b < 150) return "وردي";

    return "غير معروف";
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 169, 212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 208, 169, 212),
        title: Text(
          "التعرف على الالوان",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child:
                cameraController == null ||
                        !cameraController!.value.isInitialized
                    ? Center(child: CircularProgressIndicator())
                    : GestureDetector(
                      onTap: prendrePhoto,
                      child: CameraPreview(cameraController!),
                    ),
          ),
          if (imagepath != null) ...[
            SizedBox(height: 10),
            Center(
              child: Text(
                "الصورة :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Image.file(File(imagepath!), height: 200),
          ],
        ],
      ),
    );
  }
}
