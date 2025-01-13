import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../ccontroller/activity_controller.dart';
import '../../ccontroller/booking_controller.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';
import 'activity_page.dart';
import 'booking_page.dart';
import 'overview_page.dart';

class BookingScreen extends StatefulWidget {
  final TouristSpot spot;

  const BookingScreen({super.key, required this.spot});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentPage = 0;

  final ActivityController activityController = Get.put(ActivityController());

  // TextEditingControllers for the booking form
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberOfPeopleController = TextEditingController();

  final ValueNotifier<DateTime?> _selectedDateNotifier = ValueNotifier<DateTime?>(null);
  Map<DateTime, String> _userBookings = {};

  // Firebase references
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserBookings();
  }
  Future<void> _fetchUserBookings() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        print("Error: No authenticated user found.");
        return;
      }

      print("Fetching user bookings for UID: ${user.uid}");

      final snapshot = await _databaseRef.child('Booking').child(user.uid).get();

      if (!snapshot.exists) {
        print("No bookings found for user: ${user.uid}");
        return;
      }

      print("Raw booking data from Firebase:");
      print(snapshot.value);

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      // Parse bookings and ensure null safety
      final bookings = data.entries.map((entry) {
        final value = Map<String, dynamic>.from(entry.value as Map);

        final dateString = value['date']?.toString(); // Ensure `date` is a string
        final status = value['status']?.toString() ?? 'Unknown'; // Default to 'Unknown'

        if (dateString == null) {
          print("Warning: Booking ${entry.key} has no 'date'. Skipping...");
          return null;
        }

        try {
          final bookingDate = DateTime.parse(dateString);
          return MapEntry(bookingDate, status);
        } catch (e) {
          print("Error parsing date for Booking ${entry.key}: $e");
          return null;
        }
      }).whereType<MapEntry<DateTime, String>>().toList(); // Remove null values

      setState(() {
        _userBookings = Map<DateTime, String>.fromEntries(bookings);
      });

      print("Processed bookings:");
      print(_userBookings);
    } catch (e) {
      print("Error fetching user bookings: $e");
    }
  }


  Widget _getDynamicContent() {
    final BookingController bookingController = Get.put(BookingController());

    return Container(
      height: 340,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: _currentPage == 0
          ? Image.network(widget.spot.imageUrl, fit: BoxFit.cover) // Case 0: Overview
          : _currentPage == 1
          ? Column( // Case 1: Booking
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey),
            ),
            child: ValueListenableBuilder<DateTime?>(
              valueListenable: _selectedDateNotifier,
              builder: (context, selectedDate, child) {
                if (selectedDate != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected Date ${selectedDate.toLocal().toString().split(' ')[0]}",
                        style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _userBookings[selectedDate] ?? "Available.",
                        style: GoogleFonts.comfortaa(
                            fontSize: 14, color: Colors.green),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Visiting Hours: 08:00 AM - 05:00 PM",
                        style: GoogleFonts.comfortaa(
                            fontSize: 14, color: Colors.black),
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      "No date selected",
                      style: GoogleFonts.comfortaa(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 50.0, right: 50),
            child: GestureDetector(
              onTap: () {
                _showCalendarDialog();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Text(
                  "Select Date",
                  style: GoogleFonts.comfortaa(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : Obx(() => bookingController.selectedActivityImage.value.isNotEmpty // Case 2: Activities
          ? Image.network(
        bookingController.selectedActivityImage.value,
        fit: BoxFit.cover,
      )
          : Center(
        child: Text(
          "No activities available",
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      )),
    );
  }

  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select a Date",
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _selectedDateNotifier.value ?? DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDateNotifier.value),
                  onDaySelected: (selectedDay, focusedDay) {
                    print('Selected Date Updated to: $selectedDay'); // Debugging log
                    _selectedDateNotifier.value = selectedDay; // Trigger ValueListenable update
                    Navigator.pop(context); // Close the dialog
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  List<Widget> get pages => [
    OverviewPage(spot: widget.spot),
    ValueListenableBuilder<DateTime?>(
      valueListenable: _selectedDateNotifier,
      builder: (context, selectedDate, _) {
        print('Passing Selected Date to BookingPage: $selectedDate'); // Debugging log
        return BookingPage(
          spot: widget.spot,
          fullnameController: _fullnameController,
          contactNumberController: _contactNumberController,
          emailController: _emailController,
          numberOfPeopleController: _numberOfPeopleController,
          databaseRef: _databaseRef,
          auth: _auth,
          selectedDate: selectedDate, // Pass dynamically updated selectedDate
        );
      },
    ),
    ActivitiesPage(
      spot: widget.spot,
      onActivitySelected: (String selectedActivityImage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            // Update the dynamic content with the selected activity image
            // Ensure dynamic content is refreshed
            _getDynamicContent();
          });
        });
      },
    ),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.spot.name,
            style: GoogleFonts.comfortaa(
                fontSize: 18, fontWeight: FontWeight.bold)),
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _getDynamicContent(),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navigationButton('Overview', 0),
                _navigationButton('Booking', 1),
                _navigationButton('Activities', 2),
              ],
            ),
            pages[_currentPage],
          ],
        ),
      ),
    );
  }

  Widget _navigationButton(String label, int pageIndex) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentPage = pageIndex;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentPage == pageIndex
            ? const Color.fromARGB(255, 14, 86, 170)
            : Colors.grey,
      ),
      child: Text(label, style: GoogleFonts.comfortaa(color: Colors.white)),
    );
  }
}
