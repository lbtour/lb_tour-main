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
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(length: 5, vsync: this, initialIndex: _selectedIndex);
    Get.put(BookingController());

    // Listen for changes and update _selectedIndex
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
            insetPadding: EdgeInsets.zero, // Remove padding
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
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

                    // Message
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

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Exit Button
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(true),
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

                        // Cancel Button
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
          ),
        );
      },
    ) ?? false;
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default back navigation
      onPopInvoked: (didPop) async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0; // Reset to Home tab
            _tabController.animateTo(0); // Update TabController
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
                          style: GoogleFonts.roboto(fontSize: 14, color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.bottomCenter,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                    primaryColor: Colors.white,
                    textTheme: Theme.of(context).textTheme.copyWith(
                      bodySmall: GoogleFonts.roboto(color: Colors.black),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    unselectedLabelColor: Colors.black,
                    labelColor: const Color.fromARGB(255, 14, 86, 170),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 14, 86, 170)),
                      insets: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    labelStyle: GoogleFonts.roboto(),
                    tabs: const [
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedHome13,
                          color: Colors.black,
                        ),
                        text: "Home",
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDiscoverCircle,
                          color: Colors.black,
                        ),
                        text: "Discover",
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedSunCloudAngledRain02,
                          color: Colors.black,
                        ),
                        text: "Weather",
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedThumbsUp,
                          color: Colors.black,
                        ),
                        text: "Top-Rated",
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: Icons.person_3,
                          color: Colors.black,
                        ),
                        text: "Account",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
