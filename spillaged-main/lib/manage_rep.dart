// ignore_for_file: camel_case_types, non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:spillaged/main.dart';
import 'package:spillaged/employee.dart';
import 'package:spillaged/firebase.dart';
import 'package:spillaged/firebase_msg.dart';
import 'package:spillaged/global/common/toast.dart';
import 'package:url_launcher/link.dart';

class Manage_Reps extends StatefulWidget {
  const Manage_Reps({super.key});

  @override
  State<Manage_Reps> createState() => _Manage_RepsState();
}

class _Manage_RepsState extends State<Manage_Reps> {
  //completion date controller
  final _date = TextEditingController();

  //acessing the firebase class created
  repDatabase repData = repDatabase();

  //current logged in employee
  User? current_employee = FirebaseAuth.instance.currentUser;
  String? step = "Assessing Report";
  String save = "null";

  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
    //double screen_height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(80, 0, 0, 0),
            width: 3,
          ),
        ),
        //automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              if (save != "null") {
                setState(() {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text(
                              "Save Changes",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 2, 37, 66),
                                  fontWeight: FontWeight.bold),
                            ),
                            content: const SizedBox(
                                width: 350,
                                child: Text("Do yo want to save changes")),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const Employee_page()));
                                },
                                child: const Text(
                                  "No",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 2, 37, 66),
                                      fontSize: 13),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection("Reports")
                                      .doc(clicked)
                                      .update({"step": step});
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const Employee_page()));
                                },
                                child: const Text(
                                  "Yes",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 2, 37, 66),
                                      fontSize: 13),
                                ),
                              )
                            ],
                          ));
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: const Text(
          "Manage Report",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color.fromARGB(255, 2, 37, 66),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: repData.managereports(current_employee!.email!, clicked!),
        builder: (context, snapshot) {
          //get all reports
          final all_reps = snapshot.data?.docs;

          //no data
          if (snapshot.data == null || all_reps!.isEmpty) {
            return const Center(
              child: Text(
                "No assigned reports yet",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          }

          //return a list
          return ListView.builder(
            itemCount: all_reps.length,
            itemBuilder: (context, index) {
              //get the individual reports
              final rep = all_reps[index];

              //get the report ID
              String repID = rep.id;

              //get data from each report
              String date_time = rep["dateTime"];
              String location = rep["location"];
              String lvl = rep["u_level"];
              String repPic = rep["picture_url"];
              String report_status = rep["status"];
              String locationName = rep["locationName"];
              String device_token = rep["device_token"];
              String update = rep["step"];

              //return as a list tile

              return Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Report_Id",
                          style: TextStyle(
                              fontSize: screen_width < 400 ? 18 : 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          child: Text(
                            repID,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screen_width < 400 ? 16 : 18,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Image.network(
                          repPic,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Row(
                      children: [
                        Text(
                          "Location",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(150, 2, 37, 66),
                              width: 2),
                          color: const Color.fromARGB(60, 2, 37, 66),
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: Link(
                              target: LinkTarget.self,
                              uri: Uri.parse(
                                  "https://www.google.com/maps/search/?api=1&query=$location"),
                              builder: (context, followlink) => GestureDetector(
                                    onTap: followlink,
                                    child: SizedBox(
                                      //width: screen_width > 400 ? 250 : 150,
                                      child: Text(
                                        locationName,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromARGB(255, 2, 37, 66)),
                                      ),
                                    ),
                                  )),
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          "Urgency Level",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 55,
                          width: 150,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(150, 2, 37, 66),
                                  width: 2),
                              color: const Color.fromARGB(60, 2, 37, 66),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              children: [
                                Text(lvl),
                              ],
                            ),
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Progress Stage: ",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        // Text(update)
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              text: update,
                              style: const TextStyle(color: Colors.black)),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(150, 2, 37, 66),
                              width: 2),
                          color: const Color.fromARGB(60, 2, 37, 66),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: DropdownButton<String>(
                            underline: Container(),
                            icon: Padding(
                              padding: EdgeInsets.only(
                                  left: screen_width < 400 ? 40 : 150),
                              child: const Icon(
                                Icons.arrow_drop_down_circle_rounded,
                                color: Color.fromARGB(255, 2, 37, 66),
                                size: 30,
                              ),
                            ),
                            value: step,
                            items: const <String>[
                              "Assessing Report",
                              "Replacement parts ordered",
                              "Leakage being fixed"
                            ].map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(
                                  val,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              setState(() {
                                step = newVal;
                                save = newVal!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Row(
                      children: [
                        Text(
                          "Date Reported",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Container(
                          height: 55,
                          width: 150,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(150, 2, 37, 66),
                                  width: 2),
                              color: const Color.fromARGB(60, 2, 37, 66),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text(date_time)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 10, bottom: 10, top: 10, left: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: screen_width < 400 ? 140 : 150,
                            height: screen_width < 400 ? 46.5 : 56.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  foregroundColor: Colors.white,
                                  backgroundColor: report_status == "Rejected"
                                      ? const Color.fromARGB(100, 2, 37, 66)
                                      : const Color.fromARGB(255, 244, 67, 54)),
                              onPressed: report_status == "Complete"
                                  ? () {}
                                  : report_status == "Rejected"
                                      ? () {}
                                      : () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              String? reasons =
                                                  "Irrelevant report";
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      "Report Rejection",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromARGB(
                                                              255, 2, 37, 66)),
                                                    ),
                                                    content: SizedBox(
                                                      width: 350,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Container(
                                                              height: 55,
                                                              decoration: BoxDecoration(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      60,
                                                                      2,
                                                                      37,
                                                                      66),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Center(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child:
                                                                      DropdownButton<
                                                                          String>(
                                                                    underline:
                                                                        Container(),
                                                                    icon:
                                                                        Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left: screen_width < 400
                                                                              ? 40
                                                                              : 85),
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .arrow_drop_down_circle_rounded,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            2,
                                                                            37,
                                                                            66),
                                                                        size:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                    value:
                                                                        reasons,
                                                                    items:
                                                                        const <String>[
                                                                      "Irrelevant report",
                                                                      "Wrong location",
                                                                      "False information",
                                                                      "Leak already being fixed",
                                                                    ].map((String
                                                                            val) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            val,
                                                                        child:
                                                                            Text(
                                                                          val,
                                                                          style:
                                                                              const TextStyle(fontSize: 13),
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (newVal) {
                                                                      setState(
                                                                          () {
                                                                        reasons =
                                                                            newVal;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      2,
                                                                      37,
                                                                      66),
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _date.text =
                                                              "${DateFormat("dd-MM-yyyy").format(DateTime.now())} ${TimeOfDay.now().toString().substring(9)}";

                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "Reports")
                                                              .doc(repID)
                                                              .update({
                                                            "rejectDate":
                                                                _date.text,
                                                            "reject_reason":
                                                                reasons,
                                                            "status": "Rejected"
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                          Firebase_msg()
                                                              .sendNotification(
                                                                  "Report Rejection",
                                                                  "Report $repID has been rejected due to the following reason: $reasons",
                                                                  device_token);
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder: (BuildContext
                                                                          context) =>
                                                                      const Employee_page()));
                                                        },
                                                        child: const Text(
                                                          "Confirm",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      2,
                                                                      37,
                                                                      66),
                                                              fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                              child: report_status == "Rejected"
                                  ? const Text("Rejected")
                                  : const Text("Reject"),
                            ),
                          ),
                          SizedBox(
                            width: screen_width < 400 ? 140 : 150,
                            height: screen_width < 400 ? 46.5 : 56.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor: report_status == "Complete"
                                    ? const Color.fromARGB(255, 76, 175, 79)
                                    : const Color.fromARGB(255, 2, 37, 66),
                              ),
                              onPressed: report_status == "Complete"
                                  ? () {}
                                  : report_status == "Rejected"
                                      ? () {}
                                      : () {
                                          uploadImg(ImageSource.camera, repID,
                                              device_token);
                                        },
                              child: uploaded
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : report_status == "Complete"
                                      ? const Text("Completed")
                                      : const Text("Complete"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  XFile? compImg;
  bool uploaded = false;
  String? pathLoc;
  String? pathUrl;

  // methods of uploading images to firebase i.e the reports directory
  uploadImg(
    ImageSource src,
    String repID,
    String device_token,
  ) async {
    compImg = await ImagePicker().pickImage(source: src);
    if (compImg != null) {
      //loading animation while the image is being uploaded to the storage
      setState(() {
        uploaded = true;
      });
      return uploadImgToFirebase(File(compImg!.path), repID, device_token);
    }
  }

  Future uploadImgToFirebase(
      File image, String repID, String device_token) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      pathLoc = image.path.split("/").last;
      final uploadRef = storageRef.child("fixed/$pathLoc");
      await uploadRef.putFile(image);
      pathUrl = await uploadRef.getDownloadURL();
      setState(() {
        //ending the animation
        uploaded = false;
      });
      _date.text =
          "${DateFormat("dd-MM-yyyy").format(DateTime.now())} ${TimeOfDay.now().toString().substring(9)}";
      FirebaseFirestore.instance.collection("Reports").doc(repID).update({
        "completionDate": _date.text,
        "status": "Complete",
        "compImg": pathUrl
      });
      Firebase_msg().sendNotification(
          "Report Completion", "Report $repID has been fixed!!", device_token);
      Navigator.of(context).pop();
    } catch (e) {
      showToast(message: "$e");
    }
  }
}
