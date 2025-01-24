import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lb_tour/screens/account/account.dart';
import 'package:lb_tour/screens/discover/discover.dart';
import 'package:lb_tour/screens/home/home.dart';
import 'package:lb_tour/screens/home/notification.dart';
import 'package:lb_tour/screens/likes/likes.dart';
import 'dart:io'; // Import for exit(0)
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
import 'package:lb_tour/screens/weather/weather.dart';

import 'ccontroller/booking_controller.dart';

class TabNavigation extends StatefulWidget {
  final int initialIndex;
  final String? selectedStatus;

  TabNavigation({super.key, this.initialIndex = 0, this.selectedStatus});

  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(length: 5, vsync: this, initialIndex: _selectedIndex);
    Get.put(BookingController());

    _tabController.addListener(() {
      if (_tabController.index != _selectedIndex) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  Future<void> markAllBookingsAsRead(String userId) async {
    DatabaseEvent event = await _database.child('Booking').child(userId).once();

    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> bookings =
      Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      for (var bookingId in bookings.keys) {
        await _database.child('Booking').child(userId).child(bookingId).update({
          'isActive': false,
        });
      }
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Color.fromARGB(255, 14, 86, 170),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Exit App",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Are you sure you want to exit?",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (Platform.isAndroid) {
                            SystemNavigator.pop(); // Proper exit for Android
                          } else if (Platform.isIOS) {
                            exit(0); // Force close for iOS
                          }
                        },
                        icon: const Icon(Icons.exit_to_app, color: Colors.white),
                        label: Text(
                          "Exit",
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 14, 86, 170),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
            _tabController.animateTo(0);
          });
        } else {
          bool shouldExit = await _showExitConfirmationDialog();
          if (shouldExit) {
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          }
        }
      },
      child: SafeArea(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedLocation01,
                          color: Color.fromARGB(255, 14, 86, 170),
                          size: 24.0,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Lobo, Batangas',
                          style: GoogleFonts.roboto(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                StreamBuilder<DatabaseEvent>(
                  stream: _database.child('Booking').child(_auth.currentUser?.uid ?? '').onValue,
                  builder: (context, snapshot) {
                    bool hasNotification = false;

                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      Map<dynamic, dynamic> bookings =
                      Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                      for (var bookingId in bookings.keys) {
                        if (bookings[bookingId]['isActive'] == true) {
                          hasNotification = true;
                          break;
                        }
                      }
                    }

                    return GestureDetector(
                      onTap: () async {
                        if (_auth.currentUser != null) {
                          await markAllBookingsAsRead(_auth.currentUser!.uid);
                        }
                       Get.to(
                            () => const NotificationScreen(),

                        );
                      },
                      child: Stack(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedNotification01,
                            color: Colors.black,
                            size: 24.0,
                          ),
                          if (hasNotification)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                HomeScreen(),
                DiscoverScreen(),
                WeatherScreen(),
                TopRatedScreen(),
                AccountPage(selectedStatus: widget.selectedStatus),
              ],
            ),
            bottomNavigationBar: Container(
              width: MediaQuery.of(context).size.width, // Ensures full width
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                    _tabController.animateTo(index);
                  });
                },
                selectedItemColor: const Color.fromARGB(255, 14, 86, 170),
                unselectedItemColor: Colors.black,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed, // Ensures all items are always visible
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedHome13, size: 24.0),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedDiscoverCircle, size: 24.0),
                    label: "Discover",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedSunCloudAngledRain02, size: 24.0),
                    label: "Weather",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(HugeIcons.strokeRoundedThumbsUp, size: 24.0),
                    label: "Top-Rated",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_3, size: 24.0),
                    label: "Account",
                  ),
                ],
              ),
            ),


          ),
        ),
      ),
    );
  }
}
