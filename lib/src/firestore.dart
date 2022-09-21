import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FireStoreHelper {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference platesReference =
      FirebaseFirestore.instance.collection("plates");

  List<String> plates = [];
  List<String> texts = [];

  Future<void> createPlate(String plate) async {
    try {
      await platesReference.doc(plate).set(
        {'plate_id': plate},
      );
      texts.add("$plate is created.");
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> checkPlates(String plate) async {
    try {
      if (plates.contains(plate)) {
        texts.add("$plate is already on memory");
      } else {
        final platesSnapshot = await platesReference.doc(plate).get();
        if (platesSnapshot.exists) {
          texts.add("$plate is already on database");
        } else {
          createPlate(plate);
          plates.add(plate);
        }
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
