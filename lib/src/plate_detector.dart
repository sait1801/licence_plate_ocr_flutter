import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'camera_view.dart';

import 'package:http/http.dart' as http;

WebSocketChannel channel =
    IOWebSocketChannel.connect("wss://cheque-price.herokuapp.com/uploader");

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

  // @override
  // void initState() {
  //   super.initState();
  //   // channel = WebSocketChannel.connect(
  //   //   Uri.parse('ws://http://138.68.181.111/'),
  //   // );

  //   WebSocketChannel channel =
  //       IOWebSocketChannel.connect("ws://http://138.68.181.111/");
  // }

  @override
  Widget build(BuildContext context) {
    String? titlebar = '';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(children: [
          CameraView(
            title: 'Text Detector',
            customPaint: _customPaint,
            text: _text,
            onImage: (inputImage) {
              if (counter % 5 == 0) {
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
              print("hello");
              print('connectionstate:${snapshot.connectionState}');
              print(snapshot.error);

              return Positioned(
                top: 150,
                left: 0,
                child: SizedBox(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      snapshot.hasData
                          ? snapshot.data.toString()
                          : snapshot.error.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              );
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
      sendImage(inputImage.bytes);
    }
    _isBusy = false;
  }
}

Future<void> sendImage(Uint8List? bytes) async {
  // String base64 = base64Encode(bytes!);
  // var image = MemoryImage(bytes!);

  var pic = http.MultipartFile.fromBytes('file', bytes!);

  // channel.sink.add(pic);

  print(bytes!.first.toString());

  // Directory tempdirectory = await getTemporaryDirectory();
  // var file = File('${tempdirectory.path}/temp');
  // file.writeAsBytesSync(bytes);
  // var request = http.MultipartRequest(
  // "POST", Uri.parse("https://cheque-price.herokuapp.com/uploader"));
  //add text fields
  //create multipart using filepath, string or bytes
  // var pic = await http.MultipartFile.fromPath("imagefile", file.path);
  //add multipart to request
  // request.files.add(pic);
  // channel.sink.add(request);
  channel.sink.add(pic);
}
