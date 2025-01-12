import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lb_tour/screens/discover/booking.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';
class TouristSpotPicker {
  static Future<void> show(BuildContext context) async {
    final spots = await _fetchTouristSpots();

    if (spots.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: Text('No Tourist Spots Available'),
              content: Text('There are no tourist spots to display.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close'),
                ),
              ],
            ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a Tourist Spot'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: spots.length,
              itemBuilder: (context, index) {
                final spot = spots[index];
                return Card(
                  elevation: 4,
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(spot: spot),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.network(
                              spot.imageUrl,
                              fit: BoxFit.cover,
                              height: 150,
                              width: double.infinity,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                color: Colors.black.withOpacity(0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      spot.name,
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '₱${spot.price}/Person',
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white,
                                        fontSize: 14,
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<List<TouristSpot>> _fetchTouristSpots() async {
    final DatabaseReference databaseRef =
    FirebaseDatabase.instance.ref('TouristSpot');
    final snapshot = await databaseRef.get();

    if (!snapshot.exists) {
      print('No data found in the TouristSpot folder.');
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      return data.entries
          .map((entry) =>
          TouristSpot.fromMap(
            entry.key as String, // ID
            entry.value as Map<dynamic, dynamic>, // Data map
          ))
          .toList();
    } else {
      print('Data is null or empty in TouristSpot folder.');
      return [];
    }
  }
}