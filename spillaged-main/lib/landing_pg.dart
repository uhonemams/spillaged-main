import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spillaged/registration_pg.dart';
import 'log_in_pg.dart';
import 'landing_pg_slideshow/pg1.dart';
import 'landing_pg_slideshow/pg2.dart';
import 'landing_pg_slideshow/pg3.dart';

//----------------landing page class----------------------
class LandingPg extends StatefulWidget {
  const LandingPg({super.key});

  @override
  State<LandingPg> createState() => _LandingPgState();
}

class _LandingPgState extends State<LandingPg> {
  final pgController = PageController(initialPage: 1);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        bool exit = await _showExitConfirmationDialog(context);
        return exit;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   automaticallyImplyLeading: false,
        // ),
        body: SafeArea(
          child: SafeArea(
            child: Padding(
              padding: screenWidth < 400
                  ? const EdgeInsets.only(left: 20, right: 20)
                  : const EdgeInsets.only(left: 30, right: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Text("width: $screen_width"),
                  // Text("height: $screen_height"),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          "images/spillaged_logo.png",
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                          //height: 0,
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
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: screenHeight < 736 ? 218 : 300,
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: const Color.fromARGB(100, 2, 37, 66),
                            ),
                            borderRadius: BorderRadius.circular(11)),
                        child: PageView(
                          controller: pgController,
                          children: const [pg1(), pg2(), pg3()],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SmoothPageIndicator(
                        controller: pgController,
                        count: 3,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: Color.fromARGB(255, 2, 37, 66),
                          dotColor: Color.fromARGB(100, 2, 37, 66),
                          dotHeight: 13,
                          dotWidth: 13,
                          spacing: 12,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Join the community and help \nsave water around your city\nnow!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(255, 2, 37, 66),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 2, 37, 66),
                          ),
                          onPressed: () {
                            //Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const LogInPg(),
                              ),
                            );
                          },
                          child: const Text("Login"),
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 2, 37, 66),
                          ),
                          onPressed: () {
                            //Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const RegisterPg(),
                              ),
                            );
                          },
                          child: const Text("Register"),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(
                  //   height: 3,
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
