import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';
import '../models/feedback/user_feedback_model.dart';

class TouristSpotController extends GetxController {
  final touristSpots = <TouristSpot>[].obs;
  final selectedSpot = Rxn<TouristSpot>();
  final feedbacks = <String, List<UserFeedback>>{}.obs; // Map of feedbacks by spot ID
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child('TouristSpot');
  final DatabaseReference feedbackRef = FirebaseDatabase.instance.ref().child('UserFeedback');
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users'); // User details

  final fullName = ''.obs; // Observable for storing the full name of the current user

  @override
  void onInit() {
    super.onInit();
    fetchTouristSpots();
    fetchCurrentUserFullName();
  }

  /// ✅ **Fetches all tourist spots and sorts them based on likes**
  Future<void> fetchTouristSpots() async {
    try {
      final snapshot = await databaseRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final spots = data.entries.map((e) => TouristSpot.fromMap(e.key, e.value)).toList();
        spots.sort((a, b) => b.likes.compareTo(a.likes)); // Sort by likes
        touristSpots.value = spots;

        if (spots.isNotEmpty) {
          selectedSpot.value = spots.first; // Select the first spot initially
        }
      }
    } catch (e) {
      print("Error fetching tourist spots: $e");
    }
  }

  /// ✅ **Selects a spot and loads its feedback**
  void selectSpot(TouristSpot spot) {
    selectedSpot.value = spot;
    fetchFeedbackForSpot(spot.id);
  }

  /// ✅ **Fetches feedbacks for a specific spot and updates in real-time**
  void fetchFeedbackForSpot(String spotId) {
    feedbackRef.child(spotId).onValue.listen((event) async {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          final List<UserFeedback> feedbackList = [];

          for (var entry in data.entries) {
            final userId = entry.key;
            final feedbackMessage = entry.value;

            // Fetch user's full name asynchronously
            final fullName = await getUserFullName(userId);

            // Add feedback to the list
            feedbackList.add(UserFeedback(fullName: fullName, message: feedbackMessage));
          }

          // ✅ Update observable feedback map
          feedbacks[spotId] = feedbackList;
        }
      }
    }, onError: (error) {
      print("Error fetching feedback for spot $spotId: $error");
    });
  }

  /// ✅ **Fetch the full name of a user from the database**
  Future<String> getUserFullName(String userId) async {
    try {
      final snapshot = await usersRef.child(userId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        return '$firstName $lastName'.trim();
      } else {
        return 'Unknown User'; // Fallback if user data doesn't exist
      }
    } catch (e) {
      print('Error fetching user full name: $e');
      return 'Unknown User';
    }
  }

  /// ✅ **Fetch current user's full name**
  Future<void> fetchCurrentUserFullName() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      try {
        final name = await getUserFullName(userId);
        fullName.value = name;
      } catch (e) {
        print('Error fetching current user full name: $e');
      }
    }
  }

  void addOrEditFeedback(String spotId, String feedback) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    try {
      // ✅ Update feedback in Firebase
      await feedbackRef.child(spotId).child(userId).set(feedback);

      // ✅ Refresh the local feedback list
      fetchFeedbackForSpot(spotId);

      // ✅ Force UI update
      update();

      print("Feedback added/updated successfully!");
    } catch (e) {
      print("Error adding/editing feedback: $e");
    }
  }


  /// ✅ **Get feedback list for a specific spot**
  List<UserFeedback>? getFeedbackForSpot(String spotId) {
    return feedbacks[spotId];
  }

  /// ✅ **Checks if the user has already given feedback for a specific spot**
  Future<bool> doesUserHaveFeedback(String spotId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false; // User is not logged in

    try {
      // ✅ Fetch user details
      final snapshot = await usersRef.child(userId).get();
      if (!snapshot.exists) return false; // User not found

      final userData = snapshot.value as Map<dynamic, dynamic>?;
      if (userData == null) return false; // No user data

      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim(); // Construct full name

      // ✅ Check if feedback exists for the user
      final spotFeedbacks = feedbacks[spotId];
      if (spotFeedbacks != null) {
        return spotFeedbacks.any((feedback) => feedback.fullName == fullName);
      }
    } catch (e) {
      print('Error fetching user data or feedback: $e');
      return false;
    }

    return false; // No feedback found
  }
}


