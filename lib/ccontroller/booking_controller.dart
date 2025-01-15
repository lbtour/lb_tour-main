import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  // Reactive variable to track the selected booking status
  var selectedStatus = 'Cancelled'.obs;
  var selectedActivityImage = ''.obs;

  // Reactive booking data grouped by status
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
    fetchUserBookings(); // Fetch bookings when the controller is initialized
  }

  /// Fetch user bookings from Firebase
  Future<void> fetchUserBookings() async {
    try {
      // Get the current user's UID
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("Error: No authenticated user found.");
        return;
      }
      final userId = currentUser.uid;

      print("Fetching bookings for user: $userId from Firebase...");
      final snapshot = await databaseRef.child('Booking').child(userId).get();

      if (!snapshot.exists) {
        print("No bookings found for user: $userId");
        return;
      }

      print("Raw data fetched from Firebase:");
      print(snapshot.value);

      // Clear existing bookings
      bookings.forEach((key, value) => value.clear());

      // Parse data and group by status
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        if (value is Map) {
          final booking = Map<String, dynamic>.from(value);

          // Extract and validate booking fields
          final date = booking['date']?.toString() ?? 'N/A';
          final status = booking['status']?.toString() ?? 'Pending';
          final touristName = booking['touristName']?.toString() ?? 'Unknown Booking';
          final fullname = booking['fullname']?.toString() ?? 'N/A';
          final contactNumber = booking['contactNumber']?.toString() ?? 'N/A';
          final price = booking['price']?.toString() ?? 'N/A';
          final numberOfPeople = booking['numberOfPeople']?.toString() ?? 'N/A';
          final address = booking['address']?.toString() ?? 'N/A';
          final description = booking['description']?.toString() ?? 'No details available';
          final email = booking['email']?.toString() ?? 'N/A';
          final imageUrl = booking['imageUrl']?.toString() ?? '';

          if (date == 'N/A' || date.isEmpty) {
            print("Warning: Booking $key has an invalid or missing 'date'. Skipping...");
            return; // Skip invalid booking
          }

          print("Processing booking ID: $key with status: $status");

          // Add booking to the appropriate status group
          if (bookings.containsKey(status)) {
            bookings[status]?.add({
              'id': key,
              'title': touristName,
              'date': date,
              'fullname': fullname,
              'contactNumber': contactNumber,
              'price': price,
              'numberOfPeople': numberOfPeople,
              'address': address,
              'description': description,
              'email': email,
              'imageUrl': imageUrl,
            });
            print("Added booking to $status group: ${bookings[status]?.last}");
          }
        }
      });

      // Print all bookings grouped by status
      print("Bookings grouped by status:");
      bookings.forEach((status, bookingsList) {
        print("Status: $status");
        for (var booking in bookingsList) {
          print(booking);
        }
      });

      // Refresh bookings to update the UI
      bookings.refresh();
      print("User bookings fetched successfully.");
    } catch (error) {
      print("Error fetching user bookings: $error");
    }
  }

  /// Update the selected activity image
  void updateSelectedActivityImage(String imageUrl) {
    selectedActivityImage.value = imageUrl;
  }
}
