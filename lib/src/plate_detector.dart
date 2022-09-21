import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:plate_recognition/src/firestore.dart';
import 'camera_view.dart';

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
  int counter = 0;
  FireStoreHelper _fireStoreHelper = FireStoreHelper();

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    _fireStoreHelper.createPlateMap();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CameraView(
          title: 'Plate Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: (inputImage) {
            if (counter % 10 == 0) {
              // this will affect the performance of app
              processImage(inputImage);
              counter = 0;
            }
            counter++;
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
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      List<String> recognisedarray = recognizedText.text.split("\n");
      for (var arr in recognisedarray) {
        arr = arr.replaceAll(RegExp('[^A-Z0-9]'), '');
        if (arr.length == 7) {
          String numPart = arr.substring(0, 4);
          String strPart = arr.substring(4);
          if (_isNumeric(numPart)) {
            if (!(_isNumeric(strPart[0])) &&
                !(_isNumeric(strPart[1])) &&
                !(_isNumeric(strPart[2]))) {
              print("**********************************");
              print(arr);
              print("**********************************");
              _fireStoreHelper.checkPlates(arr.toLowerCase());
            }
          }
        }
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
