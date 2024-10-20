// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spillaged/firebase_msg.dart';
import 'package:spillaged/landing_pg.dart';

//------------------global variables/methods/custom_widgets------------------------

String? clicked;
String? global_Password;

//a boolean variable that will be used to show that a picture is uploaded
bool is_uploaded = false;
bool is_verified = false;

// bool variable for loading animation
bool is_uploading = false;

//report status controller
String rep_status = "Submitted";

//string of showing an image from the firebase storage
String? device_token;
String? location;
String profileLoc = "hello";

//string variables of a path uses to delete an image from firebase storage
String? pathName;
String profilePath = "hello";

//file used to pick an image from the gallery
XFile? repImage;

//----------------------------------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "",
              appId: "",
              messagingSenderId: "",
              projectId: "",
              storageBucket: ""),
        )
      : await Firebase.initializeApp();
  await Firebase_msg().initialize_notifications();
  runApp(const SpillAged());
}

class SpillAged extends StatelessWidget {
  const SpillAged({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LandingPg(),
    );
  }
}
