import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FireStoreHelper {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference platesReference =
      FirebaseFirestore.instance.collection("plates");

  Future<void> createPlate(String plate) async {
    try {
      await platesReference.doc(plate).set(
        {'plate_id': plate},
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> checkPlates(String plate) async {
    try {
      final platesSnapshot = await platesReference.doc(plate).get();
      if (platesSnapshot.exists != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
