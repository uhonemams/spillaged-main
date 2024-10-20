// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:spillaged/global/common/toast.dart';
import 'main.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
/////------------variables used for loading animation------------
  bool prof_upload = false;

  //-------------------------------------
  String? pic_url;
  String? pic_path;

//---------------Dectaring  and assigning Variables-------------------------

  final profileKey = GlobalKey<FormState>();

// methods of uploading images to firebase i.e the profile pic directory
  uploadPP(ImageSource src) async {
    final profilePic = await ImagePicker().pickImage(source: src);
    if (profilePic != null) {
      //loading animation while the image is being uploaded to the storage

      //print(profilePic.path);
      return uploadPPToFirebase(File(profilePic.path));
    }
  }

  Future uploadPPToFirebase(File image) async {
    try {
      setState(() {
        prof_upload = true;
      });

      final storageRef = FirebaseStorage.instance.ref();
      profilePath = image.path.split("/").last;
      final uploadRef = storageRef.child("profile/$profilePath");
      await uploadRef.putFile(image);
      //print("success");
      profileLoc = await uploadRef.getDownloadURL();
      //print(profileLoc);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(current_user!.email)
          .update({
        "profile_f_type": profilePath,
        "profile_url": profileLoc,
      });

      //ending the animation
      setState(() {
        prof_upload = false;
      });

      //Navigator.pop(context);
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const Profile()));
      showToast(message: "Image uploaded successfully!!");
    } catch (e) {
      showToast(message: "$e");
      //print(e);
    }
  }

