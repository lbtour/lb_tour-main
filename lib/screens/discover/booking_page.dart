import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';
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
    print('BookingPage received selectedDate yesssssssssssssssssssssssssssssss: ${widget.selectedDate}');

  _fetchUserBookings();
    if (widget.selectedDate != null) {
      selectedDate = widget.selectedDate; // Initialize with passed date
      _bookingStatus = _userBookings[selectedDate!] ?? "No booking on this date.";
    }
  }

  Future<void> _fetchUserBookings() async {
    User? user = widget.auth.currentUser;
    if (user == null) return;

    final snapshot = await widget.databaseRef.child('Booking').child(user.uid).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final bookings = data.map((key, value) {
        final bookingDate = DateTime.parse(value['date']);
        final status = value['status'] as String; // Ensure it's a String
        return MapEntry(bookingDate, status);
      });
      setState(() {
        _userBookings = bookings;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      selectedDate = selectedDay;
      _bookingStatus = _userBookings[selectedDay] ?? "No booking on this date.";
    });
    print('Selected date: $selectedDate'); // Debugging line
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
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter the number of people'
                : null,
          ),
          const SizedBox(height: 10),

          // Submit Booking Button
    ElevatedButton(
    onPressed: () {
    print('Selected Date during submission: ${widget.selectedDate}');
    if (widget.selectedDate == null) {
    print('Error: No date selected!');
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
    content: Text('Please select a date.'),
    backgroundColor: Colors.red,
    ),
    );
    return;
    }
    // Proceed with the submission logic...
    },
    child: const Text('Submit Booking'),
    ),

    ],
      ),
    );
  }
}
