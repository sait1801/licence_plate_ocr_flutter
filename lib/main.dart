import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plate_recognition/src/plate_detector.dart';
import 'package:plate_recognition/src/trial.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  cameras = await availableCameras();

  runApp(TextRecognizerView());
  // runApp(MyApp());
}
