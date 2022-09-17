import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:plate_recognition/src/firestore.dart';
import 'package:plate_recognition/src/painter.dart';

import 'camera_view.dart';
import 'painter.dart';

class TextRecognizerView extends StatefulWidget {
  // FirebaseCrud _firebseCrud = FirebaseCrud();
  @override
  _TextRecognizerViewState createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CameraView(
          title: 'Text Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: (inputImage) {
            processImage(inputImage);
          },
        ),
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
      print("here=====================================================");
      print(recognizedText.text);
      await FireStoreHelper().createPlate(recognizedText.text);
    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      _customPaint = null;
      if (_text != null) {
        print("here=====================================================");
        print(recognizedText.text);
        await FireStoreHelper().createPlate(recognizedText.text);

        // if (await FireStoreHelper().checkPlates(recognizedText.text)) {
        //  await  FireStoreHelper().createPlate(recognizedText.text);
        // } else {
        //   print("Plate Already Exist");
        // }
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
