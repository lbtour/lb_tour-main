import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';

class TouristSpotPicker {
  static Future<void> show(BuildContext context) async {
    final spots = await _fetchTouristSpots();

    if (spots.isEmpty) {
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
                      _showAvailableMaps(context, spot.address, spot.name);
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showAvailableMaps(BuildContext context, String location, String name) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: availableMaps.map((map) {
              return ListTile(
                leading: Icon(Icons.map),
                title: Text(map.mapName),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    // Parse coordinates from the location string
                    final regex = RegExp(r'@([-+]?[0-9]*\.?[0-9]+),([-+]?[0-9]*\.?[0-9]+)');
                    final match = regex.firstMatch(location);

                    if (match != null) {
                      final latitude = double.tryParse(match.group(1) ?? '');
                      final longitude = double.tryParse(match.group(2) ?? '');

                      if (latitude != null && longitude != null) {
                        await map.showDirections(
                          destination: Coords(latitude, longitude),
                          destinationTitle: name,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid coordinates.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coordinates not found.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              );
            }).toList(),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available map applications.')),
      );
    }
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
      return data.entries
          .map((entry) => TouristSpot.fromMap(
        entry.key as String,
        entry.value as Map<dynamic, dynamic>,
      ))
          .toList();
    } else {
      print('Data is null or empty in TouristSpot folder.');
      return [];
    }
  }
}
