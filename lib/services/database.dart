import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  getUserByUsername(String username) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .where("name", isEqualTo: username)
        .get();
  }

  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection("users").add(userMap);
  }
}
