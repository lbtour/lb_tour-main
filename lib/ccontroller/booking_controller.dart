import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  // Reactive variable to track the selected booking status
  var selectedStatus = 'Pending'.obs;
  var selectedActivityImage = ''.obs;

  // Dynamic booking data grouped by status
  final bookings = {
    'Pending': <Map<String, String>>[],
    'Approved': <Map<String, String>>[],
    'Finished': <Map<String, String>>[],
    'Cancelled': <Map<String, String>>[],
  }.obs;

  // Firebase database reference
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserBookings();
  }



  Future<void> fetchUserBookings() async {
    try {
      // Step 1: Get the current user's UID from Firebase Auth
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("Error: No authenticated user found.");
        return;
      }
      final userId = currentUser.uid;
      print("Fetched UID from Firebase Auth: $userId");

      // Step 2: Access the user's bookings in Firebase Realtime Database
      print("Fetching bookings for user: $userId from Firebase...");
      final snapshot = await databaseRef.child('Booking').child(userId).get();

      if (!snapshot.exists) {
        print("No bookings found for user: $userId");
        return;
      }

      print("Raw data fetched from Firebase:");
      print(snapshot.value);

      // Step 3: Clear existing bookings
      bookings.forEach((key, value) => value.clear());
      print("Cleared existing bookings in controller.");

      // Step 4: Parse data and group by status
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        if (value is Map) {
          // Safely parse fields
          final booking = Map<String, dynamic>.from(value);
          final status = booking['status']?.toString() ?? 'Pending'; // Default to 'Pending'
          final touristName = booking['touristName']?.toString() ?? 'Unknown Booking';
          final selectedDate = booking['selectedDate']?.toString();

          if (selectedDate == null || selectedDate.isEmpty) {
            print("Warning: Booking $key has an invalid or missing 'selectedDate'. Skipping...");
            return; // Skip invalid booking
          }

          print("Processing booking ID: $key with status: $status");

          if (bookings.containsKey(status)) {
            bookings[status]?.add({
              'title': touristName,
              'date': selectedDate,
            });
            print("Added booking to $status group: ${bookings[status]?.last}");
          }
        }
      });

      // Step 5: Refresh bookings to update the UI
      bookings.refresh();
      print("Updated bookings in controller:");
      print(bookings);

      print("User bookings fetched successfully.");
    } catch (error) {
      print("Error fetching user bookings: $error");
    }
  }

  void updateSelectedActivityImage(String imageUrl) {
    selectedActivityImage.value = imageUrl;
  }
}
