import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:plate_recognition/src/firestore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'camera_view.dart';

var channel = WebSocketChannel.connect(
  Uri.parse('wss://ifelse.io'),
);

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

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    FireStoreHelper().createPlateMap();
    channel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(children: [
          CameraView(
            title: 'Text Detector',
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
          StreamBuilder(builder: ((context, snapshot) {
            return Positioned(
                top: 150,
                left: 200,
                child: SizedBox(
                  child: Text(
                    snapshot.hasData ? snapshot.data.toString() : 'None',
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ));
          })),
        ]),
      ),
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      // compute(sendImage, inputImage.bytes);
      await sendImage(inputImage.bytes);
    }
    _isBusy = false;
  }
}

Future<void> sendImage(Uint8List? bytes) async {
  String base64 = base64Encode(bytes!);
  print(base64);

  channel.sink.add(base64);
}
