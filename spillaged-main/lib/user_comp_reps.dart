// ignore_for_file: camel_case_types, non_constant_identifier_names, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:spillaged/firebase.dart';

class User_Completed_Reps extends StatefulWidget {
  const User_Completed_Reps({super.key});

  @override
  State<User_Completed_Reps> createState() => _User_Completed_RepsState();
}

class _User_Completed_RepsState extends State<User_Completed_Reps> {
  //acessing the firebase class created
  repDatabase repData = repDatabase();

  //current logged in employee
  User? current_user = FirebaseAuth.instance.currentUser;

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
          centerTitle: true,
          title: const Text(
            "Completed Reports",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color.fromARGB(255, 2, 37, 66),
            ),
          ),
        ),
        body: StreamBuilder(
          stream: repData.CompleteReps(current_user!.email!),
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
                      "No reports yet",
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
                String step = rep["step"];
                String compImg = rep["compImg"];
                //return as a list tile

                return Column(
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
                          padding:
                              const EdgeInsets.only(left: 5, bottom: 5, top: 5),
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
                                      SizedBox(
                                        width: 100,
                                        child: const Text(
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
                                      SizedBox(
                                        width: 100,
                                        child: const Text(
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
                                            SizedBox(
                                              width: 100,
                                              child: const Text(
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
                                            SizedBox(
                                              width: 100,
                                              child: const Text(
                                                "Reject-Date",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                                child: Text(": $rejectDate"))
                                          ],
                                        )
                                      : const Row(),
                                  report_status == "In Progress"
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: const Text(
                                                "Step",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(child: Text(": $step "))
                                          ],
                                        )
                                      : const Row(),
                                  report_status == "Complete"
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: const Text(
                                                "Picture",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const Text(": "),
                                            SizedBox(
                                                child: GestureDetector(
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
                                                                child: Image
                                                                    .network(
                                                                        compImg),
                                                              )));
                                                });
                                              },
                                              child: const Text(
                                                "view picture",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 2, 37, 66),
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ))
                                          ],
                                        )
                                      : const Row(),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: const Text(
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
                                                        ? const Color.fromARGB(
                                                            255, 244, 21, 5)
                                                        : const Color.fromARGB(
                                                            210, 0, 0, 0)),
                                      ))
                                    ],
                                  ),
                                  reject_reason != "null"
                                      ? Row(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: const Text(
                                                "Reason",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                                child: Text(": $reject_reason"))
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
                );
              },
            );
          },
        ));
  }
}
