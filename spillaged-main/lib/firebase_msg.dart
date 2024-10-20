// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spillaged/main.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:spillaged/global/common/toast.dart';

class Firebase_msg {
  final String projectId = "spillaged-test";
  //create an instance of the firebase messaging
  final firebase_msg = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin local_notifications =
      FlutterLocalNotificationsPlugin();

  Future<String> getAccessToken() async {
    final service_acc = {
      "type": "service_account",
      "project_id": "",
      "private_key_id": "",
      "private_key":
          "-----BEGIN PRIVATE KEY-----",
      "client_email": "",
      "client_id": "",
      "auth_uri": "",
      "token_uri": "",
      "auth_provider_x509_cert_url":
          "",
      "client_x509_cert_url":
          "",
      "universe_domain": ""
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(service_acc), scopes);

    //get access token

    auth.AccessCredentials cred =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(service_acc),
            scopes,
            client);

    client.close();

    return cred.accessToken.data;
  }

//Function to send a notification
  Future sendNotification(String title, String body, String phone_token) async {
    final String server_key = await getAccessToken();

    //print("server key : $server_key");
    //print("phone token: $phone_token");
    String endPoint =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final Map<String, dynamic> msg = {
      'message': {
        'token': phone_token,
        'notification': {'title': title, 'body': body}
      }
    };

    final http.Response response = await http.post(Uri.parse(endPoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $server_key'
        },
        body: jsonEncode(msg));

    if (response.statusCode == 200) {
      showToast(message: "Notification sent successfully");
    } else {
      showToast(message: "Failed to send the notification");
    }
  }

  //initialize the notifications
  Future<void> initialize_notifications() async {
    // request permission from user
    await firebase_msg.requestPermission();
    //fetch the FCM token for the device
    String? token = await firebase_msg.getToken();
    device_token = token;

    //initialize further settings for push notifications
    initializePushNotifications();
  }

  //handle the recieved messages :opens the app when the user clicks on the notification
  void handleMsg(RemoteMessage? message) {
    //if the message is null, do nothing
    if (message == null) {
      return;
    }
  }

  Future<void> initializePushNotifications() async {
    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/spillaged_logo_trans');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await local_notifications.initialize(initializationSettings);

    // Handle notifications when the app is terminated and now opened
    firebase_msg.getInitialMessage().then(handleMsg);

    // Attach event listeners when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMsg);

    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //print('Message received in foreground: ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(
            message.notification?.title, message.notification?.body);
      }
    });
  }

  // Function to display a local notification in the foreground
  Future<void> showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('high_importance', 'SpillAged',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await local_notifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }
}
