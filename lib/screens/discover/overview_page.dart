import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lb_tour/screens/discover/panorama_view.dart';
import 'package:map_launcher/map_launcher.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';

class OverviewPage extends StatefulWidget {
  final TouristSpot spot;

  const OverviewPage({Key? key, required this.spot}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool isLiked = false; // Track if the user has liked this spot
  bool isLoading = true; // To show loading state initially

  @override
  void initState() {
    super.initState();
    _fetchLikeStatus();
  }

  Future<void> _fetchLikeStatus() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      setState(() {
        isLiked = false;
        isLoading = false;
      });
      return;
    }

    try {
      final likeSnapshot = await _database
          .child('UserLikes')
          .child(userId)
          .child(widget.spot.id)
          .get();

      setState(() {
        isLiked = likeSnapshot.value == true;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching like status: $e');
      setState(() {
        isLiked = false;
        isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to log in to like this spot.')),
      );
      return;
    }

    try {
      setState(() {
        isLiked = !isLiked;

        // Update local count
        if (isLiked) {
          widget.spot.likes++;
        } else {
          widget.spot.likes--;
        }
      });

      // Update Firebase
      await _database
          .child('UserLikes')
          .child(userId)
          .child(widget.spot.id)
          .set(isLiked);

      // Update the tourist spot's likes count in Firebase
      await _database
          .child('TouristSpots')
          .child(widget.spot.id)
          .child('likes')
          .set(widget.spot.likes);
    } catch (e) {
      print('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update like status.')),
      );

      // Revert the state on failure
      setState(() {
        if (isLiked) {
          widget.spot.likes--;
        } else {
          widget.spot.likes++;
        }
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.spot.name,
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : IconButton(
                onPressed: _toggleLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${widget.spot.likes} Likes',
            style: GoogleFonts.comfortaa(fontSize: 14, color: Colors.black),
          ),
          const Divider(),
          GestureDetector(
            onTap: () =>
                _openMap(context, widget.spot.address, widget.spot.name),
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
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Text(
            "BACKGROUND",
            style: GoogleFonts.comfortaa(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            widget.spot.description,
            style: GoogleFonts.comfortaa(fontSize: 12),
            textAlign: TextAlign.justify,
          ),
          const Divider(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '₱${widget.spot.price}/Person',
              style: GoogleFonts.comfortaa(
                fontSize: 14,
                color: const Color.fromARGB(255, 14, 86, 170),
              ),
            ),
          ),
          const Divider(),
          Text(
            [
              "olo olo mangrove forest",
              "mt. nalayag",
              "lagadlarin mangrove forest"
            ]
                .contains(widget.spot.name.toLowerCase().trim())
                ? "Virtual Tour"
                : "Images",
            style: GoogleFonts.comfortaa(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: widget.spot.virtualImages.map<Widget>((imageUrl) {
              return GestureDetector(
                onTap: [
                  "olo olo mangrove forest",
                  "mt. nalayag",
                  "lagadlarin mangrove forest"
                ]
                    .contains(widget.spot.name.toLowerCase().trim())

                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PanoramaPage(imageUrl: imageUrl),
                    ),
                  );
                }
                    : () {
                  _showImagePopup(context, imageUrl);
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
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                    (progress.expectedTotalBytes ?? 1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey,
                              child: Center(
                                child: Text(
                                  "Failed to load image",
                                  style: GoogleFonts.comfortaa(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Text(
                              [
                                "olo olo mangrove forest",
                                "mt. nalayag",
                                "lagadlarin mangrove forest"
                              ]
                                  .contains(
                                  widget.spot.name.toLowerCase().trim())

                                  ? "Tap here to view VR Tour"
                                  : "Tap here for more details",
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
              leading: Icon(Icons.map),
              title: Text(map.mapName),
              onTap: () async {
                Navigator.pop(context);
                try {
                  // Extract coordinates from the location string
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





void _showImagePopup(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    height: 200,
                    width: double.infinity,
                    child: const Center(
                      child: Text("Failed to load image."),
                    ),
                  );
                },
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        ),
      );
    },
  );
}

