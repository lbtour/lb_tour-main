import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class TouristSpotDetailPage extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String location; // Add location as a string variable

  const TouristSpotDetailPage({
    Key? key,
    required this.name,
    required this.imageUrl,
    required this.location, // Initialize location
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Image.network(
              imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _openMap(context, location),
            // Pass location to _openMap
            child: Text('Get Directions'),
          ),
        ],
      ),
    );
  }


  Future<void> _openMap(BuildContext context, String location) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: availableMaps.map((map) {
              return ListTile(
                title: Text(map.mapName), // Show the name of the map (no icon)
                onTap: () async {
                  Navigator.pop(context); // Close the modal
                  print(
                      'Location being passed: $location'); // Debug: Print the location string

                  try {
                    // Parse the coordinates from the location string
                    final uri = Uri.parse(location);
                    final regex = RegExp(
                        r'@([-+]?[0-9]*\.?[0-9]+),([-+]?[0-9]*\.?[0-9]+)');
                    final match = regex.firstMatch(uri.toString());

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
                          SnackBar(content: Text('Invalid coordinates.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                            'Coordinates not found in the location URL.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error parsing location: $e')),
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
        SnackBar(content: Text('No available map applications.')),
      );
    }
  }
}