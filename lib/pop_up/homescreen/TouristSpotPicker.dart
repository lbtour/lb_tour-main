import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../models/tourist_spot/tourist_spot_model.dart';

class TouristSpotPicker {
  static Future<void> show(BuildContext context) async {
    final spots = await _fetchTouristSpots();


      // Show full-screen dialog with blue title background
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20.0,150,20,100),
          child: Container(
            decoration: BoxDecoration(
            ),
            child: Dialog(
              insetPadding: EdgeInsets.zero, // No padding
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.9,
                color: Colors.white,
                child: Column(
                  children: [
                    // Title with Blue Background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color.fromARGB(255, 14, 86, 170),
                      child: Text(
                        'Pick a Tourist Spot',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: spots.length,
                        itemBuilder: (context, index) {
                          final spot = spots[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                _openMap(context, spot.address, spot.name);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Stack(
                                  children: [
                                    // Background Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        spot.imageUrl.isNotEmpty
                                            ? spot.imageUrl
                                            : 'https://via.placeholder.com/150',
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 150,
                                            width: double.infinity,
                                            color: Colors.grey,
                                            child: const Center(
                                              child: Icon(Icons.error, color: Colors.white),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Positioned Name Overlay
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        color: Colors.black.withOpacity(0.5),
                                        child: Text(
                                          spot.name,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10,),
                    // Close Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 14, 86, 170),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),

                    ),
                    SizedBox(height: 5,),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> _openMap(BuildContext context, String address, String name) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose a Map',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...availableMaps.map((map) {
                String iconPath;
                if (map.mapName.toLowerCase().contains('google')) {
                  iconPath = 'assets/images/maps_icon/google maps.png';
                } else if (map.mapName.toLowerCase().contains('waze')) {
                  iconPath = 'assets/images/maps_icon/waze.png';
                } else {
                  iconPath = ''; // Fallback for unknown apps
                }

                return ListTile(
                  leading: iconPath.isNotEmpty
                      ? Image.asset(
                    iconPath,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.map),
                  title: Text(map.mapName),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final regex = RegExp(r'@([-+]?[0-9]*\.?[0-9]+),([-+]?[0-9]*\.?[0-9]+)');
                      final match = regex.firstMatch(address);

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
            ],
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
      return data.entries.map((entry) {
        final spotData = entry.value as Map<dynamic, dynamic>;
        return TouristSpot.fromMap(entry.key as String, spotData);
      }).toList();
    } else {
      print('Data is null or empty in TouristSpot folder.');
      return [];
    }
  }
}
