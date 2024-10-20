// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:spillaged/main.dart';
import 'package:spillaged/firebase.dart';
import 'package:spillaged/global/common/toast.dart';
import 'package:spillaged/landing_pg.dart';
import 'package:spillaged/userAuth.dart';
import 'package:spillaged/verifyEmail.dart';
import 'package:url_launcher/link.dart';
import 'log_in_pg.dart';
import 'package:intl/intl.dart';

class RegisterPg extends StatefulWidget {
  const RegisterPg({super.key});

  @override
  State<RegisterPg> createState() => _RegisterPgState();
}

class _RegisterPgState extends State<RegisterPg> {
  final formKey = GlobalKey<FormState>();
  final passwords = TextEditingController();
  final dateOfBirth = TextEditingController();
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _surname = TextEditingController();
  final _phone = TextEditingController();

  final Firebase_Services auth = Firebase_Services();
  final FlutterSecureStorage _secure_Strg = const FlutterSecureStorage();
  late final LocalAuthentication _auth;
  bool supported = false;

  //--------------Checkbox for the privacy and terms of use--------------
  bool is_checked = false;
  bool allowed = false;
  bool is_Signed = false;

  @override
  void initState() {
    super.initState();
    _auth = LocalAuthentication();
    _auth.isDeviceSupported().then((bool is_Supported) => setState(() {
          supported = is_Supported;
        }));
  }

  //-------------------Registering method------------

