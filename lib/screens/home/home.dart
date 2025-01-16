import 'dart:async'; // For Timer
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/tourist_spot/tourist_spot_model.dart';
import '../../pop_up/homescreen/TouristSpotPicker.dart';
import '../discover/booking.dart';
import '../../pop_up/homescreen/pick_tourist_spot_popup.dart' as popup;



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TouristSpot> touristSpots = [];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  final TextEditingController searchController = TextEditingController();
  late Timer _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    fetchTouristSpots();
    searchController.addListener(filterResults);

    // Start auto-scrolling
    _startAutoScroll();
  }

  @override
  void dispose() {
    // Dispose of the controller and timer to avoid memory leaks
    _pageController.dispose();
    _autoScrollTimer.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchTouristSpots() async {
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child('TouristSpot');

    try {
      final snapshot = await databaseRef.once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          touristSpots = data.entries
              .map((entry) => TouristSpot.fromMap(
            entry.key as String, // Pass ID
            entry.value as Map<dynamic, dynamic>, // Pass map data
          ))
              .toList();
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }


  void filterResults() {
    final query = searchController.text.toLowerCase();
    setState(() {
      touristSpots = touristSpots
          .where((spot) => spot.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && touristSpots.isNotEmpty) {
        final nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage < touristSpots.length) {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          // Loop back to the first page
          _pageController.jumpToPage(0);
        }
      }
    });
  }

  Widget buildCarousel() {
    return touristSpots.isNotEmpty
        ? SizedBox(
      height: 450,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: PageView.builder(
        controller: _pageController,
        itemCount: touristSpots.length,
        itemBuilder: (context, index) {
          final spot = touristSpots[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(spot: spot),
                ),
              );
            },
            child: Column(
              children: [
                // Carousel Image
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.45,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      spot.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Tourist Spot Name
                Text(
                  spot.name,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(255, 14, 86, 170),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    )
        : const Center(
      child: CircularProgressIndicator(
        color: Color.fromARGB(255, 14, 86, 170),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/header.jpg',
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              'Where do you want to go?',
                              style: GoogleFonts.roboto(
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => TouristSpotPicker.show(context),
                              child: Container(
                                width: 220,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Card(
                                  elevation: 6,
                                  child: Container(
                                    decoration: BoxDecoration(

                                    ),
                                    height: 50,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        "Pick Tourist Spot",
                                        style:  GoogleFonts.roboto(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Carousel Section
                  buildCarousel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

