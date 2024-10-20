// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spillaged/main.dart';
import 'package:spillaged/completed_reps.dart';
import 'package:spillaged/firebase.dart';
import 'package:spillaged/landing_pg.dart';
import 'package:spillaged/manage_rep.dart';
import 'package:spillaged/rejected_reps.dart';

class Employee_page extends StatefulWidget {
  const Employee_page({super.key});

  @override
  State<Employee_page> createState() => _Employee_pageState();
}

class _Employee_pageState extends State<Employee_page> {
  //acessing the firebase class created
  repDatabase repData = repDatabase();

  //current logged in employee
  User? current_employee = FirebaseAuth.instance.currentUser;

  //method of fetching the employee's data
  Future<DocumentSnapshot<Map<String, dynamic>>> get_employee_data() async {
    return await FirebaseFirestore.instance
        .collection("Employees")
        .doc(current_employee!.uid)
        .get();
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool exit = await _showExitConfirmationDialog(context);
        return exit;
      },
      child: Scaffold(
        appBar: AppBar(
          shape: const Border(
            bottom: BorderSide(
              color: Color.fromARGB(80, 0, 0, 0),
              width: 3,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const Employee_page()));
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
        ),
        drawer: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: get_employee_data(),
          builder: (context, snapshot) {
            //if there is an error
            if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            //if data is received
            else if (snapshot.hasData) {
              //extract the data
              Map<String, dynamic>? employee = snapshot.data!.data();
              return Drawer(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child:
                                      Image.asset("images/spillaged_logo.png")),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  " Hi, ${employee!["name"]} ${employee["surname"]}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 3, color: Colors.grey),
                              color: const Color.fromARGB(60, 2, 37, 66),
                              borderRadius: BorderRadius.circular(10)),
                          height: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.maps_home_work_rounded,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    title: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "H O M E",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Colors.grey,
                                    thickness: 3,
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.delete,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const Rejected_Reps()));
                                    },
                                    title: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "R E J E C T E D  R E P O R T S",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13
                                            //color: Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Colors.grey,
                                    thickness: 3,
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.done,
                                      //color: Colors.black,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const Completed_Reps()));
                                    },
                                    title: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "C O M P L E T E D  R E P O R T S",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13
                                            //color: Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    indent: 20,
                                    endIndent: 20,
                                    color: Colors.grey,
                                    thickness: 3,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25),
                                child: Column(
                                  children: [
                                    const Divider(
                                      indent: 20,
                                      endIndent: 20,
                                      color: Colors.grey,
                                      thickness: 3,
                                    ),
                                    ListTile(
                                      onTap: () {
                                        FirebaseAuth.instance.signOut();
                                        Navigator.pop(context);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        const LandingPg()));
                                      },
                                      leading: const Icon(
                                        Icons.logout_rounded,
                                      ),
                                      titleAlignment:
                                          ListTileTitleAlignment.center,
                                      title: const Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          "L O G O U T",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      indent: 20,
                                      endIndent: 20,
                                      color: Colors.grey,
                                      thickness: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
        body: StreamBuilder(
          stream: repData.assignedreports(current_employee!.email!),
          builder: (context, snapshot) {
            //get all reports
            final all_reps = snapshot.data?.docs;

            //no data
            if (snapshot.data == null || all_reps!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.asset("images/noResult.png"),
                    ),
                    const Text(
                      "No Assigned Reports Yet",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                String completionDate = rep["completionDate"];
                String report_status = rep["status"];
                String rejectDate = rep["rejectDate"];
                String reject_reason = rep["reject_reason"];
                String step_ = rep["step"];
                //return as a list tile

                return GestureDetector(
                  onTap: () {
                    clicked = repID;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const Manage_Reps()));
                  },
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Animate(
                          effects: const [
                            SlideEffect(),
                            FadeEffect(),
                            ShimmerEffect(duration: Duration(seconds: 1))
                          ],
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 5, bottom: 5, top: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 3,
                                    color: report_status == "Rejected"
                                        ? const Color.fromARGB(200, 244, 67, 54)
                                        : report_status == "Complete"
                                            ? const Color.fromARGB(
                                                200, 76, 175, 79)
                                            : const Color.fromARGB(
                                                100, 2, 37, 66)),
                                borderRadius: BorderRadius.circular(10),
                                color: report_status == "Rejected"
                                    ? const Color.fromARGB(100, 244, 67, 54)
                                    : report_status == "Complete"
                                        ? const Color.fromARGB(100, 76, 175, 79)
                                        : const Color.fromARGB(60, 2, 37, 66)),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text(
                                            "Report_ID",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          ": $repID",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text(
                                            "Report-Date",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(child: Text(": $date_time"))
                                      ],
                                    ),
                                    completionDate != "null"
                                        ? Row(
                                            children: [
                                              const SizedBox(
                                                width: 100,
                                                child: Text(
                                                  "Completion",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                  child:
                                                      Text(": $completionDate"))
                                            ],
                                          )
                                        : const Row(),
                                    rejectDate != "null"
                                        ? Row(
                                            children: [
                                              const SizedBox(
                                                width: 100,
                                                child: Text(
                                                  "Reject-Date",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                  child: Text(
                                                ": $rejectDate",
                                              ))
                                            ],
                                          )
                                        : const Row(),
                                    report_status == "In Progress"
                                        ? Row(
                                            children: [
                                              const SizedBox(
                                                width: 100,
                                                child: Text(
                                                  "Step",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                  child: Text(
                                                ": $step_ ",
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ))
                                            ],
                                          )
                                        : const Row(),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 100,
                                          child: Text(
                                            "Status",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                            child: Text(
                                          ": $report_status",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: report_status ==
                                                      "In Progress"
                                                  ? const Color.fromARGB(
                                                      255, 185, 139, 0)
                                                  : report_status == "Complete"
                                                      ? const Color.fromARGB(
                                                          255, 1, 112, 4)
                                                      : report_status ==
                                                              "Rejected"
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 244, 21, 5)
                                                          : const Color
                                                              .fromARGB(
                                                              210, 0, 0, 0)),
                                        ))
                                      ],
                                    ),
                                    reject_reason != "null"
                                        ? Row(
                                            children: [
                                              const SizedBox(
                                                width: 100,
                                                child: Text(
                                                  "Reason",
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                  child:
                                                      Text(": $reject_reason"))
                                            ],
                                          )
                                        : const Row()
                                  ],
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
