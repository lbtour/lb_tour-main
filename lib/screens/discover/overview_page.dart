import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lb_tour/screens/discover/panorama_view.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';

class OverviewPage extends StatelessWidget {
  final TouristSpot spot;

  const OverviewPage({Key? key, required this.spot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(spot.name,
              style: GoogleFonts.comfortaa(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => _openMap(context, spot.address, spot.name),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 14, 86, 170),
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Get Directions",
                  style: GoogleFonts.comfortaa(
                      fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ),
          const Divider(),
          Text("BACKGROUND",
              style: GoogleFonts.comfortaa(
                  fontSize: 14, fontWeight: FontWeight.w900)),
          Text(spot.description,
              style: GoogleFonts.comfortaa(fontSize: 12),
              textAlign: TextAlign.justify),
          const Divider(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text('₱${spot.price}/Person',
                style: GoogleFonts.comfortaa(
                    fontSize: 14, color: const Color.fromARGB(255, 14, 86, 170))),
          ),
          const Divider(),
          Text("Virtual Tour",
              style: GoogleFonts.comfortaa(
                  fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Column(
            children: spot.virtualImages.map((imageUrl) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PanoramaPage(imageUrl: imageUrl),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Text(
                              "Tap here to view VR Tour",
                              style: GoogleFonts.comfortaa(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

Future<void> _openMap(BuildContext context, String location, String name) async {
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
                  final regex = RegExp(
                      r'@([-+]?[0-9]*\.?[0-9]+),([-+]?[0-9]*\.?[0-9]+)');
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
                      const SnackBar(
                          content: Text(
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
      const SnackBar(content: Text('No available map applications.')),
    );
  }
}
