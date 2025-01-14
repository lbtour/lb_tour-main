import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BookingStatusNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  BookingStatusNotifier() {
    _initLocalNotifications();
  }

  /// Continuously listens for changes in the 'status' field of bookings
  void listenForStatusChanges(String userId) {
    if (userId.isEmpty) {
      print('Error: User ID is empty. Cannot listen for status changes.');
      return;
    }

    // Listen for changes at 'Booking/uid'
    _database.child('Booking/$userId').onChildChanged.listen((event) {
      // Debug: Log the changed child
      print('Child Changed: ${event.snapshot.value}');
      print('Child Key: ${event.snapshot.key}');

      if (event.snapshot.value == null) {
        print('Warning: Null snapshot detected for Booking/$userId.');
        return;
      }

      // Extract data
      final bookingId = event.snapshot.key; // Booking ID
      final status = event.snapshot.child('status').value; // Updated status
      final address = event.snapshot.child('address').value; // Booking address

      // Debug: Log extracted values
      print('Detected Booking ID: $bookingId');
      print('Detected Status: $status');
      print('Detected Address: $address');

      // Only show notification if 'status' and 'address' are valid
      if (status != null && address != null) {
        print('Showing notification for booking status update.');
        _showLocalNotification(
          title: 'Booking Status Updated',
          body: 'Booking at "$address" is now $status.',
          payload: bookingId,
        );
      } else {
        print('Status or Address is null. Skipping notification.');
      }
    }).onError((error) {
      print('Error listening for changes in Booking/$userId: $error');
    });

    // Debug: Confirmation of listener setup
    print('Listening for status changes in Booking/$userId');
  }

  /// Initialize local notifications
  void _initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          print('Notification tapped with payload: ${response.payload}');
          // Navigate to booking details page or perform other actions
        }
      },
    );

    print('Local notifications initialized successfully.');
  }

  /// Display a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'booking_status_channel', // Channel ID
        'Booking Status Notifications', // Channel name
        channelDescription: 'Notifications for booking status updates.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        title,
        body,
        platformChannelSpecifics,
        payload: payload, // Pass payload (e.g., Booking ID)
      );

      print('Notification displayed: $title - $body');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
