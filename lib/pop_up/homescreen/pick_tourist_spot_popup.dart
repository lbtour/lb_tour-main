import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class TouristSpotPicker {
  static Future<void> initializePermissions() async {
    // Request location permissions at app startup
    await _requestLocationPermission();
  }

  static Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (status.isPermanentlyDenied) {
        openAppSettings();  // Direct user to app settings if permanently denied
      }
    }
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Pick a Tourist Spot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Eiffel Tower'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TouristSpotDetailPage(
                          name: 'Eiffel Tower',
                          latitude: 48.8584,
                          longitude: 2.2945,
                          imageUrl: 'https://link_to_eiffel_tower_image',
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Great Wall of China'),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TouristSpotDetailPage(
                          name: 'Great Wall of China',
                          latitude: 40.4319,
                          longitude: 116.5704,
                          imageUrl: 'https://link_to_great_wall_image',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class TouristSpotDetailPage extends StatelessWidget {
  final String name;
  final double latitude;
  final double longitude;
  final String imageUrl;

  const TouristSpotDetailPage({
    Key? key,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          Image.network(imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _openMap(context, latitude, longitude),
            child: Text('Get Directions'),
          ),
        ],
      ),
    );
  }

  Future<void> _openMap(BuildContext context, double latitude, double longitude) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: availableMaps.map((map) {
              return ListTile(
                leading: Image.asset(
                  map.icon,
                  height: 40,
                  width: 40,
                ),
                title: Text(map.mapName),
                onTap: () {
                  map.showDirections(
                    destination: Coords(latitude, longitude),
                  );
                  Navigator.pop(context);
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
