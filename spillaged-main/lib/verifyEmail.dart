// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spillaged/global/common/toast.dart';
import 'package:spillaged/home_pg.dart';
import 'package:spillaged/log_in_pg.dart';

import 'main.dart';

class EmailVerif extends StatefulWidget {
  const EmailVerif({super.key});

  @override
  State<EmailVerif> createState() => _EmailVerifState();
}

class _EmailVerifState extends State<EmailVerif> {
  bool can_Resend = false;
  Timer? time;

  @override
  void initState() {
    super.initState();
    is_verified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!is_verified) {
      send_verification();

      time = Timer.periodic(
        const Duration(seconds: 3),
        (check) => check_Email(),
      );
    }
  }

  Future check_Email() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      is_verified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (is_verified) {
      time?.cancel();
    }
  }

  Future send_verification() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => can_Resend = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => can_Resend = true);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  @override
  void dispose() {
    time?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return is_verified
        ? const Home()
        : Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Image.asset("images/email.png"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Verify your email",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color.fromARGB(255, 2, 37, 66),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Text(
                        "We have sent an email to ${FirebaseAuth.instance.currentUser!.email} to verify your email address and activate your account. Please click on the link sent to your email to activate your account",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: send_verification,
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 2, 37, 66),
                              borderRadius: BorderRadius.circular(10)),
                          child: can_Resend == false
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 15),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    Text(
                                      "Resend Email",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LogInPg()));
                        },
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(60, 2, 37, 66),
                              border: Border.all(
                                  width: 2,
                                  color: const Color.fromARGB(255, 2, 37, 66)),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 2, 37, 66)),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
