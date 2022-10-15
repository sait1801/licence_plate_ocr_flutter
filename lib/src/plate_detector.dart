import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'camera_view.dart';

late var channel;

class TextRecognizerView extends StatefulWidget {
  const TextRecognizerView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TextRecognizerViewState createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  int counter = 0;

  @override
  void dispose() {
    _canProcess = false;
    channel.sink.close();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.ifelse.io/'),
    );
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
          StreamBuilder(
            stream: channel.stream,
            builder: ((context, snapshot) {
              print('connectionstate:${snapshot.connectionState}');
              print(snapshot.data);
              return Positioned(
                  top: 150,
                  left: 0,
                  child: SizedBox(
                    child: Text(
                      snapshot.hasData
                          ? snapshot.data.toString()
                          : snapshot.connectionState.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ));
            }),
          ),
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
      sendImage(inputImage.bytes);
    }
    _isBusy = false;
  }
}

void sendImage(Uint8List? bytes) {
  String base64 = base64Encode(bytes!);

  channel.sink.add(base64);
}
