// ignore_for_file: camel_case_types, non_constant_identifier_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:spillaged/global/common/toast.dart';
import 'log_in_pg.dart';

class Forgot_Pwd extends StatefulWidget {
  const Forgot_Pwd({super.key});

  @override
  State<Forgot_Pwd> createState() => _Forgot_PwdState();
}

class _Forgot_PwdState extends State<Forgot_Pwd> {
  final _email = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  //a method of showing that the report is made successfully
  void successAnimation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Set a timer to close the dialog after 2 seconds
            Future.delayed(const Duration(seconds: 5), () {
              Navigator.of(context).pop();
            });

            return AlertDialog(
              backgroundColor: Colors.transparent,
              content: SizedBox(
                child: LottieBuilder.asset(
                  "lottie_animation/Animation - 1725311468054.json",
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future reset_Pwd() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email.text);
      _email.clear();
      // ignore: use_build_context_synchronously
      successAnimation(context);
    } catch (e) {
      showToast(message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Image.asset("images/pwd.png"),
              ),
              const Text(
                "Forgot your password?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Color.fromARGB(255, 2, 37, 66),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Enter your email address below to recieve a reset link. Click the link, set a new password, and you are all set",
                style: TextStyle(
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                child: TextFormField(
                  cursorColor: const Color.fromARGB(255, 2, 37, 66),
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    floatingLabelStyle:
                        const TextStyle(color: Color.fromARGB(255, 2, 37, 66)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 2, 37, 66), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 2, 37, 66),
                  ),
                  onPressed: reset_Pwd,
                  child: const Text("Reset Password"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => const LogInPg()));
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
                        "Back to login",
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
      )),
    );
  }
}