//methods of deleting images in firebase storage that are in the profile_pic directory

  Future<void> deletePPImage(String path) async {
    final stg = FirebaseStorage.instance;
    Reference ref = stg.ref("profile/$path");
    try {
      await ref.delete();
      FirebaseFirestore.instance
          .collection("Users")
          .doc(current_user!.email)
          .update({
        "profile_f_type": "null",
        "profile_url": "null",
      });
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const Profile()));
      showToast(message: "Image removed successfully!!");
    } catch (e) {
      showToast(message: e.toString());
      //print(e);
    }
  }

  bool autofocus_ = false;

  //current logged in user
  User? current_user = FirebaseAuth.instance.currentUser;

  //method of fetching the user's data
  Future<DocumentSnapshot<Map<String, dynamic>>> get_user_data() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(current_user!.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(80, 0, 0, 0),
            width: 3,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_sharp)),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color.fromARGB(255, 2, 37, 66),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: get_user_data(),
        builder: (context, snapshot) {
          //when loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Lottie.asset(
                  'lottie_animation/Animation - 1720956624571.json',
                ),
              ),
            );
          }
          //if there is an error
          else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          //if data is received
          if (snapshot.hasData) {
            //extract the data
            Map<String, dynamic>? user = snapshot.data!.data();

            final profileName = TextEditingController(text: user!["name"]);
            final profileSurname = TextEditingController(text: user["surname"]);
            final profileDateBirth =
                TextEditingController(text: user["date_of_birth"]);
            final profilePhone = TextEditingController(text: user["phone"]);
            final profileEmail = TextEditingController(text: user["email"]);
            pic_url = user["profile_url"];
            pic_path = user["profile_f_type"];

            return SingleChildScrollView(
              child: Center(
                child: Form(
                  key: profileKey,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 40,
                        ),
                        Stack(children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color:
                                        const Color.fromARGB(255, 2, 37, 66)),
                                borderRadius: BorderRadius.circular(150)),
                            child: prof_upload == true
                                ? const Center(
                                    child: SizedBox(
                                      child: CircularProgressIndicator(
                                        color: Color.fromARGB(255, 2, 37, 66),
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(150),
                                    child: pic_url != "null"
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                            shape:
                                                                const Border(),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            content: SizedBox(
                                                              child:
                                                                  Image.network(
                                                                      pic_url!),
                                                            )));
                                              });
                                            },
                                            child: Image.network(
                                              pic_url!,
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset("images/blank_img.webp")),
                          ),
                          Positioned(
                            bottom: -9,
                            left: 61,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color:
                                      const Color.fromARGB(255, 250, 244, 250)),
                              child: IconButton(
                                onPressed: () {
                                  chooseMethod(context);
                                },
                                icon: const Icon(Icons.camera_alt),
                                iconSize: 30,
                                color: const Color.fromARGB(255, 2, 37, 66),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(
                          height: 40,
                        ),
                        Column(
                          children: [
                            const Center(
                              child: Text(
                                "Personal Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 2, 37, 66),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 350,
                              child: TextFormField(
                                controller: profileName,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r'^[a-z A-Z]+$')
                                          .hasMatch(value)) {
                                    return "Name entered doesn't exist";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: 'Name',
                                    suffix: IconButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("Users")
                                              .doc(current_user!.email)
                                              .update(
                                                  {"name": profileName.text});
                                          showToast(
                                              message:
                                                  "Name updated successfully!");
                                        },
                                        icon:
                                            const Icon(Icons.update_rounded))),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 350,
                              child: TextFormField(
                                controller: profileSurname,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r'^[a-z A-Z]+$')
                                          .hasMatch(value)) {
                                    return "Surname entered doesn't exist";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: 'Surname',
                                    suffix: IconButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection("Users")
                                              .doc(current_user!.email)
                                              .update({
                                            "surname": profileSurname.text
                                          });
                                          showToast(
                                              message:
                                                  "Surname updated successfully!");
                                        },
                                        icon:
                                            const Icon(Icons.update_rounded))),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 350,
                              child: TextFormField(
                                controller: profileDateBirth,
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                ),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Center(
                              child: Text(
                                "Contact Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 2, 37, 66),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 350,
                              child: TextFormField(
                                autofocus: autofocus_,
                                controller: profilePhone,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value!.isEmpty ||
                                      !RegExp(r'^(?:[+0]9)?[0-9]{10,12}$')
                                          .hasMatch(value)) {
                                    return "Invalid phone number";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                  suffix: IconButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("Users")
                                          .doc(current_user!.email)
                                          .update({"phone": profilePhone.text});
                                      showToast(
                                          message:
                                              "Phone number updated successfully!");
                                    },
                                    icon: const Icon(Icons.update_rounded),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: 350,
                              child: TextFormField(
                                controller: profileEmail,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                ),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }

  //--------------------choosing an option of uploading the image---------------

  void chooseMethod(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
    double screen_height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return SizedBox(
            width: screen_width,
            height: screen_height < 700 ? screen_height / 3 : screen_height / 4,
            child: Column(
              children: [
                SizedBox(
                  height: screen_height > 740 ? 30 : 15,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.highlight_remove,
                    size: 30,
                  ),
                  selectedColor: const Color.fromARGB(255, 2, 37, 66),
                  onTap: () {
                    if (pic_path != "null") {
                      deletePPImage(pic_path!);
                      Navigator.of(context).pop();
                    } else {
                      showToast(message: "There's no image uploaded");
                    }
                  },
                  title: const Text(
                    "Remove profile picture",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.image_outlined,
                    size: 30,
                  ),
                  onTap: () {
                    if (pic_path != "null") {
                      showToast(
                          message:
                              "Please remove the current uploaded image first");
                    } else {
                      uploadPP(ImageSource.gallery);
                    }
                    Navigator.of(context).pop();
                  },
                  selectedColor: const Color.fromARGB(255, 2, 37, 66),
                  title: const Text(
                    "Upload picture from Gallery",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    size: 30,
                  ),
                  onTap: () {
                    if (pic_path != "null") {
                      showToast(
                          message:
                              "Please remove the current uploaded image first");
                    } else {
                      uploadPP(ImageSource.camera);
                    }
                    Navigator.of(context).pop();
                  },
                  selectedColor: const Color.fromARGB(255, 2, 37, 66),
                  title: const Text(
                    "Upload a picture from camera",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
