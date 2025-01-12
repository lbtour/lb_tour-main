import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';
import '../models/feedback/user_feedback_model.dart';

class TouristSpotController extends GetxController {
  final touristSpots = <TouristSpot>[].obs;
  final selectedSpot = Rxn<TouristSpot>();
  final feedbacks = <String, List<UserFeedback>>{}
      .obs; // Map of feedbacks by spot ID
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child(
      'TouristSpot');
  final DatabaseReference feedbackRef = FirebaseDatabase.instance.ref().child(
      'UserFeedback');
  final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child(
      'users'); // For fetching user details

  final fullName = ''
      .obs; // Observable for storing the full name of the current user

  @override
  void onInit() {
    super.onInit();
    fetchTouristSpots();
    fetchCurrentUserFullName();
  }

  Future<void> fetchTouristSpots() async {
    try {
      final snapshot = await databaseRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final spots = data.entries
            .map((e) => TouristSpot.fromMap(e.key, e.value))
            .toList();

        spots.sort((a, b) => b.likes.compareTo(a.likes));
        touristSpots.value = spots;

        if (spots.isNotEmpty) {
          selectedSpot.value = spots.first;
        }
      }
    } catch (e) {
      print("Error fetching tourist spots: $e");
    }
  }

  void selectSpot(TouristSpot spot) {
    selectedSpot.value = spot;
    fetchFeedbackForSpot(spot.id);
  }

  Future<void> fetchFeedbackForSpot(String spotId) async {
    try {
      final snapshot = await feedbackRef.child(spotId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final List<UserFeedback> feedbackList = [];
          for (var entry in data.entries) {
            final userId = entry.key; // User ID
            final feedbackMessage = entry.value; // Feedback message

            // Fetch user details from the 'users' node
            final userSnapshot = await usersRef.child(userId).get();

            String fullName = userId; // Default to userId if user details are missing

            if (userSnapshot.exists) {
              final userData = userSnapshot.value as Map<dynamic, dynamic>?;
              if (userData != null) {
                final firstName = userData['firstName'] ??
                    ''; // Fetch firstName
                final lastName = userData['lastName'] ?? ''; // Fetch lastName
                fullName = (firstName.isNotEmpty || lastName.isNotEmpty)
                    ? '$firstName $lastName'
                    : userId; // Construct fullName or fallback to userId
              }
            }

            // Add feedback to the list
            feedbackList.add(
                UserFeedback(fullName: fullName, message: feedbackMessage));
          }
          feedbacks[spotId] = feedbackList;
        }
      }
    } catch (e) {
      print("Error fetching feedback for spot $spotId: $e");
    }
  }

  Future<String> getUserFullName(String userId) async {
    try {
      final snapshot = await usersRef.child(userId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final firstName = data['firstName'] ?? '';
        final lastName = data['lastName'] ?? '';
        return '$firstName $lastName';
      } else {
        return 'Unknown User'; // Fallback if user data doesn't exist
      }
    } catch (e) {
      print('Error fetching user full name: $e');
      return 'Unknown User';
    }
  }

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

  void addOrEditFeedback(String spotId, String feedback) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    feedbackRef.child(spotId).update({userId: feedback});
    fetchFeedbackForSpot(spotId); // Refresh feedbacks after adding/editing
  }

  List<UserFeedback>? getFeedbackForSpot(String spotId) {
    return feedbacks[spotId];
  }

  Future<bool> doesUserHaveFeedback(String spotId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return false; // User is not logged in
    }

    // Step 1: Fetch the user's full name from the Realtime Database
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child(
        'users').child(userId);
    try {
      final snapshot = await usersRef.get();
      if (!snapshot.exists) {
        return false; // User's data does not exist
      }

      final userData = snapshot.value as Map<dynamic, dynamic>?;
      if (userData == null) {
        return false; // No user data found
      }

      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim(); // Construct full name

      // Step 2: Fetch the feedbacks for the given spot
      final spotFeedbacks = feedbacks[spotId];

      if (spotFeedbacks != null) {
        // Step 3: Check if the user's full name matches any feedback's fullName
        return spotFeedbacks.any((feedback) => feedback.fullName == fullName);
      }
    } catch (e) {
      print('Error fetching user data or feedback: $e');
      return false; // Handle errors gracefully
    }

    return false; // No feedbacks or no match found
  }
}