  void Register() async {
    setState(() {
      is_Signed = true;
    });
    String email = _email.text;
    String password = passwords.text;

    if (allowed) {
      await _secure_Strg.write(key: "email", value: email);
      await _secure_Strg.write(key: "password", value: password);
    }
    //create the user
    User? user = await auth.register_email_password(email, password);
    repDatabase database = repDatabase();

    setState(() {
      is_Signed = false;
    });

    if (user != null) {
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const EmailVerif()));
      //create a new user document and add it to the firestore
      database.createUseDoc(_name.text, _surname.text, dateOfBirth.text,
          _gender!, _phone.text, profileLoc, profilePath);
    }
  }

  // //method of creating a user document, colllection, and add them in the firestore
  // Future<void> createUseDoc(User? usercred) async {
  //   if (usercred != null) {
  //     await FirebaseFirestore.instance
  //         .collection("Users")
  //         .doc(usercred.email)
  //         .set({
  //       "email": usercred.email,
  //       "name": _name.text,
  //       "surname": _surname.text,
  //       "date_of_birth": dateOfBirth.text,
  //       "gender": _gender,
  //       "phone": _phone.text,
  //     });
  //   }
  // }

  bool _obscureTxt = true;
  bool _hidden = true;

  DateTime dob = DateTime.now();

  //----------method of date picking---------

  Future<Null> datePick(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dob,
      firstDate: DateTime(1900),
      lastDate: dob,
    );

    if (picked != null && picked != dob) {
      setState(() {
        dob = picked;
        dateOfBirth.text = DateFormat('dd-MM-yyy').format(dob);
      });
    }
  }

  String? _gender = "Male";

  @override
  void dispose() {
    _email.dispose();
    passwords.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screen_width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(80, 0, 0, 0),
            width: 3,
          ),
        ),
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => const LandingPg()));
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5, right: 2),
                  child: Image.asset(
                    "images/spillaged_logo.png",
                    height: 35,
                    width: 35,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const Text(
                " SpillAged",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color.fromARGB(255, 2, 37, 66),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color.fromARGB(255, 2, 37, 66),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    //width: 350,
                    child: TextFormField(
                      controller: _name,
                      cursorColor: const Color.fromARGB(255, 2, 37, 66),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        floatingLabelStyle: const TextStyle(
                            color: Color.fromARGB(255, 2, 37, 66)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 2, 37, 66),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                          return "Name entered doesn't exist";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    //width: 350,
                    child: TextFormField(
                        controller: _surname,
                        cursorColor: const Color.fromARGB(255, 2, 37, 66),
                        decoration: InputDecoration(
                          labelText: 'Surname',
                          floatingLabelStyle: const TextStyle(
                              color: Color.fromARGB(255, 2, 37, 66)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 2, 37, 66),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                            return "Surname entered doesn't exist";
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    //width: 350,
                    child: TextFormField(
                        controller: dateOfBirth,
                        cursorColor: const Color.fromARGB(255, 2, 37, 66),
                        decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            floatingLabelStyle: const TextStyle(
                                color: Color.fromARGB(255, 2, 37, 66)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 2, 37, 66),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () => datePick(context),
                                icon:
                                    const Icon(Icons.calendar_month_outlined))),
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r'(0[1-9]|[12][0-9]|3[01])-(0[1-9]|1[0-2])-(19|20)\d{2}')
                                  .hasMatch(value)) {
                            return "Invalid Date of Birth";
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Row(
                    children: [
                      Text(" Gender"),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                            activeColor: const Color.fromARGB(255, 2, 37, 66),
                            title: Text(
                              "Male",
                              style: TextStyle(
                                  fontSize: screen_width < 400 ? 11 : 13),
                            ),
                            contentPadding: const EdgeInsets.all(0.0),
                            value: "Male",
                            groupValue: _gender,
                            onChanged: (val) {
                              setState(() {
                                _gender = val;
                              });
                            }),
                      ),
                      Expanded(
                        child: RadioListTile(
                            activeColor: const Color.fromARGB(255, 2, 37, 66),
                            title: Text(
                              "Female",
                              style: TextStyle(
                                  fontSize: screen_width < 400 ? 11 : 13),
                            ),
                            contentPadding: const EdgeInsets.all(0.0),
                            value: "Female",
                            groupValue: _gender,
                            onChanged: (val) {
                              setState(() {
                                _gender = val;
                              });
                            }),
                      ),
                      Expanded(
                        child: RadioListTile(
                            activeColor: const Color.fromARGB(255, 2, 37, 66),
                            title: Text(
                              "Other",
                              style: TextStyle(
                                  fontSize: screen_width < 400 ? 11 : 13),
                            ),
                            contentPadding: const EdgeInsets.all(0.0),
                            value: "Other",
                            groupValue: _gender,
                            onChanged: (val) {
                              setState(() {
                                _gender = val;
                              });
                            }),
                      ),
                    ],
                  ),
                  SizedBox(
                    child: TextFormField(
                        controller: _phone,
                        cursorColor: const Color.fromARGB(255, 2, 37, 66),
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          floatingLabelStyle: const TextStyle(
                              color: Color.fromARGB(255, 2, 37, 66)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 2, 37, 66),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty ||
                              !RegExp(r'^(?:[+0]9)?[0-9]{10,12}$')
                                  .hasMatch(value)) {
                            return "Invalid phone number";
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    //width: 350,
                    child: TextFormField(
                        cursorColor: const Color.fromARGB(255, 2, 37, 66),
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          floatingLabelStyle: const TextStyle(
                              color: Color.fromARGB(255, 2, 37, 66)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 2, 37, 66),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        //autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.endsWith("@spillaged.com")) {
                            return "Cannot create user with that kind of email";
                          }
                          if (value.isEmpty ||
                              !RegExp(r'^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$')
                                  .hasMatch(value)) {
                            return "Invalid Email Address";
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    //width: 350,
                    child: TextFormField(
                        cursorColor: const Color.fromARGB(255, 2, 37, 66),
                        decoration: InputDecoration(
                            labelText: 'Password',
                            floatingLabelStyle: const TextStyle(
                                color: Color.fromARGB(255, 2, 37, 66)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 2, 37, 66),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureTxt = !_obscureTxt;
                                  });
                                },
                                icon: _obscureTxt
                                    ? const Icon(Icons.visibility_outlined)
                                    : const Icon(
                                        Icons.visibility_off_outlined))),
                        obscureText: _obscureTxt,
                        controller: passwords,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (valueP) {
                          if (passwords.text == "") {
                            return "Nothing was entered";
                          }
                          if (valueP!.isEmpty ||
                              RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&-]).{8,}$')
                                  .hasMatch(valueP)) {
                            return null;
                          } else if (!RegExp(r'(?=.*?[A-Z])')
                              .hasMatch(valueP)) {
                            return "Requires at least one uppercase";
                          } else if (!RegExp(r'(?=.*?[a-z])')
                              .hasMatch(valueP)) {
                            return "Requires at least one lowercase";
                          } else if (!RegExp(r'(?=.*?[0-9])')
                              .hasMatch(valueP)) {
                            return "Requires at least one number";
                          } else if (!RegExp(r'(?=.*?[#?!@$%^&-])')
                              .hasMatch(valueP)) {
                            return "Requires at least one special character";
                          } else if (!RegExp(r'.{8,}').hasMatch(valueP)) {
                            return "should be 8 characters long";
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    //width: 350,
                    child: TextFormField(
                        cursorColor: const Color.fromARGB(255, 2, 37, 66),
                        decoration: InputDecoration(
                            labelText: 'Repeat Password',
                            floatingLabelStyle: const TextStyle(
                                color: Color.fromARGB(255, 2, 37, 66)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 2, 37, 66),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hidden = !_hidden;
                                  });
                                },
                                icon: _hidden
                                    ? const Icon(Icons.visibility_outlined)
                                    : const Icon(
                                        Icons.visibility_off_outlined))),
                        obscureText: _hidden,
                        validator: (value) {
                          if (value != passwords.text) {
                            return "Passwords don't match";
                          } else {
                            return null;
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  supported
                      ? Row(children: [
                          Checkbox(
                              //focusColor: Color.fromARGB(255, 2, 37, 66),
                              activeColor: const Color.fromARGB(255, 2, 37, 66),
                              value: allowed,
                              onChanged: (bool? value) {
                                setState(() {
                                  allowed = value ?? false;
                                });
                              }),
                          Text(
                            "Use biometrics to log in",
                            style: TextStyle(
                                fontSize: screen_width < 400 ? 11 : 13),
                          ),
                        ])
                      : const SizedBox(),
                  Row(
                    children: [
                      Checkbox(
                          //focusColor: Color.fromARGB(255, 2, 37, 66),
                          activeColor: const Color.fromARGB(255, 2, 37, 66),
                          value: is_checked,
                          onChanged: (bool? value) {
                            setState(() {
                              is_checked = value ?? false;
                            });
                          }),
                      Text(
                        "I accept the ",
                        style:
                            TextStyle(fontSize: screen_width < 400 ? 11 : 13),
                      ),
                      Link(
                        target: LinkTarget.self,
                        uri: Uri.parse(
                            "https://222019622.github.io/about-us-spillaged/privacypolicy.html"),
                        builder: (context, followlink) => GestureDetector(
                            onTap: followlink,
                            child: Text(
                              "Terms of use & Privacy Policy",
                              style: TextStyle(
                                  fontSize: screen_width < 400 ? 11 : 13,
                                  color: const Color.fromARGB(255, 2, 37, 66),
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: const Alignment(0, 0),
                    child: SizedBox(
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
                        onPressed:
                            //Register,
                            () {
                          if (formKey.currentState!.validate() &&
                              is_checked != false) {
                            Register();
                          }
                          if (is_checked == false) {
                            showToast(
                                message:
                                    "Please accept the Terms of Use and Privacy Policy above");
                          }
                        },
                        child: is_Signed
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Register",
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style:
                            TextStyle(fontSize: screen_width < 400 ? 11 : 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LogInPg()));
                        },
                        child: Text(
                          "Login now",
                          style: TextStyle(
                              fontSize: screen_width < 400 ? 11 : 13,
                              color: const Color.fromARGB(255, 2, 37, 66),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
