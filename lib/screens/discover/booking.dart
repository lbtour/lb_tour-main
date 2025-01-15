import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../ccontroller/activity_controller.dart';
import '../../ccontroller/booking_controller.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';
import 'activity_page.dart';
import 'booking_page.dart';
import 'overview_page.dart';

class BookingScreen extends StatefulWidget {
  final TouristSpot spot;
  final int initialPage;

  const BookingScreen({super.key, required this.spot, this.initialPage = 0});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late int _currentPage;

  final ActivityController activityController = Get.put(ActivityController());
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberOfPeopleController = TextEditingController();

  final ValueNotifier<DateTime?> _selectedDateNotifier = ValueNotifier<DateTime?>(null);
  final ValueNotifier<String> _availableHourNotifier = ValueNotifier<String>("Loading...");
  final ValueNotifier<List<Map<String, String>>> _activitiesNotifier = ValueNotifier<List<Map<String, String>>>([]);
  Map<DateTime, String> _userBookings = {};

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _fetchUserBookings();
    _fetchAvailableHour();
  }

  Future<void> _fetchUserBookings() async {
    // Fetch user bookings logic here (if needed)
  }

  Future<void> _fetchAvailableHour() async {
    try {
      final touristId = widget.spot.id;

      if (touristId.isEmpty) {
        _availableHourNotifier.value = "Invalid tourist ID";
        return;
      }

      // Corrected path to access `availableHour`
      final snapshot = await _databaseRef
          .child('TouristSpot')
          .child(touristId)
          .child('availableHour')
          .get();
      print('Fetching availableHour for ID: $touristId');
      print('Snapshot value: ${snapshot.value}');

      if (snapshot.exists) {
        _availableHourNotifier.value = snapshot.value.toString();
      } else {
        _availableHourNotifier.value = "Unavailable";
      }
    } catch (e) {
      print('Error fetching available hours: $e');
      _availableHourNotifier.value = "Error loading data";
    }
  }

  Future<void> _fetchActivities() async {
    try {
      final touristId = widget.spot.id;

      if (touristId.isEmpty) {
        _activitiesNotifier.value = [];
        return;
      }

      final snapshot = await _databaseRef
          .child('TouristSpot')
          .child(touristId)
          .child('activities')
          .get();

      if (snapshot.exists) {
        final activities = (snapshot.value as List<dynamic>).map((activity) {
          return {
            "title": activity['title']?.toString() ?? "Untitled",
            "image": activity['image']?.toString() ?? "",
          };
        }).toList();

        _activitiesNotifier.value = activities;
      } else {
        _activitiesNotifier.value = [];
      }
    } catch (e) {
      print('Error fetching activities: $e');
      _activitiesNotifier.value = [];
    }
  }



  Widget _getDynamicContent() {
    final BookingController bookingController = Get.put(BookingController());

    return Container(
      height: 340,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: _currentPage == 0
          ? Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 300,
              width: double.infinity,
              child: Image.network(widget.spot.imageUrl, fit: BoxFit.fill)),
          const SizedBox(height: 10),

          ValueListenableBuilder<String>(
            valueListenable: _availableHourNotifier,
            builder: (context, availableHour, child) {
              return Text(
                "Available Hours: $availableHour",
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            },
          ),
        ],
      )
          : _currentPage == 1
          ? Column(
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
                        "Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                        style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _userBookings[selectedDate] ?? "Available.",
                        style: GoogleFonts.comfortaa(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ValueListenableBuilder<String>(
                        valueListenable: _availableHourNotifier,
                        builder: (context, availableHour, child) {
                          return Text(
                            "Visiting Hours: $availableHour",
                            style: GoogleFonts.comfortaa(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                      Text(
                        "Activities:",
                        style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<List<Map<String, String>>>(
                          valueListenable: _activitiesNotifier,
                          builder: (context, activities, child) {
                            if (activities.isEmpty) {
                              return Text(
                                "No activities available",
                                style: GoogleFonts.comfortaa(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: activities.map((activity) {
                                return Text(
                                  "- ${activity['title']}",
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: GestureDetector(
              onTap: _showCalendarDialog,
              child: Container(
                height: 50,
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
          : Obx(() => bookingController.selectedActivityImage.value.isNotEmpty
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
                    _fetchAvailableHour();
                    _fetchActivities();
                    _selectedDateNotifier.value = selectedDay;
                    Navigator.pop(context);
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
        return BookingPage(
          spot: widget.spot,
          fullnameController: _fullnameController,
          contactNumberController: _contactNumberController,
          emailController: _emailController,
          numberOfPeopleController: _numberOfPeopleController,
          databaseRef: _databaseRef,
          auth: _auth,
          selectedDate: selectedDate,
        );
      },
    ),
    ActivitiesPage(
      spot: widget.spot,
      onActivitySelected: (String selectedActivityImage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    if (label == 'Booking' && !(widget.spot.name == 'Olo Olo Mangrove Forest' || widget.spot.name == 'Lagadlarin Mangrove Forest' || widget.spot.name == 'Mt. Nalayag')) {
      return SizedBox.shrink();
    }

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
