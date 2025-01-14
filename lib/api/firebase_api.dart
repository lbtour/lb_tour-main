import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseAPI {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging and Request Permissions
  static Future<void> initNotifications() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions.');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permissions.');
    } else {
      print('User denied notification permissions.');
      return;
    }

    // Retrieve FCM token
    await _getToken();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      // You can show a local notification here if required
    });
  }

  /// Get Firebase Messaging Token
  static Future<void> _getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM Token: $token');
      } else {
        print('Failed to retrieve FCM token.');
      }
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
  }

  /// Background Message Handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Message received in background: ${message.notification?.title}');
    // Handle background notification actions here
  }
}
