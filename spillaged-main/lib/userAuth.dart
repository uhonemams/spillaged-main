// ignore_for_file: camel_case_types, non_constant_identifier_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spillaged/global/common/toast.dart';

class Firebase_Services {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> register_email_password(String email, String password) async {
    try {
      UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        showToast(message: "The email entered already exists.");
      } else {
        showToast(message: "An error occured: ${e.code}");
      }
    }
    return null;
  }

  Future<User?> login_email_password(String email, String password) async {
    try {
      UserCredential cred = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "channel-error") {
        showToast(message: "fill-in the missing spaces.");
      } else if (e.code == "invalid-credential") {
        showToast(message: "Invalid email or password.");
      } else {
        showToast(message: "An error occured: ${e.code}");
      }
    }
    return null;
  }
}
