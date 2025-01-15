import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';

class TouristSpot {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String description;
  final String date; // Replaced formattedDate with date
  final String price;

  TouristSpot({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.description,
    required this.date,
    required this.price,
  });

  // fromMap method to parse data from Firebase
  factory TouristSpot.fromMap(String id, Map<dynamic, dynamic> data) {
    return TouristSpot(
      id: id,
      name: data['name'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? 'No description available',
      date: data['date'] ?? 'N/A', // Directly map the date field
      price: data['price'] ?? 'N/A',
    );
  }
}

class TouristSpotPicker {
  static Future<void> show(BuildContext context) async {
    final spots = await _fetchTouristSpots();

    if (spots.isEmpty) {
      // Show dialog if no tourist spots are available
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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

    // Show tourist spots in a dialog
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
                      // Show spot details in a dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(spot.name),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${spot.name}'),
                                const SizedBox(height: 8),
                                Text('Address: ${spot.address}'),
                                const SizedBox(height: 8),
                                Text('Price: ${spot.price}'),
                                const SizedBox(height: 8),
                                Text('Description: ${spot.description}'),
                                const SizedBox(height: 8),
                                Text('Date Added: ${spot.date}'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            // Display network image with fallback
                            Image.network(
                              spot.imageUrl.isNotEmpty
                                  ? spot.imageUrl
                                  : 'https://via.placeholder.com/150',
                              fit: BoxFit.cover,
                              height: 150,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: Colors.grey,
                                  child: Center(
                                    child: Icon(Icons.error, color: Colors.white),
                                  ),
                                );
                              },
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
                                    const SizedBox(height: 5),
                                    Text(
                                      'Date Added: ${spot.date}',
                                      style: GoogleFonts.comfortaa(
                                        color: Colors.white70,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<List<TouristSpot>> _fetchTouristSpots() async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('TouristSpot');
    final snapshot = await databaseRef.get();

    if (!snapshot.exists) {
      print('No data found in the TouristSpot folder.');
      return [];
    }

    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      return data.entries.map((entry) {
        final spotData = entry.value as Map<dynamic, dynamic>;

        return TouristSpot.fromMap(
          entry.key as String,
          spotData,
        );
      }).toList();
    } else {
      print('Data is null or empty in TouristSpot folder.');
      return [];
    }
  }
}
