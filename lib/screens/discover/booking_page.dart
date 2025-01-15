import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';
import '../../navigation-tab.dart';
import '../../utils/helpers/form_helpers.dart';

class BookingPage extends StatefulWidget {
  final TouristSpot spot;

  final TextEditingController fullnameController;
  final TextEditingController contactNumberController;
  final TextEditingController emailController;
  final TextEditingController numberOfPeopleController;
  final DatabaseReference databaseRef;
  final FirebaseAuth auth;
  final DateTime? selectedDate; // Define selectedDate as a field

  const BookingPage({
    Key? key,
    required this.spot,
    required this.fullnameController,
    required this.contactNumberController,
    required this.emailController,
    required this.numberOfPeopleController,
    required this.databaseRef,
    required this.auth,
    this.selectedDate, // Properly add selectedDate to the constructor
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  Map<DateTime, String> _userBookings = {};
  String _bookingStatus = "";

  @override
  void initState() {
    super.initState();
    print('BookingPage received selectedDate: ${widget.selectedDate}');
    _fetchUserBookings().then((_) {
      if (widget.selectedDate != null) {
        setState(() {
          selectedDate = widget.selectedDate;
          _bookingStatus = _userBookings[selectedDate!] ?? "No booking on this date.";
        });
      }
    });
  }

  Future<void> _fetchUserBookings() async {
    try {
      User? user = widget.auth.currentUser;
      if (user == null) {
        print("Error: No authenticated user found.");
        return;
      }

      final snapshot = await widget.databaseRef.child('Booking').child(user.uid).get();
      if (!snapshot.exists) {
        print("No bookings found for user: ${user.uid}");
        return;
      }

      print("Raw booking data fetched from Firebase:");
      print(snapshot.value);

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      // Parse bookings and ensure null safety
      final bookings = data.entries.map((entry) {
        final value = Map<String, dynamic>.from(entry.value as Map);

        // Ensure 'date' is not null before parsing
        final dateString = value['date']?.toString();
        if (dateString == null) {
          print("Warning: Booking ${entry.key} has no 'date'. Skipping...");
          return null;
        }

        try {
          final bookingDate = DateTime.parse(dateString);
          final status = value['status']?.toString() ?? 'Unknown'; // Default to 'Unknown'
          return MapEntry(bookingDate, status);
        } catch (e) {
          print("Error parsing date for Booking ${entry.key}: $e");
          return null;
        }
      }).whereType<MapEntry<DateTime, String>>().toList(); // Remove null values

      setState(() {
        _userBookings = Map<DateTime, String>.fromEntries(bookings);
      });

      print("Processed bookings:");
      print(_userBookings);
    } catch (e) {
      print("Error fetching user bookings: $e");
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
          Text(widget.spot.name,
              style: GoogleFonts.comfortaa(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Text("Booking Form",
              style: GoogleFonts.comfortaa(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Booking Status Display
          if (selectedDate != null)
            Text(
              "Status on ${selectedDate?.toLocal().toString().split(' ')[0]}: $_bookingStatus",
              style: GoogleFonts.comfortaa(fontSize: 14),
            ),

          const SizedBox(height: 10),

          // Booking Form Fields
          buildTextField(
            controller: widget.fullnameController,
            hintText: 'Fullname',
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your full name'
                : null,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: widget.contactNumberController,
            hintText: 'Contact Number',
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your contact number'
                : null,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: widget.emailController,
            hintText: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter your email address'
                : null,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: widget.numberOfPeopleController,
            hintText: 'Number of People',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the number of people';
              }
              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Submit Booking Button
          ElevatedButton(
            onPressed: () async {
              // Refresh the selectedDate value before validation
              final DateTime? refreshedDate = widget.selectedDate;

              // Check if a date is selected
              if (refreshedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a date.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Check if all fields are filled out
              if (widget.fullnameController.text.isEmpty ||
                  widget.contactNumberController.text.isEmpty ||
                  widget.emailController.text.isEmpty ||
                  widget.numberOfPeopleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill out all fields.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Parse and validate the number of people
              final int? numberOfPeople = int.tryParse(widget.numberOfPeopleController.text);
              if (numberOfPeople == null || numberOfPeople <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number of people.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Prepare the booking data
              final bookingData = {
                'fullname': widget.fullnameController.text,
                'contactNumber': widget.contactNumberController.text,
                'email': widget.emailController.text,
                'numberOfPeople': numberOfPeople,
                'date': refreshedDate.toIso8601String(),
                'touristName': widget.spot.name,
                'imageUrl': widget.spot.imageUrl,
                'price': widget.spot.price,
                'address': widget.spot.address,
                'description': widget.spot.description,
                'status': 'Pending',
              };

              try {
                final User? user = widget.auth.currentUser;
                if (user != null) {
                  // Check if a booking already exists for the selected date
                  final snapshot = await widget.databaseRef
                      .child('Booking')
                      .child(user.uid)
                      .orderByChild('selectedDate')
                      .equalTo(refreshedDate.toIso8601String())
                      .get();

                  if (snapshot.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You already have a booking for the selected date.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Save the booking if no existing booking is found
                  await widget.databaseRef
                      .child('Booking')
                      .child(user.uid)
                      .push()
                      .set(bookingData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to TabNavigation screen
                  Get.offAll(() => TabNavigation());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please log in to save a booking.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to save booking.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit Booking'),
          ),

        ],
      ),
    );
  }
}
