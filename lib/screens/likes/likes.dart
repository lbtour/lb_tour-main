import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class UserFeedback {
  final String fullName;
  final String message;

  UserFeedback(this.fullName, this.message);
}

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
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String description;
  final String address;
  final List<Activity> activities;
  final List<String> virtualImages;
  int likes;
  Set<String> likedByUsers;

  TouristSpot({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.address,
    required this.activities,
    required this.virtualImages,
    required this.likes,
    required this.likedByUsers,
  });

  factory TouristSpot.fromMap(String id, Map<dynamic, dynamic> map) {
    return TouristSpot(
      id: id,
      name: map['touristName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: map['price'] ?? '',
      description: map['description'] ?? '',
      address: map['location'] ?? '',
      activities: (map['activities'] as List<dynamic>? ?? [])
          .map((activity) => Activity.fromMap(activity))
          .toList(), // Parse activities as a list of Activity objects
      virtualImages: List<String>.from(map['virtualImages'] ?? []),
      likes: map['likes'] ?? 0, // Initialize likes to 0 if not present
      likedByUsers: Set<String>.from(map['userLikes']?.keys ?? []),
    );
  }
}

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  List<TouristSpot> touristSpots = [];
  DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref().child('TouristSpot');
  DatabaseReference bookingsRef =
      FirebaseDatabase.instance.ref().child('Booking');
  User? currentUser = FirebaseAuth.instance.currentUser;
  Set<String> likedSpots = {};
  Set<String> bookedSpotNames = {};
  Map<String, List<UserFeedback>> spotFeedbacks = {};

  @override
  void initState() {
    super.initState();
    fetchTouristSpots();
    fetchUserLikes();
    fetchUserBookings();
    for (var spot in touristSpots) {
      fetchFeedback(spot.name);
    }
  }

  Future<void> fetchTouristSpots() async {
    databaseRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        touristSpots = data.entries
            .map((e) => TouristSpot.fromMap(e.key, e.value))
            .toList();
      });
    });
  }

  Future<void> fetchFeedback(String spotName) async {
    String sanitizedSpotName = spotName.replaceAll('.', '_');
    DatabaseReference feedbackRef =
        FirebaseDatabase.instance.ref().child('UserFeedback');

    final DatabaseEvent feedbackEvent = await feedbackRef.once();
    final feedbackData =
        feedbackEvent.snapshot.value as Map<dynamic, dynamic>? ?? {};

    List<UserFeedback> feedbackList = [];

    for (var entry in feedbackData.entries) {
      String userId = entry.key;
      Map<dynamic, dynamic> userFeedbacks =
          entry.value as Map<dynamic, dynamic>;

      if (userFeedbacks.containsKey(sanitizedSpotName)) {
        String feedbackMessage = userFeedbacks[sanitizedSpotName];

        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users').child(userId);
        DatabaseEvent userEvent = await userRef.once();

        if (userEvent.snapshot.value != null) {
          final userData = userEvent.snapshot.value as Map<dynamic, dynamic>;
          String fullName = '${userData['firstName']} ${userData['lastName']}';
          feedbackList.add(UserFeedback(fullName, feedbackMessage));
        }
      }
    }

    setState(() {
      spotFeedbacks[spotName] = feedbackList;
    });
  }

  Future<void> fetchUserLikes() async {
    if (currentUser == null) return;

    DatabaseReference likesRef =
        FirebaseDatabase.instance.ref().child('UserLikes/${currentUser!.uid}');
    likesRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        likedSpots = Set<String>.from(data.keys);
      });
    });
  }

  Future<void> fetchUserBookings() async {
    if (currentUser == null) return;

    bookingsRef
        .orderByChild('email')
        .equalTo(currentUser!.email)
        .once()
        .then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        bookedSpotNames = data.values
            .map((e) => e['touristName'] as String)
            .toSet(); // Collect tourist names from bookings
      });
    });
  }

  void likeSpot(TouristSpot spot) {
    if (likedSpots.contains(spot.id)) {
      // Show feedback if already liked
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Already Liked!"),
          content: Text("You have already liked ${spot.name}."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      spot.likes += 1;
      likedSpots.add(spot.id);
      spot.likedByUsers.add(currentUser!.uid); // Add user to liked list
    });

    // Update likes in Firebase
    databaseRef.child(spot.id).update({'likes': spot.likes});
    DatabaseReference userLikesRef =
        FirebaseDatabase.instance.ref().child('UserLikes/${currentUser!.uid}');
    userLikesRef.child(spot.id).set(true); // Mark spot as liked by user

    // Show feedback message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Liked!"),
        content: Text("You liked ${spot.name}!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showFeedbackForm(String spotName) {
    // Sanitize the spot name by replacing restricted characters
    String sanitizedSpotName = spotName.replaceAll('.', '_');

    TextEditingController feedbackController = TextEditingController();

    DatabaseReference userFeedbackRef = FirebaseDatabase.instance
        .ref()
        .child('UserFeedback/${currentUser!.uid}');

    userFeedbackRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      if (data.containsKey(sanitizedSpotName)) {
        // If feedback exists for the same spot, show an alert
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Feedback Already Submitted"),
            content: Text("You have already submitted feedback for $spotName."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      // Show feedback form if no existing feedback
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Feedback for $spotName"),
          content: TextField(
            controller: feedbackController,
            decoration: const InputDecoration(
              hintText: "Write your feedback...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save feedback to Firebase under UserFeedback path
                userFeedbackRef
                    .child(sanitizedSpotName)
                    .set(feedbackController.text);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Feedback submitted for $spotName."),
                ));
              },
              child: const Text("Submit"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      );
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
          bool isBooked = bookedSpotNames.contains(spot.name);

          return GestureDetector(
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
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${spot.likes} Likes',
                          style: GoogleFonts.comfortaa(
                              fontSize: 14, color: Colors.black),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (isBooked) {
                                  showFeedbackForm(spot.name);
                                } else {
                                  likeSpot(spot);
                                }
                              },
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedThumbsUp,
                                color: likedSpots.contains(spot.id)
                                    ? Colors.blue
                                    : Colors.grey,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                showFeedbackForm(spot.name);
                              },
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedMessage01,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ExpansionTile for displaying feedbacks
                  ExpansionTile(
                    title: Text(
                      "Show Feedbacks",
                      style: GoogleFonts.comfortaa(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: spotFeedbacks[spot.name]?.map((feedback) {
                          return ListTile(
                            title: Text(feedback.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(feedback.message),
                          );
                        }).toList() ??
                        [const Text('No feedbacks available')],
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded && spotFeedbacks[spot.name] == null) {
                        fetchFeedback(spot.name);
                      }
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
