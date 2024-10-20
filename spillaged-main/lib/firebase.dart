// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';

//this database stores user repoerts, it is stored in a collection called "reports" in firestore

//each report is going to consist of the location, date, and urgency level for now

class repDatabase {
  //current logged in user
  User? current_user = FirebaseAuth.instance.currentUser;

  //collection of reports
  final CollectionReference reports =
      FirebaseFirestore.instance.collection("Reports");

  //method of creating a user document, colllection, and add them in the firestore
  Future<void> createUseDoc(
    String name,
    String surname,
    String date_of_birth,
    String gender,
    String phone,
    String profile_url,
    String file_type,
  ) async {
    if (current_user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(current_user!.email)
          .set({
        "email": current_user!.email,
        "name": name,
        "surname": surname,
        "date_of_birth": date_of_birth,
        "gender": gender,
        "phone": phone,
        "dateCreated": DateTime.now(),
        "profile_url": "null",
        "profile_f_type": "null",
      });
    }
  }

  //make a report
  Future<void> addReport(
      String location,
      String dateTime,
      String level,
      String picture,
      String imgNameType,
      String status,
      double latitude,
      double longitude,
      String locatioName,
      String repName) {
    return reports.doc(repName).set({
      "rejectDate": "null",
      "reject_reason": "null",
      "assigned_to": "null", //this where the employee_id will be entered
      "completionDate": "null",
      "latitude": latitude,
      "longitude": longitude,
      "locationName": locatioName,
      "dateTime": dateTime,
      "location": location,
      "u_level": level,
      "status": status,
      "imageName_type": imgNameType,
      "picture_url": picture,
      "userEmail": current_user!.email,
      "device_token": "null",
      "step": "Assessing Report",
      "compImg": "null"
    });
  }

  //read the reports made from the database that are made by a specific user
  Stream<QuerySnapshot> getreports(String userEmail) {
    final report = FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: userEmail)
        .orderBy("dateTime", descending: true)
        .snapshots();
    return report;
  }

  //read all the users reports that are submitted
  Stream<QuerySnapshot> submittedReps(String userEmail) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: userEmail)
        .where("status", isEqualTo: "Submitted")
        .orderBy("dateTime", descending: true)
        .snapshots();
    return rep;
  }

  //read all the users reports that are rejected
  Stream<QuerySnapshot> rejectedReps(String userEmail) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: userEmail)
        .where("status", isEqualTo: "Rejected")
        .orderBy("rejectDate", descending: true)
        .snapshots();
    return rep;
  }

  //read all the users reports that are in progress
  Stream<QuerySnapshot> InProgress(String userEmail) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: userEmail)
        .where("status", isEqualTo: "In Progress")
        .orderBy("dateTime", descending: true)
        .snapshots();
    return rep;
  }

  //read all the users reports that are completed
  Stream<QuerySnapshot> CompleteReps(String userEmail) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("userEmail", isEqualTo: userEmail)
        .where("status", isEqualTo: "Complete")
        .orderBy("completionDate", descending: true)
        .snapshots();
    return rep;
  }

  //read the reports made from the database that are assigned to an employee
  Stream<QuerySnapshot> assignedreports(String userEmail) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("assigned_to", isEqualTo: userEmail)
        .where("status", isEqualTo: "In Progress")
        .orderBy("dateTime", descending: true)
        .snapshots();
    return rep;
  }

  //read the report that an employee clicks on for managing purposes
  Stream<QuerySnapshot> managereports(String userEmail, String repId) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("assigned_to", isEqualTo: userEmail)
        .where(FieldPath.documentId, isEqualTo: repId)
        .snapshots();
    return rep;
  }

  //read the deleted reports
  Stream<QuerySnapshot> rejectedReports(String userEmail) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("assigned_to", isEqualTo: userEmail)
        .where("status", isEqualTo: "Rejected")
        .orderBy("rejectDate", descending: true)
        .snapshots();
    return rep;
  }

  //read the deleted reports
  Stream<QuerySnapshot> CompletedReports(String userEmail) {
    final rep = FirebaseFirestore.instance
        .collection("Reports")
        .where("assigned_to", isEqualTo: userEmail)
        .where("status", isEqualTo: "Complete")
        .orderBy("completionDate", descending: true)
        .snapshots();
    return rep;
  }

  //read all the reports made from the database
  Stream<QuerySnapshot> allreports() {
    final rep = FirebaseFirestore.instance.collection("Reports").snapshots();
    return rep;
  }

  //delete a document from firebase
  Future<void> deleteRep(String repId) async {
    return await reports.doc(repId).delete();
  }

  Future<String> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      return "${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
    } catch (e) {
      //print(e);
      return "Unknown location";
    }
  }
}
