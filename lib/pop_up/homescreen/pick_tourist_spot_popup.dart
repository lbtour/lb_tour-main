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
  final String date;
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

  factory TouristSpot.fromMap(String id, Map<dynamic, dynamic> data) {
    return TouristSpot(
      id: id,
      name: data['touristName'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? 'No description available',
      date: data['date'] ?? 'N/A',
      price: data['price'] ?? '0',
    );
  }
}

class TouristSpotService {
  static Future<void> openMap(BuildContext context, String address, String name) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose a map',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...availableMaps.map((map) {
                // Assign the custom icons based on the map name
                String iconPath;
                if (map.mapName.toLowerCase().contains('google')) {
                  iconPath = 'assets/images/maps_icon/google_maps.png';
                } else if (map.mapName.toLowerCase().contains('waze')) {
                  iconPath = 'assets/images/maps_icon/waze.png';
                } else {
                  iconPath = ''; // Fallback for unknown map apps
                }

                return ListTile(
                  leading: iconPath.isNotEmpty
                      ? Image.asset(
                    iconPath,
                    width: 32, // Set the desired width
                    height: 32, // Set the desired height
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.map), // Default icon for unsupported apps
                  title: Text(map.mapName),
                  onTap: () async {
                    Navigator.pop(context); // Close modal
                    try {
                      // Extract coordinates from the location string
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

  static Future<List<TouristSpot>> fetchTouristSpots() async {
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
