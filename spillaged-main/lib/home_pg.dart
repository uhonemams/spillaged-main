// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names, prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:spillaged/educationalCont.dart';
import 'package:spillaged/firebase.dart';
import 'package:spillaged/global/common/toast.dart';
import 'package:spillaged/landing_pg.dart';
import 'package:spillaged/userSubmittedreps.dart';
import 'package:spillaged/user_comp_reps.dart';
import 'package:spillaged/user_inprogress.dart';
import 'package:spillaged/user_rejected_reps.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/link.dart';
import 'profile_pg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart'
    // ignore: library_prefixes
    as mapMarker;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'main.dart';
import 'package:geocoding/geocoding.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //String variable for the report variable that makes sure that the documents are not the same
  String? repID;
  List<String> IDs = [];

//list of all the locations that were reported to have a water leak
//-----------------used to check if a user is adding a report of an area that has been reported already--------
  List<String> locations = [];

//getting all the report locations from the database
  void getReportLocation() async {
    // Reference to the Firestore collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("Reports");

    try {
      // Query the collection to get all documents
      QuerySnapshot querySnapshot = await collectionRef
          .where("status", whereNotIn: ["Complete", "Rejected"]).get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        //loop through all the documents in the snapshot

        for (QueryDocumentSnapshot docsnapshot in querySnapshot.docs) {
          //retrive the value from the location field
          String _location = docsnapshot.get("location");
          //add the location to the list
          locations.add(_location);
        }
        // Print the value or use it in your application
        //print("Retrieved locations: $locations");
      } else {
        //print("No documents found");
      }
    } catch (e) {
      showToast(message: e.toString());
      //print("Error getting document: $e");
    }
  }

  int rejected = 0;
  int inProgress = 0;
  int submitted = 0;
  int _counter = 0;
  int _attended = 0;
  int _total = 0;
  int _points = 0;

  //get the total number of reports that a user rejected
  get_num_rejected() async {
    final count = await FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: current_user!.email!)
        .where("status", isEqualTo: "Rejected")
        .get();

    setState(() {
      rejected = count.size;
    });
  }

  //get the total number of reports that a user in progress
  get_num_inProgress() async {
    final count = await FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: current_user!.email!)
        .where("status", isEqualTo: "In Progress")
        .get();

    setState(() {
      inProgress = count.size;
    });
  }

//get the total number of reports that a user submitted
  get_num_submitted() async {
    final count = await FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: current_user!.email!)
        .where("status", isEqualTo: "Submitted")
        .get();

    setState(() {
      submitted = count.size;
    });
  }

//method of getting the number of reports

  get_num() async {
    final count = await FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: current_user!.email!)
        .get();

    setState(() {
      _counter = count.size;
    });
  }

  //method of getting the number of reports that are completed
  get_num_attended() async {
    final count = await FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: current_user!.email!)
        .where("status", isEqualTo: "Complete")
        .get();

    setState(() {
      _attended = count.size;
      _points = _attended * 10;
    });
  }

//get the total number of reports that are completed in the database regardless of the user
  get_total() async {
    final count = await FirebaseFirestore.instance
        .collection("Reports")
        .where("status", isEqualTo: "Complete")
        .get();

    setState(() {
      _total = count.size;
    });
  }

  //aading report loading animation controller
  bool is_added = false;
  //access to the fireStore class
  final repDatabase repData = repDatabase();

  //current logged in user
  User? current_user = FirebaseAuth.instance.currentUser;

  //method of fetching the user's data
  Future<DocumentSnapshot<Map<String, dynamic>>> get_user_data() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(current_user!.email)
        .get();
  }

//---------------Text editing controller for the input box of date-------------------

  final _date = TextEditingController();

//---------method of making the map to automatically follow along as the marker is being moved----------------------------------
  // Future<void> camera_pos(LatLng pos) async {
  //   final GoogleMapController controller = await map_cntrl.future;
  //   CameraPosition new_Cam_Pos = CameraPosition(target: pos, zoom: 15);
  //   await controller.animateCamera(
  //     CameraUpdate.newCameraPosition(new_Cam_Pos),
  //   );
  // }

//-----------default value for urgency level--------------------------
  String? dropValue = "Low";

//-----------default value for cupertino switch of notifications------------

  bool on_off = false;

//-----------home page bottom navigation controller------------------
  int state = 0;

  String? name;
  String? surname;

  late final LocalAuthentication _auth;
  bool supported = false;

