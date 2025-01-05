import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lb_tour/screens/discover/booking.dart';

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

class TouristSpot {
  final String name;
  final String imageUrl;
  final String price;
  final String description;
  final String address;
  final List<Activity> activities; // Updated to use the `Activity` class
  final List<String> virtualImages;

  TouristSpot({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.address,
    required this.activities, // Updated for activities
    required this.virtualImages,
  });

  factory TouristSpot.fromMap(Map<dynamic, dynamic> map) {
    return TouristSpot(
      name: map['touristName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] ?? '',
      description: map['description'] ?? '',
      address: map['location'] ?? '', // Adjusted for `location`
      activities: map['activities'] != null
          ? (map['activities'] as List<dynamic>)
              .map((activity) => Activity.fromMap(activity))
              .toList()
          : [],
      virtualImages: List<String>.from(map['virtualImages'] ?? []),
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

    databaseRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        touristSpots = data.values.map((e) => TouristSpot.fromMap(e)).toList();
      });
    });
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
                      Image.network(spot.imageUrl,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity),
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
                              Text(spot.name,
                                  style: GoogleFonts.comfortaa(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('₱${spot.price}/Person',
                                  style: GoogleFonts.comfortaa(
                                      color: Colors.white, fontSize: 16)),
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
