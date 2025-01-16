import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lb_tour/screens/discover/booking.dart';

import '../../models/tourist_spot/tourist_spot_model.dart';

class Activity {
  final String title;
  final String image;

  Activity({
    required this.title,
    required this.image,
  });

  factory Activity.fromMap(Map<dynamic, dynamic> map) {
    return Activity(
      title: map['title'] ?? '',
      image: map['image'] ?? '',
    );
  }
}


class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<TouristSpot> touristSpots = [];

  @override
  void initState() {
    super.initState();
    fetchTouristSpots();
  }

  Future<void> fetchTouristSpots() async {
    DatabaseReference databaseRef =
    FirebaseDatabase.instance.ref().child('TouristSpot');

    try {
      final snapshot = await databaseRef.once();
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          touristSpots = data.entries
              .map((entry) => TouristSpot.fromMap(entry.key as String, entry.value as Map<dynamic, dynamic>))
              .toList();
        });
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
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
            child: Card(
              color: Colors.white,
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.network(
                        spot.imageUrl,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spot.name,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                '₱${spot.price}/Person',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
