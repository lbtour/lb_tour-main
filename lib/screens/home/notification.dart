import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

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

  // Fetch user bookings from Firebase
  Future<void> fetchUserBookings() async {
    DatabaseReference bookingsRef =
        FirebaseDatabase.instance.ref().child('Booking');

    // Log the current user UID
    print("Fetching bookings for user: ${currentUser!.uid}");

    // Query the 'Booking' node for the logged-in user's bookings
    bookingsRef
        .child(
            currentUser!.uid) // Access the bookings directly using the userId
        .once()
        .then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      print("Fetched bookings data: $data");

      // Parse the booking data
      List<Map<String, dynamic>> bookings = [];
      data.forEach((key, value) {
        bookings.add({
          'id': key,
          'fullname': value['fullname'],
          'email': value['email'],
          'touristName': value['touristName'],
          'price': value['price'],
          'date': value['date'],
          'status': value['status'],
          'numberOfPeople': value['numberOfPeople'],
          'description': value['description'],
          'contactNumber': value['contactNumber'],
          'imageUrl': value['imageUrl'],
        });
      });

      setState(() {
        userBookings = bookings; // Update state with the fetched bookings
        print(
            "Bookings fetched: $userBookings"); // Debug log to check the bookings list
      });
    });
  }

  // Function to format the date
  String formatDate(String rawDate) {
    DateTime dateTime =
        DateTime.parse(rawDate); // Convert the raw date string to DateTime
    return DateFormat('MMMM d, yyyy').format(
        dateTime); // Format to "Month Day, Year" (e.g. December 5, 2024)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft02,
              color: Colors.black,
              size: 24.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const HugeIcon(
                icon: HugeIcons.strokeRoundedNotification01,
                color: Color.fromARGB(255, 14, 86, 170),
                size: 24.0),
            const SizedBox(width: 10),
            Text(
              "Notifications",
              style: GoogleFonts.comfortaa(
                fontSize: 14,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
      body: userBookings.isEmpty
          ? const Center(child: Text("No bookings found."))
          : ListView.builder(
              itemCount: userBookings.length,
              itemBuilder: (context, index) {
                final booking = userBookings[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display the image of the tourist spot
                        Image.network(
                          booking['imageUrl'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        // Display booking details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['touristName'],
                                style: GoogleFonts.comfortaa(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Booked by: ${booking['fullname']}",
                                style: GoogleFonts.comfortaa(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Date: ${formatDate(booking['date'])}",
                                style: GoogleFonts.comfortaa(fontSize: 14),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Status: ${booking['status']}",
                                style: GoogleFonts.comfortaa(
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
                );
              },
            ),
    );
  }
}