//---------method initiator-----------------------------
  @override
  void initState() {
    //addIcon();
    super.initState();
    _auth = LocalAuthentication();
    _auth.isDeviceSupported().then((bool is_Supported) => setState(() {
          supported = is_Supported;
        }));
    Delete.addAll([
      TargetFocus(keyTarget: delete, shape: ShapeLightFocus.Circle, contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: const Column(
              children: [
                Text(
                  "Report Card",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "Swipe left to delete a report",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
              ],
            ))
      ])
    ]);
    target.addAll([
      TargetFocus(keyTarget: search, shape: ShapeLightFocus.RRect, contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Column(
              children: [
                Text(
                  "Location Search Engine",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "Manually search and select the address of the leakage/burst",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        )
      ]),
      TargetFocus(keyTarget: reportLocationCircle, contents: [
        TargetContent(
          align: ContentAlign.left,
          child: const Column(
            children: [
              Text(
                "Areas with reports",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "View locations with active reports",
                style: TextStyle(fontSize: 13, color: Colors.white),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      ]),
      TargetFocus(keyTarget: myLocation, contents: [
        TargetContent(
          align: ContentAlign.left,
          child: const Column(
            children: [
              Text(
                "Location",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "Optimize the map to your current location",
                style: TextStyle(fontSize: 13, color: Colors.white),
              )
            ],
          ),
        )
      ]),
      TargetFocus(keyTarget: chooseFile, contents: [
        TargetContent(
          align: ContentAlign.right,
          child: const Column(
            children: [
              Text(
                "Image File",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "Upload an image from your device",
                style: TextStyle(fontSize: 13, color: Colors.white),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      ]),
      TargetFocus(keyTarget: camera, contents: [
        TargetContent(
          align: ContentAlign.left,
          child: const Column(
            children: [
              Text(
                "Camera",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "Use your device to capture the image",
                style: TextStyle(fontSize: 13, color: Colors.white),
              )
            ],
          ),
        )
      ]),
      TargetFocus(keyTarget: level, contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Column(
            children: [
              Text(
                "Urgency Level",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "Predict the severity of the leakage/burst",
                style: TextStyle(fontSize: 13, color: Colors.white),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      ]),
      TargetFocus(keyTarget: submit, contents: [
        TargetContent(
          align: ContentAlign.top,
          child: const Padding(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                Text(
                  "Submit Report",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "Submit your report for processing",
                  style: TextStyle(fontSize: 13, color: Colors.white),
                )
              ],
            ),
          ),
        )
      ]),
    ]);
    getReportLocation();
    loadCustomMarker();
    user_location();
    get_num();
    get_num_attended();
    get_total();
    get_num_inProgress();
    get_num_rejected();
    get_num_submitted();
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Exit App',
              style: TextStyle(
                  color: Color.fromARGB(255, 2, 37, 66),
                  fontWeight: FontWeight.bold),
            ),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pop(false), // User does not want to exit
                child: const Text(
                  'No',
                  style: TextStyle(
                      color: Color.fromARGB(255, 2, 37, 66),
                      fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                }, // User wants to exit
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      color: Color.fromARGB(255, 2, 37, 66),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ) ??
        false; // Return false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
    double screen_height = MediaQuery.of(context).size.height;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool exit = await _showExitConfirmationDialog(context);
        return exit;
      },
      child: Scaffold(
        //App bar of my reports page
        appBar: state == 1
            ? AppBar(
                shape: const Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(80, 0, 0, 0),
                    width: 3,
                  ),
                ),
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "My Reports",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color.fromARGB(255, 2, 37, 66),
                      ),
                    ),
                    IconButton(
                      onPressed: () => show_Del_Tut(),
                      icon: Icon(Icons.info_outlined,
                          size: 30,
                          color: _counter == 1
                              ? const Color.fromARGB(255, 2, 37, 66)
                              : Colors.transparent),
                    )
                  ],
                ),
              )
            //App bar of the report status page
            : state == 3
                ? AppBar(
                    shape: const Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(80, 0, 0, 0),
                        width: 3,
                      ),
                    ),
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    title: const Text(
                      "Reports Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color.fromARGB(255, 2, 37, 66),
                      ),
                    ),
                  )
                //app bar of the home page
                : state == 0
                    ? AppBar(
                        shape: const Border(
                          bottom: BorderSide(
                            color: Color.fromARGB(80, 0, 0, 0),
                            width: 3,
                          ),
                        ),
                        automaticallyImplyLeading: false,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const Home()));
                              },
                              child: const Text(
                                "SpillAged",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Color.fromARGB(255, 2, 37, 66),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    //app bar of the settings page
                    : state == 4
                        ? AppBar(
                            shape: const Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(80, 0, 0, 0),
                                width: 3,
                              ),
                            ),
                            automaticallyImplyLeading: false,
                            centerTitle: true,
                            title: const Text(
                              "Settings",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Color.fromARGB(255, 2, 37, 66),
                              ),
                            ),
                          )
                        : //app bar of the Report a water leak page
                        AppBar(
                            shape: const Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(80, 0, 0, 0),
                                width: 3,
                              ),
                            ),
                            automaticallyImplyLeading: false,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Create a Report",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Color.fromARGB(255, 2, 37, 66),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Start_Tut(),
                                  icon: const Icon(Icons.info_outline),
                                  color: const Color.fromARGB(255, 2, 37, 66),
                                  iconSize: 30,
                                )
                              ],
                            ),
                          ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: get_user_data(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              //if data is received
              else if (snapshot.hasData) {
                //extract the data
                Map<String, dynamic>? user = snapshot.data!.data();

                name = user!["name"];
                surname = user["surname"];

                return Center(
                  //---------------------home page content------------------------------
                  child: state == 0
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: ListView(
                            children: [
                              SizedBox(height: screen_height < 650 ? 10 : 20),
                              Center(
                                child: Animate(
                                  effects: const [FadeEffect(), SlideEffect()],
                                  child: Text(
                                    "Welcome $name",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Color.fromARGB(255, 2, 37, 66),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screen_height < 650 ? 10 : 20,
                              ),
                              Animate(
                                effects: const [FadeEffect(), SlideEffect()],
                                child: SizedBox(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Animate(
                                        effects: const [
                                          ShimmerEffect(
                                              duration: Duration(seconds: 1))
                                        ],
                                        child: Container(
                                          height:
                                              screen_height < 650 ? 100 : 130,
                                          width: screen_width < 400 ? 100 : 110,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 2, 37, 66),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              Text(
                                                _points.toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Tokens \nEarned",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  //fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Animate(
                                        effects: const [
                                          ShimmerEffect(
                                              duration: Duration(seconds: 1))
                                        ],
                                        child: Container(
                                          height:
                                              screen_height < 650 ? 100 : 130,
                                          width: screen_width < 400 ? 100 : 110,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 2, 37, 66),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              Text(
                                                _counter.toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Total \nReports",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                  //fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Animate(
                                        effects: const [
                                          ShimmerEffect(
                                              duration: Duration(seconds: 1)),
                                        ],
                                        child: Container(
                                          height:
                                              screen_height < 650 ? 100 : 130,
                                          width: screen_width < 400 ? 100 : 110,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: const Color.fromARGB(
                                                255, 2, 37, 66),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                height: 12,
                                              ),
                                              Text(
                                                _attended.toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Text(
                                                "Attended\nReports",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: screen_height < 650 ? 10 : 20),
                              const Divider(
                                color: Color.fromARGB(255, 2, 37, 66),
                              ),
                              SizedBox(
                                height: screen_height < 650 ? 5 : 10,
                              ),
                              Animate(
                                effects: const [FadeEffect(), SlideEffect()],
                                child: const Center(
                                  child: Text(
                                    "Statistics",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 2, 37, 66),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Animate(
                                effects: const [FadeEffect(), SlideEffect()],
                                child: ListTile(
                                  onTap: () {},
                                  leading: const Icon(
                                    Icons.pie_chart_rounded,
                                    size: 30,
                                    color: Color.fromARGB(255, 2, 37, 66),
                                  ),
                                  title: const Text(
                                    "Total leaks that were fixed   \nthrough SpillAged",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: Text(
                                    _total.toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      //fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screen_height < 650 ? 10 : 20,
                              ),
                              const Divider(
                                color: Color.fromARGB(255, 2, 37, 66),
                              ),
                              SizedBox(
                                height: screen_height < 650 ? 5 : 10,
                              ),
                              Animate(
                                effects: const [FadeEffect(), SlideEffect()],
                                child: const Center(
                                  child: Text(
                                    "Resources",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 20,
                                      color: Color.fromARGB(255, 2, 37, 66),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Animate(
                                effects: const [SlideEffect(), FadeEffect()],
                                child: ListTile(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                const Education()));
                                  },
                                  leading: const Icon(
                                    Icons.book_rounded,
                                    size: 30,
                                    color: Color.fromARGB(255, 2, 37, 66),
                                  ),
                                  title: const Text(
                                    "Tips on water conservation",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: const Text(
                                    " ",
                                    //style: TextStyle(fontSize: 1),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screen_height < 650 ? 10 : 20,
                              ),
                              const Divider(
                                color: Color.fromARGB(255, 2, 37, 66),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )
                      //---------------------my reports page content------------------------------
                      : state == 1
                          ? StreamBuilder(
                              stream: repData.getreports(current_user!.email!),
                              builder: (context, snapshot) {
                                // // show a loading circle
                                // if (snapshot.connectionState ==
                                //     ConnectionState.waiting) {
                                //   return Center(
                                //     child: CircularProgressIndicator(),
                                //   );
                                // }

                                //get all reports
                                final all_reps = snapshot.data?.docs;

                                //no data
                                if (snapshot.data == null ||
                                    all_reps!.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: Image.asset(
                                              "images/noResult.png"),
                                        ),
                                        const Text(
                                          "No reports yet",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                      ],
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
                                    String lvl = rep["u_level"];
                                    String repPic = rep["picture_url"];
                                    String img_path = rep["imageName_type"];
                                    String report_status = rep["status"];
                                    String locationName = rep["locationName"];

                                    //return as a list tile

                                    return Padding(
                                      key: all_reps.length == 1 ? delete : null,
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      child: Animate(
                                        effects: const [
                                          SlideEffect(),
                                          FadeEffect(),
                                          ShimmerEffect(
                                              duration: Duration(seconds: 1))
                                        ],
                                        child: Dismissible(
                                          direction:
                                              DismissDirection.endToStart,
                                          background: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: Container(
                                              //height: 70,
                                              color: const Color.fromARGB(
                                                  255, 154, 40, 32),
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          key: ValueKey<QueryDocumentSnapshot>(
                                              all_reps[index]),
                                          onDismissed: (direction) async {
                                            setState(() {
                                              if (report_status ==
                                                  "Submitted") {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (context) =>
                                                            AlertDialog(
                                                              title: const Text(
                                                                "Report Deletion",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            2,
                                                                            37,
                                                                            66)),
                                                              ),
                                                              content: const SizedBox(
                                                                  width: 350,
                                                                  child: Text(
                                                                      "Are you sure you want to delete this report?")),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            2,
                                                                            37,
                                                                            66),
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    repData.deleteRep(
                                                                        repID);
                                                                    deleteImage(
                                                                        img_path);
                                                                    get_num();
                                                                    get_num_submitted();
                                                                    showToast(
                                                                        message:
                                                                            "Report deleted successfully");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Yes",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            2,
                                                                            37,
                                                                            66),
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                )
                                                              ],
                                                            ));
                                              } else {
                                                showToast(
                                                    message:
                                                        "cannot delete because the status of this report has changed");
                                              }
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Container(
                                                padding: EdgeInsets.only(
                                                  bottom: 5,
                                                  top: 5,
                                                  left: screen_width > 400
                                                      ? 0
                                                      : 5,
                                                ),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 3,
                                                        color: const Color
                                                            .fromARGB(
                                                            100, 2, 37, 66)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        60, 2, 37, 66)),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      height: screen_width < 400
                                                          ? 70
                                                          : 60,
                                                      width: screen_width < 400
                                                          ? 60
                                                          : 70,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            repPic,
                                                            fit: BoxFit.cover,
                                                          )),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                "Date-Time",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screen_width <
                                                                                400
                                                                            ? 11
                                                                            : 13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            Text(
                                                              ": $date_time",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      screen_width <
                                                                              400
                                                                          ? 11
                                                                          : 13),
                                                            )
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                "Location",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screen_width <
                                                                                400
                                                                            ? 11
                                                                            : 13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            const Text(": "),
                                                            SizedBox(
                                                                height: 20,
                                                                width:
                                                                    screen_width >
                                                                            400
                                                                        ? 180
                                                                        : 155,
                                                                child: Center(
                                                                  child: Row(
                                                                    children: [
                                                                      Flexible(
                                                                        child:
                                                                            Text(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          locationName
                                                                              .split(",")
                                                                              .first,
                                                                          style:
                                                                              TextStyle(fontSize: screen_width < 400 ? 11 : 13),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 70,
                                                              child: Text(
                                                                "Urgency",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        screen_width <
                                                                                400
                                                                            ? 11
                                                                            : 13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            Text(
                                                              ": $lvl",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      screen_width <
                                                                              400
                                                                          ? 11
                                                                          : 13),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )

                          //-------------------------adding a report----------------------------------
                          : state == 2
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Location",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: screen_height < 736 ? 218 : 320,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    100, 2, 37, 66),
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: init_Pos == null
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                          height: 120,
                                                          width: 120,
                                                          child: Lottie.asset(
                                                            'lottie_animation/Animation - 1720956624571.json',
                                                          )),
                                                    ],
                                                  ),
                                                )
                                              : Stack(children: [
                                                  GoogleMap(
                                                    circles: _circles,
                                                    zoomControlsEnabled: false,
                                                    onMapCreated: onMapCreated,
                                                    initialCameraPosition:
                                                        CameraPosition(
                                                            target: init_Pos!,
                                                            zoom: 17),
                                                    markers:
                                                        //marker,
                                                        {
                                                      mapMarker.Marker(
                                                        markerId: MarkerId(
                                                            init_Pos
                                                                .toString()),
                                                        position: init_Pos!,
                                                        infoWindow: InfoWindow(
                                                            title: name),
                                                        icon: customIcon ??
                                                            BitmapDescriptor
                                                                .defaultMarker,
                                                      ),
                                                      marker.first
                                                    },
                                                    onTap: onTap,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 10),
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: TextFormField(
                                                        key: search,
                                                        cursorColor: const Color
                                                            .fromARGB(
                                                            255, 2, 37, 66),
                                                        controller:
                                                            locationSearch,
                                                        decoration:
                                                            InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 10,
                                                            right: 10,
                                                          ),
                                                          hintText:
                                                              "Search Location",
                                                          suffix: IconButton(
                                                              onPressed:
                                                                  searchLocation,
                                                              icon: const Icon(
                                                                  Icons
                                                                      .search)),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 10,
                                                    right: 10,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          go_to_location();
                                                        });
                                                      },
                                                      child: Container(
                                                        key: myLocation,
                                                        height: 30,
                                                        width: 30,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    103,
                                                                    101,
                                                                    101),
                                                                width: 1)),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.gps_fixed,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    103,
                                                                    101,
                                                                    101),
                                                          ),
                                                          //color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 45,
                                                    right: 10,
                                                    child: GestureDetector(
                                                      onTap:
                                                          _circleReportedAreas,
                                                      child: Container(
                                                        key:
                                                            reportLocationCircle,
                                                        height: 30,
                                                        width: 30,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    103,
                                                                    101,
                                                                    101),
                                                                width: 1)),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons
                                                                .report_problem,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    103,
                                                                    101,
                                                                    101),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  marker_Pos != null
                                                      ? Positioned(
                                                          bottom: 80,
                                                          right: 10,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                marker_Pos =
                                                                    null;
                                                                marker.clear();
                                                                marker.add(const mapMarker
                                                                    .Marker(
                                                                    markerId:
                                                                        MarkerId(
                                                                            "init")));
                                                              });
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              width: 30,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border.all(
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          103,
                                                                          101,
                                                                          101),
                                                                      width:
                                                                          1)),
                                                              child:
                                                                  const Center(
                                                                child: Icon(
                                                                  Icons
                                                                      .location_off,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          103,
                                                                          101,
                                                                          101),
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                      : Container()
                                                ]),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            is_uploaded == true
                                                ? SizedBox(
                                                    child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (context) =>
                                                                      AlertDialog(
                                                                          shape:
                                                                              const Border(),
                                                                          contentPadding: const EdgeInsets
                                                                              .all(
                                                                              5),
                                                                          content:
                                                                              SizedBox(
                                                                            child:
                                                                                Image.network(location!),
                                                                          )));
                                                            });
                                                          },
                                                          child: SizedBox(
                                                            width:
                                                                screen_width <
                                                                        400
                                                                    ? 270
                                                                    : 320,
                                                            child: Text(
                                                              "Image Name: ${pathName!.substring(pathName!.length > 27 ? (pathName!.length - 15) : 0)}",
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                          onPressed: () {
                                                            deleteImage(
                                                                pathName!);
                                                            setState(() {
                                                              is_uploaded =
                                                                  false;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.cancel_sharp,
                                                          ))
                                                    ],
                                                  ))
                                                : const Row(
                                                    children: [
                                                      Text(
                                                        "Upload Image",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: is_uploaded == true
                                                      ? const Color.fromARGB(
                                                          175, 76, 175, 79)
                                                      : const Color.fromARGB(
                                                          60, 2, 37, 66)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: SizedBox(
                                                      width: 140,
                                                      height: 35,
                                                      child: ElevatedButton(
                                                        key: chooseFile,
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              ContinuousRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          backgroundColor:
                                                              const Color
                                                                  .fromARGB(
                                                                  75, 0, 0, 0),
                                                        ),
                                                        onPressed:
                                                            is_uploaded == true
                                                                ? () {}
                                                                : () {
                                                                    uploadImg(
                                                                        ImageSource
                                                                            .gallery);
                                                                    setState(
                                                                        () {
                                                                      _date.text =
                                                                          "${DateFormat("dd-MM-yyyy").format(DateTime.now())} ${TimeOfDay.now().toString().substring(9)}";
                                                                    });
                                                                  },
                                                        child: is_uploading
                                                            ? const SizedBox(
                                                                height: 25,
                                                                width: 25,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  color: Colors
                                                                      .white,
                                                                ))
                                                            : const Text(
                                                                "Choose File",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        13),
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    key: camera,
                                                    onPressed:
                                                        is_uploaded == true
                                                            ? () {}
                                                            : () {
                                                                uploadImg(
                                                                    ImageSource
                                                                        .camera);
                                                                setState(() {
                                                                  _date.text =
                                                                      "${DateFormat("dd-MM-yyyy").format(DateTime.now())} ${TimeOfDay.now().toString().substring(9)}";
                                                                });
                                                              },
                                                    icon: is_uploading
                                                        ? const SizedBox(
                                                            height: 25,
                                                            width: 25,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                            ))
                                                        : const Icon(
                                                            Icons
                                                                .camera_alt_rounded,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    2,
                                                                    37,
                                                                    66),
                                                          ),
                                                    iconSize: 30,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Row(
                                              children: [
                                                Text(
                                                  "Urgency Level",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 150,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              60, 2, 37, 66),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child:
                                                        DropdownButton<String>(
                                                      underline: Container(),
                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 40,
                                                        ),
                                                        child: Icon(
                                                          key: level,
                                                          Icons
                                                              .arrow_drop_down_circle_rounded,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 2, 37, 66),
                                                          size: 30,
                                                        ),
                                                      ),
                                                      value: dropValue,
                                                      items: const <String>[
                                                        "Low",
                                                        "Medium",
                                                        "High",
                                                      ].map((String val) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: val,
                                                          child: Text(
                                                            val,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        13),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (newVal) {
                                                        setState(() {
                                                          dropValue = newVal;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            SizedBox(
                                              child: TextFormField(
                                                controller: _date,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  labelText: 'Date and Time',
                                                  labelStyle: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        235, 0, 0, 0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Center(
                                              child: SizedBox(
                                                height: 50,
                                                width: 150,
                                                child: ElevatedButton(
                                                  key: submit,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        ContinuousRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    foregroundColor:
                                                        Colors.white,
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 2, 37, 66),
                                                  ),
                                                  onPressed: () {
                                                    make_report();
                                                  },
                                                  child: is_added
                                                      ? const SizedBox(
                                                          child:
                                                              CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ))
                                                      : const Text(
                                                          "Submit Report",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 25,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              //---------------------Report status content------------------------------
                              : state == 3
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 60,
                                            child: Animate(
                                              effects: const [
                                                SlideEffect(),
                                                FadeEffect(),
                                                ShimmerEffect(
                                                    duration:
                                                        Duration(seconds: 1))
                                              ],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 3,
                                                        color: const Color
                                                            .fromARGB(
                                                            100, 2, 37, 66)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        60, 2, 37, 66)),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                const User_Submitted_Reps()));
                                                  },
                                                  leading: const Icon(
                                                    Icons.description_outlined,
                                                    size: 30,
                                                  ),
                                                  title: const Text(
                                                    "Submitted",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: Text(
                                                    "$submitted",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          SizedBox(
                                            height: 60,
                                            child: Animate(
                                              effects: const [
                                                SlideEffect(),
                                                FadeEffect(),
                                                ShimmerEffect(
                                                    duration:
                                                        Duration(seconds: 1))
                                              ],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 3,
                                                        color: const Color
                                                            .fromARGB(
                                                            100, 2, 37, 66)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        60, 2, 37, 66)),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                const User_InProgress_Reps()));
                                                  },
                                                  leading: const Icon(
                                                    Icons.timer_outlined,
                                                    size: 30,
                                                  ),
                                                  title: const Text(
                                                    "In-Progress",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: Text(
                                                    "$inProgress",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          SizedBox(
                                            height: 60,
                                            child: Animate(
                                              effects: const [
                                                SlideEffect(),
                                                FadeEffect(),
                                                ShimmerEffect(
                                                    duration:
                                                        Duration(seconds: 1))
                                              ],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 3,
                                                        color: const Color
                                                            .fromARGB(
                                                            100, 2, 37, 66)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        60, 2, 37, 66)),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                const User_Completed_Reps()));
                                                  },
                                                  leading: const Icon(
                                                    Icons.done_outline_rounded,
                                                    size: 30,
                                                  ),
                                                  title: const Text(
                                                    "Completed",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: Text(
                                                    "$_attended",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          SizedBox(
                                            height: 60,
                                            child: Animate(
                                              effects: const [
                                                SlideEffect(),
                                                FadeEffect(),
                                                ShimmerEffect(
                                                    duration:
                                                        Duration(seconds: 1))
                                              ],
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 3,
                                                        color: const Color
                                                            .fromARGB(
                                                            100, 2, 37, 66)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        60, 2, 37, 66)),
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                const User_Rejected_Reps()));
                                                  },
                                                  leading: const Icon(
                                                    Icons.cancel_outlined,
                                                    size: 30,
                                                  ),
                                                  title: const Text(
                                                    "Rejected",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  trailing: Text(
                                                    "$rejected",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider()
                                        ],
                                      ),
                                    )

                                  //-----------------------Settings page content------------------------------
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20, top: 10),
                                      child: ListView(
                                        children: [
                                          Animate(
                                            effects: const [
                                              SlideEffect(),
                                              FadeEffect(),
                                              ShimmerEffect(
                                                  duration:
                                                      Duration(seconds: 1))
                                            ],
                                            child: Container(
                                              height: 100,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 2,
                                                      color:
                                                          const Color.fromARGB(
                                                              100, 2, 37, 66)),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: const Color.fromARGB(
                                                      40, 2, 37, 66)),
                                              child: Center(
                                                child: ListTile(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                const Profile()));
                                                  },
                                                  leading: Container(
                                                    height: 58,
                                                    width: 58,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 2,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 2, 37, 66),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child: user["profile_url"] ==
                                                                "null"
                                                            ? Image.asset(
                                                                "images/blank_img.webp")
                                                            : Image.network(
                                                                user[
                                                                    "profile_url"],
                                                                fit: BoxFit
                                                                    .cover,
                                                              )),
                                                  ),
                                                  title: Text(
                                                    "$name $surname",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  subtitle: Text(
                                                    "${_points.toString()} Tokens Earned",
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  trailing: IconButton(
                                                    iconSize: 30,
                                                    color: const Color.fromARGB(
                                                        255, 2, 37, 66),
                                                    onPressed: () {
                                                      setState(() {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title:
                                                                          const Text(
                                                                        "Logout",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                2,
                                                                                37,
                                                                                66)),
                                                                      ),
                                                                      content: const SizedBox(
                                                                          width:
                                                                              350,
                                                                          child:
                                                                              Text("Are you sure you want to log out?")),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Cancel",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Color.fromARGB(255, 2, 37, 66),
                                                                                fontSize: 13),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            FirebaseAuth.instance.signOut();
                                                                            Navigator.pop(context);
                                                                            Navigator.pop(context);
                                                                            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const LandingPg()));
                                                                          },
                                                                          child:
                                                                              const Text(
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
                                                    },
                                                    icon: const Icon(
                                                        Icons.logout_outlined),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          supported
                                              ? SizedBox(
                                                  height: 60,
                                                  child: ListTile(
                                                    onTap: () {
                                                      setState(() {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                                      title:
                                                                          const Text(
                                                                        "Are you sure?",
                                                                        style: TextStyle(
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                2,
                                                                                37,
                                                                                66),
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      content: const SizedBox(
                                                                          width:
                                                                              350,
                                                                          child:
                                                                              Text("Note: if activated, this will save the login credentials of the current logged in account")),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Cancel",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: Color.fromARGB(255, 2, 37, 66),
                                                                                fontSize: 13),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            flutter_Storage();
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text(
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
                                                    },
                                                    leading: const Icon(
                                                      Icons.fingerprint,
                                                      size: 30,
                                                    ),
                                                    title: const Text(
                                                      "Activate Biometrics Log-in",
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                          supported
                                              ? const Divider()
                                              : const SizedBox(),
                                          SizedBox(
                                            height: 60,
                                            child: Link(
                                              target: LinkTarget.self,
                                              uri: Uri.parse(
                                                  "https://222019622.github.io/about-us-spillaged/privacypolicy.html"),
                                              builder: (context, followlink) =>
                                                  ListTile(
                                                onTap: followlink,
                                                leading: const Icon(
                                                  Icons.lock_outline_rounded,
                                                  size: 30,
                                                ),
                                                title: const Text(
                                                  "Terms Of Use & Privacy Policy",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          SizedBox(
                                            height: 60,
                                            child: ListTile(
                                              onTap: () {
                                                setState(() {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) =>
                                                              AlertDialog(
                                                                title:
                                                                    const Text(
                                                                  "Contact Us",
                                                                  style: TextStyle(
                                                                      color: Color
                                                                          .fromARGB(
                                                                              255,
                                                                              2,
                                                                              37,
                                                                              66),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                content: const SizedBox(
                                                                    width: 350,
                                                                    child: Text(
                                                                        "Are you sure you want to make a call")),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Cancel",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              2,
                                                                              37,
                                                                              66),
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Yes",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              2,
                                                                              37,
                                                                              66),
                                                                          fontSize:
                                                                              13),
                                                                    ),
                                                                  )
                                                                ],
                                                              ));
                                                });
                                              },
                                              leading: const Icon(
                                                Icons.phone_outlined,
                                                size: 30,
                                              ),
                                              title: const Text(
                                                "Contact Us",
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          SizedBox(
                                            height: 60,
                                            child: Link(
                                              target: LinkTarget.self,
                                              uri: Uri.parse(
                                                  "https://222019622.github.io/about-us-spillaged/"),
                                              builder: (context, followlink) =>
                                                  ListTile(
                                                onTap: followlink,
                                                leading: const Icon(
                                                  Icons.info_outline,
                                                  size: 30,
                                                ),
                                                title: const Text(
                                                  "About Us",
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    ),
                );
              } else {
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
            }),

        //----------------------------------------------------------------bottom Nav----------------
        bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: Colors.transparent,
            animationDuration: const Duration(milliseconds: 350),
            height: 65,
            onTap: (value) {
              setState(() {
                state = value;
              });
            },
            color: const Color.fromARGB(255, 2, 37, 66),
            items: <Widget>[
              SizedBox(
                height: 40,
                child: state != 0
                    ? const Column(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 26.5,
                          ),
                          Expanded(
                            child: Text(
                              "Home",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              SizedBox(
                height: 40,
                child: state != 1
                    ? const Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                            size: 26.5,
                          ),
                          Expanded(
                            child: Text(
                              "My Reports",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              const Icon(
                Icons.add,
                color: Colors.white,
                size: 35,
              ),
              SizedBox(
                height: 40,
                child: state != 3
                    ? const Column(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            color: Colors.white,
                            size: 26.5,
                          ),
                          Expanded(
                            child: Text(
                              "Status",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.fact_check,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
              SizedBox(
                height: 40,
                child: state != 4
                    ? const Column(
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 26.5,
                          ),
                          Expanded(
                            child: Text(
                              "Settings",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ],
                      )
                    : const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 30,
                      ),
              ),
            ]),
      ),
    );
  }

  //a variable for flutter storage that is used to store the user's email and passworf for logging in using biometrics
  final FlutterSecureStorage _secure_Strg = const FlutterSecureStorage();
  //global keys of the widgets that are supposed to ba expalined how they work

  GlobalKey reportLocationCircle = GlobalKey();
  GlobalKey myLocation = GlobalKey();
  GlobalKey search = GlobalKey();
  GlobalKey chooseFile = GlobalKey();
  GlobalKey camera = GlobalKey();
  GlobalKey submit = GlobalKey();
  GlobalKey level = GlobalKey();
  GlobalKey delete = GlobalKey();

  //list that stores the elements that are supposed to be shown how they work
  List<TargetFocus> target = [];
  List<TargetFocus> Delete = [];

  List<String> alphabets = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z'
  ];

  // List of numbers (0-9)
  List<String> numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  void randomizeList(List<String> list) {
    final random = Random();
    for (int i = list.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      String temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  Set<Circle> _circles =
      {}; //document that stores all the circles that show areas that are reported
  double? latitude;
  double? long_coodinates;

  late GoogleMapController mapControl;
  Set<mapMarker.Marker> marker = {
    const mapMarker.Marker(markerId: MarkerId("init"))
  }; //a dictionary that stores
  TextEditingController locationSearch = TextEditingController();
  LatLng? init_Pos;
  LatLng? marker_Pos;
  BitmapDescriptor? customIcon; //custom icon for the user's location

  String? convert;
  String? repName;

  //the method of uploding the email and the password in the flutter storage

  Future flutter_Storage() async {
    await _secure_Strg.write(key: "email", value: current_user!.email);
    await _secure_Strg.write(key: "password", value: global_Password);
    showToast(message: "Biometrics activated successfully");
  }

  //method of showing how to delete a report
  void show_Del_Tut() {
    TutorialCoachMark(
      targets: Delete,
    ).show(context: context);
  }

  //method of showing the user the functions of the buttons
  void Start_Tut() {
    TutorialCoachMark(
      targets: target,
    ).show(context: context);
  }

  // methods of uploading images to firebase i.e the reports directory
  uploadImg(ImageSource src) async {
    repImage = await ImagePicker().pickImage(source: src);
    if (repImage != null) {
      //loading animation while the image is being uploaded to the storage
      setState(() {
        is_uploading = true;
      });

      //print(repImage!.path);
      return uploadImgToFirebase(File(repImage!.path));
    }
  }

  Future uploadImgToFirebase(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      pathName = image.path.split("/").last;
      final uploadRef = storageRef.child("reports/$pathName");
      await uploadRef.putFile(image);
      //print("success");
      location = await uploadRef.getDownloadURL();
      //print(location);
      setState(() {
        //ending the animation
        is_uploading = false;
        is_uploaded = true;
      });
    } catch (e) {
      showToast(message: "$e");
      //print(e);
    }
  }

//methods of deleting images in firebase storage that are in the reports directory

  Future<void> deleteImage(String path) async {
    final stg = FirebaseStorage.instance;
    Reference ref = stg.ref("reports/$path");
    try {
      await ref.delete();
      //print("image deleted successfully");
    } catch (e) {
      showToast(message: e.toString());
      //print(e);
    }
  }

  // a method of determining the users position
  Future<void> user_location() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      init_Pos = LatLng(pos.latitude, pos.longitude);
      //print(init_Pos);
    });
  }

  //a method of searching for a specific location
  Future<void> searchLocation() async {
    List<Location> places = await locationFromAddress(locationSearch.text);
    if (places.isNotEmpty) {
      Location place = places.first;
      mapControl.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(place.latitude, place.longitude), 17));
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapControl = controller;
  }

  //setting a marker when a user taps on the map
  void onTap(LatLng position) {
    setState(() {
      marker.clear();

      //clear markers that already exist in the list
      marker_Pos = position;
      //print(marker_Pos);

      //marker.add(retainedMark);
      marker.add(
        mapMarker.Marker(
            markerId: MarkerId(position.toString()),
            position: position,
            infoWindow: const InfoWindow(title: "Water Leakage"),
            draggable: true,
            onDrag: (dragPos) {
              setState(() {
                marker_Pos = dragPos;
                //print(marker_Pos);
              });
            }),
      );
    });
  }

  //method of loading the custom marker
  void loadCustomMarker() async {
    customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)), // You can adjust the size
      'images/current_location.png', // Path to your asset image
    );
  }

  //animationg the camera to move to the current location
  void go_to_location() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    mapControl.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 17));
  }

  //a method of making a circle around the reported areas
  void _circleReportedAreas() async {
    getReportLocation();
    Set<Circle> circles = {};
    for (var loc in locations) {
      String lat = loc.split(",").first.substring(1);
      latitude = double.parse(lat);
      String long = loc.split(",").last;
      String longitude = long.split(")").first;
      long_coodinates = double.parse(longitude);
      //-----------------------adding circles--------------
      circles.add(
        Circle(
          circleId: CircleId(latitude.toString()),
          center: LatLng(latitude!, long_coodinates!),
          radius: 50, // The radius of the circle in meters
          fillColor: const Color.fromARGB(100, 244, 67, 54),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ),
      );
    }
    setState(() {
      _circles = circles;
    });
  }

//a method of showing that the report is made successfully
  void successAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Set a timer to close the dialog after 2 seconds
            Future.delayed(const Duration(seconds: 3), () {
              Navigator.of(context).pop();
            });

            return AlertDialog(
              backgroundColor: Colors.transparent,
              content: SizedBox(
                child: LottieBuilder.asset(
                  "lottie_animation/Animation - 1725240537068.json",
                ),
              ),
            );
          },
        );
      },
    );
  }

  void updateDeviceToken(String ID) {
    FirebaseFirestore.instance
        .collection("Reports")
        .doc(ID)
        .update({"device_token": device_token});
  }

  //method of creating a report
  void make_report() async {
    //Randomize each list
    randomizeList(alphabets);
    randomizeList(numbers);
    //if all fields a filled
    if (init_Pos != null && _date.text.isNotEmpty && location != null) {
      setState(() {
        is_added = true;
      });
      if (marker_Pos != null) {
        convert = await repData.getAddress(
            marker_Pos!.latitude, marker_Pos!.longitude);
        if (convert!.endsWith("Gauteng")) {
          repName =
              "GP${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Limpopo")) {
          repName =
              "LP${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Eastern Cape")) {
          repName =
              "EC${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Free State")) {
          repName =
              "FS${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("KwaZulu-Natal")) {
          repName =
              "KZ${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Mpumalanga")) {
          repName =
              "MP${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Northern Cape")) {
          repName =
              "NC${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("North West")) {
          repName =
              "NW${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Western Cape")) {
          repName =
              "WC${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else {
          showToast(
              message:
                  "that province is not registered in the application yet");
        }
        repData.addReport(
            marker_Pos!.toString().substring(6),
            _date.text,
            dropValue!,
            location!,
            pathName!,
            rep_status,
            marker_Pos!.latitude,
            marker_Pos!.longitude,
            convert!,
            repName!);
      } else {
        convert =
            await repData.getAddress(init_Pos!.latitude, init_Pos!.longitude);
        if (convert!.endsWith("Gauteng")) {
          repName =
              "GP${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Limpopo")) {
          repName =
              "LP${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Eastern Cape")) {
          repName =
              "EC${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Free State")) {
          repName =
              "FS${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("KwaZulu-Natal")) {
          repName =
              "KZ${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Mpumalanga")) {
          repName =
              "MP${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Northern Cape")) {
          repName =
              "NC${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("North West")) {
          repName =
              "NW${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else if (convert!.endsWith("Western Cape")) {
          repName =
              "WC${DateTime.now().year}-Rep${numbers.last + numbers.first + numbers[6] + alphabets.first}-${_counter + 1}";
        } else {
          showToast(
              message:
                  "that province is not registered in the application yet");
        }
        repData.addReport(
            init_Pos!.toString().substring(6),
            _date.text,
            dropValue!,
            location!,
            pathName!,
            rep_status,
            init_Pos!.latitude,
            init_Pos!.longitude,
            convert!,
            repName!);
      }
      // ignore: use_build_context_synchronously
      successAnimation(context);
      showToast(message: "Leak reported successfully!!");
      updateDeviceToken(repName!);
    }

    //return everything to default
    setState(() {
      getReportLocation();
      go_to_location();
      marker_Pos = null; // setting the marker position to null
      //clearing the marker from the map
      marker.clear();
      marker.add(const mapMarker.Marker(markerId: MarkerId("init")));
      get_num_submitted();
      get_num(); //updates the total reports section on the home page
      is_added = false;
      is_uploaded = false;
      _date.clear();
      location = null;
    });
  }
}
