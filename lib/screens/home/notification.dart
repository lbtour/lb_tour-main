import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../navigation-tab.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> userBookings = [];

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      fetchUserBookings();
    }
  }

  /// Fetch user bookings from Firebase
  Future<void> fetchUserBookings() async {
    DatabaseReference bookingsRef = FirebaseDatabase.instance.ref().child('Booking');
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');

    print("Fetching bookings for user: ${currentUser!.uid}");

    bookingsRef.child(currentUser!.uid).once().then((DatabaseEvent event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      // Debug Log
      print("Fetched bookings data: $data");

      List<Map<String, dynamic>> bookings = [];

      for (var entry in data.entries) {
        String key = entry.key;
        Map<dynamic, dynamic> value = entry.value;

        String fullName = value['fullName'] ?? 'Unknown';

        // If fullName is missing or null, fetch it from the users node
        if (fullName == 'Unknown' || fullName.isEmpty) {
          final userSnapshot = await usersRef.child(currentUser!.uid).get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.value as Map<dynamic, dynamic>;
            fullName = "${userData['firstName'] ?? 'Unknown'} ${userData['lastName'] ?? 'Unknown'}";
          }
        }

        bookings.add({
          'id': key,
          'fullName': fullName,
          'email': value['email'] ?? 'Unknown',
          'touristName': value['touristName'] ?? 'Unknown',
          'price': value['price'] ?? '0',
          'date': value['date'] ?? '',
          'status': value['status'] ?? 'Unknown',
          'numberOfPeople': value['numberOfPeople'] ?? '0',
          'description': value['description'] ?? '',
          'contactNumber': value['contactNumber'] ?? 'Unknown',
          'imageUrl': value['imageUrl'] ??
              'https://via.placeholder.com/70', // Default image if null
        });
      }

      setState(() {
        userBookings = bookings;
      });
      print("Processed bookings: $userBookings");
    }).catchError((error) {
      print("Error fetching bookings: $error");
    });
  }

  /// Format the date
  String formatDate(String rawDate) {
    try {
      DateTime dateTime = DateTime.parse(rawDate);
      return DateFormat('MMMM d, yyyy').format(dateTime);
    } catch (e) {
      print("Error formatting date: $e");
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Get.to(
                () => TabNavigation(initialIndex: 0),

            );
          },
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: Color.fromARGB(255, 14, 86, 170),
            size: 24.0,
          ),
        ),
        title: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedNotification01,
              color: Color.fromARGB(255, 14, 86, 170),
              size: 24.0,
            ),
            const SizedBox(width: 10),
            Text(
              "Notifications",
              style: GoogleFonts.roboto(
                fontSize: 22,
                color: Color.fromARGB(255, 14, 86, 170),
                textStyle: TextStyle(fontWeight: FontWeight.normal)
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (userBookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text("No bookings found."),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true, // Ensure the ListView only takes as much space as it needs
                physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
                itemCount: userBookings.length,
                itemBuilder: (context, index) {
                  final booking = userBookings[index];
                  return GestureDetector(
                    onTap: () {
                      // Log the status value being sent
                      print("Navigating to AccountPage with status: ${booking['status']}");

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TabNavigation(
                            initialIndex: 4, // Navigate to the AccountPage tab
                            selectedStatus: booking['status'], // Pass the status of the selected booking
                          ),
                        ),
                      );
                    },

                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image of the tourist spot
                            Image.network(
                              booking['imageUrl'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey,
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            // Booking details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking['touristName'],
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Booked by: ${booking['fullName']}",
                                    style: GoogleFonts.roboto(fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Date: ${booking['date'] != null && booking['date'].toString().isNotEmpty ? formatDate(booking['date'].toString()) : 'No date provided'}",
                                    style: GoogleFonts.roboto(fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Status: ${booking['status']}",
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: booking['status'] == "Pending"
                                          ? Colors.orange
                                          : booking['status'] == "Cancelled"
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}