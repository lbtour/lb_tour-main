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

class TabNavigation extends StatelessWidget {
  final int initialIndex; // To determine which tab to display
  final String? selectedStatus; // Pass selected status

  TabNavigation({super.key, this.initialIndex = 0, this.selectedStatus});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> markAllBookingsAsRead(String userId) async {
    DatabaseEvent event = await _database
        .child('Booking')
        .child(userId) // Navigate to the user's bookings
        .once();

    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> bookings = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      for (var bookingId in bookings.keys) {
        // Update the 'isActive' field to false for all bookings
        await _database.child('Booking').child(userId).child(bookingId).update({
          'isActive': false,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("TabNavigation initialized with selectedStatus: $selectedStatus");

    // Ensure BookingController is initialized here
    Get.put(BookingController());

    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 5,
          initialIndex: initialIndex, // Use the passed initialIndex
          child: Scaffold(
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
                          style: GoogleFonts.comfortaa(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
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
              children: [
                HomeScreen(),
                DiscoverScreen(),
                WeatherScreen(),
                TopRatedScreen(),
                AccountPage(selectedStatus: selectedStatus), // Pass status here
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 60, // Adjust height as needed
                width: MediaQuery.of(context).size.width, // Set width to device width
                alignment: Alignment.bottomCenter,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: const Color.fromARGB(255, 255, 255, 255),
                    primaryColor: Colors.white,
                    textTheme: Theme.of(context).textTheme.copyWith(
                      bodySmall: GoogleFonts.comfortaa(color: Colors.black),
                    ),
                  ),
                  child: TabBar(
                    padding: const EdgeInsets.all(0),
                    tabAlignment: TabAlignment.center,
                    unselectedLabelColor: Colors.black,
                    labelColor: const Color.fromARGB(255, 14, 86, 170),
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                          width: 2.0, color: Color.fromARGB(255, 14, 86, 170)),
                      insets: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    labelStyle: GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                    tabs: const [
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedHome13,
                          color: Colors.black,
                        ),
                        child: Text(
                          "Home",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDiscoverCircle,
                          color: Colors.black,
                        ),
                        child: Text(
                          "Discover",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedSunCloudAngledRain02,
                          color: Colors.black,
                        ),
                        child: Text(
                          "Weather",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedThumbsUp,
                          color: Colors.black,
                        ),
                        child: Text(
                          "Top-Rated",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      Tab(
                        icon: HugeIcon(
                          icon: Icons.person_3,
                          color: Colors.black,
                        ),
                        child: Text(
                          "Account",
                          style: TextStyle(fontSize: 14),
                        ),
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
