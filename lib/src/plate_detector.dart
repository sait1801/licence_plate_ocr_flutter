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

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    List<String> recognisedarray = recognizedText.text.split("\n");
    for (var arr in recognisedarray) {
      arr = arr.replaceAll(" ", "");
      if (arr.length == 7) {
        String num_part = arr.substring(0, 4);
        String str_part = arr.substring(4);
        if (_isNumeric(num_part)) {
          if (!(_isNumeric(str_part[0])) &&
              !(_isNumeric(str_part[1])) &&
              !(_isNumeric(str_part[2]))) {
            print("**********************************");
            print(arr);
            print("**********************************");

            if (await FireStoreHelper().checkPlates(recognizedText.text)) {
              FireStoreHelper().createPlate(recognizedText.text);
            } else {
              print("Plate Already Exist");
            }
          }
        }
        ;
      }
    }

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
      if (_text != null) {
        print("here");
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
