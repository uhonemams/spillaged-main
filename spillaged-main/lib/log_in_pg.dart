// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spillaged/main.dart';
import 'package:spillaged/employee.dart';
import 'package:spillaged/forgotPwd.dart';
import 'package:spillaged/global/common/toast.dart';
import 'package:spillaged/landing_pg.dart';
import 'package:spillaged/verifyEmail.dart';
import 'registration_pg.dart';
import 'userAuth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LogInPg extends StatefulWidget {
  const LogInPg({super.key});

  @override
  State<LogInPg> createState() => _LogInPgState();
}

class _LogInPgState extends State<LogInPg> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final loginForm = GlobalKey<FormState>();
  final FlutterSecureStorage _secure_Strg = const FlutterSecureStorage();
  final Firebase_Services auth = Firebase_Services();
  late final LocalAuthentication _auth;
  bool supported = false;

  @override
  void initState() {
    super.initState();
    _auth = LocalAuthentication();
    _auth.isDeviceSupported().then((bool is_Supported) => setState(() {
          supported = is_Supported;
        }));
  }

  //-----------------biometric login method----------
  Future<void> finger_login() async {
    String? email = await _secure_Strg.read(key: "email");
    String? password = await _secure_Strg.read(key: "password");

    // print(email);
    // print(password);

    bool authenticated = false;

    if (email != null && password != null) {
      try {
        authenticated = await _auth.authenticate(
            localizedReason: "Scan your fingerptint/Enter pin to Sign-In",
            options: const AuthenticationOptions(
              useErrorDialogs: true,
              stickyAuth: true,
            ));
      } catch (e) {
        showToast(message: e.toString());
      }
      if (authenticated) {
        login(email, password);
      }
    } else {
      showToast(message: "Biometric login is not activated yet");
    }
  }

  //-------------------sign in method------------

  void login(String email, String password) async {
    global_Password = password;
    setState(() {
      isLogged = true;
    });
    // String email = _email.text;
    // String password = _password.text;

    User? user = await auth.login_email_password(email, password);

    setState(() {
      isLogged = false;
    });

    if (user != null && user.email!.endsWith("@spillaged.com")) {
      //print(user);
      //print("logged in successfully");
      showToast(message: "Employee logged in successfully.");

      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const Employee_page()));
    } else if (user != null) {
      //showToast(message: "User logged in successfully.");

      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const EmailVerif()));
    }
  }

  bool _isObscure = true;
  bool isLogged = false;

  void visibilty() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //double screen_width = MediaQuery.of(context).size.width;
    double screen_height = MediaQuery.of(context).size.height;

    return Scaffold(
      //appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Form(
            key: loginForm,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const LandingPg()));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          "images/spillaged_logo.png",
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Text(
                      "SpillAged",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color.fromARGB(255, 2, 37, 66),
                      ),
                    ),
                    const Text(
                      "Making pipe leakages a thing \nof the past",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 2, 37, 66),
                      ),
                    ),
                    supported
                        ? SizedBox(
                            height: screen_height < 650
                                ? 20 / 2
                                : screen_height > 750
                                    ? 175 / 2
                                    : 80 / 2,
                          )
                        : SizedBox(
                            height: screen_height < 650
                                ? 40
                                : screen_height > 750
                                    ? 175
                                    : 80,
                          ),
                    const Text(
                      "Log In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Color.fromARGB(255, 2, 37, 66),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
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
                        validator: (value) {
                          if (_email.text == "") {
                            return "nothing was entered";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      //width: 350,
                      child: TextFormField(
                          cursorColor: const Color.fromARGB(255, 2, 37, 66),
                          controller: _password,
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
                                onPressed: visibilty,
                                icon: _isObscure
                                    ? const Icon(Icons.visibility_outlined)
                                    : const Icon(
                                        Icons.visibility_off_outlined)),
                          ),
                          validator: (value) {
                            if (_password.text == "") {
                              return "nothing was entered";
                            } else {
                              return null;
                            }
                          },
                          obscureText: _isObscure),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const Forgot_Pwd()));
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(255, 2, 37, 66)),
                          ),
                        ),
                      ],
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
                        onPressed: () {
                          login(_email.text, _password.text);
                        },
                        child: isLogged
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Login"),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const RegisterPg()));
                          },
                          child: const Text(
                            "Register now",
                            style: TextStyle(
                                color: Color.fromARGB(255, 2, 37, 66),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    supported
                        ? Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2.5,
                                  color: const Color.fromARGB(255, 2, 37, 66),
                                ),
                                borderRadius: BorderRadius.circular(100)),
                            child: IconButton(
                              onPressed: finger_login,
                              icon: const Icon(
                                Icons.fingerprint,
                                size: 60,
                                color: Color.fromARGB(255, 2, 37, 66),
                              ),
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
