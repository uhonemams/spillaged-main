// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';

class Terms_Privacy extends StatefulWidget {
  const Terms_Privacy({super.key});

  @override
  State<Terms_Privacy> createState() => _Terms_PrivacyState();
}

class _Terms_PrivacyState extends State<Terms_Privacy> {
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
        //centerTitle: true,
        title: const Text(
          "Terms Of Use & Privacy Policy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color.fromARGB(255, 2, 37, 66),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            Text(
              "Terms Of Use",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                  "These Terms of Use govern your use of the SpillAged mobile application. By using the mobile application, you agree to these terms. If you disagree with any part of these terms, please do not use the App"),
            ),
            Text(
              "1. App Use:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•You may use the App solely for your personal, \n  non-commercial use.\n•You agree not to misuse the application or its \n  content.\n•You are responsible for maintaining the confidentiality of your account and password."),
            ),
            Text(
              "2. User-Generated Content:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•Any content you submit through the application becomes our property.\n•You grant us a non-exclusive, royalty-free license to use, reproduce, modify, and distribute your content.\n•You represent and warrant that your content does not violate any laws or infringe on the rights of others."),
            ),
            Text(
              "3. Disclaimer of Warranties:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•The application is provided 'as is' without warranties of any kind.\n•We do not guarantee the accuracy, completeness, or reliability of the application or its content."),
            ),
            Text(
              "4. Limitation of Liability:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•Our liability for any damages arising from the use of the application is limited"),
            ),
            Text(
              "5. Changes to Terms:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We may update these terms from time to time. Your continued use of the application constitutes acceptance of the changes."),
            ),
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                  "This Privacy Policy outlines how SpillAged collects, uses, discloses, and protects your personal information when you use the SpillAged mobile application ('App')."),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "Information We Collect:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Personal Information:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We may collect personal information such as your name, email address, and phone number when you create an account or submit a report."),
            ),
            Text(
              "Location Data:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We may collect your location data to process and verify leak or burst reports."),
            ),
            Text(
              "Device Information:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We may collect information about your device, such as the type of device, operating system, and device identifier."),
            ),
            Text(
              "How We Use Your Information:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We use your information to process and respond to your leak or burst reports.\n•We may use your information to improve our application and services.\n•We may use your information for analytics and research purposes."),
            ),
            Text(
              "Data Sharing:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We may share your information with government agencies or other relevant parties to address the reported issues. We will only share the minimum necessary information."),
            ),
            Text(
              "Data Security:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We implement reasonable security measures to protect your personal information from unauthorized access, disclosure, alteration, or destruction."),
            ),
            Text(
              "Your Rights:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•You have the right to access, correct, or delete your personal information. You can also object to the processing of your data"),
            ),
            Text(
              "Changes to This Policy:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  "•We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new privacy policy on this page"),
            )
          ],
        ),
      ),
    );
  }
}
