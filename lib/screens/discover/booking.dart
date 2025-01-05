import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lb_tour/screens/discover/discover.dart';
import 'package:intl/intl.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class BookingScreen extends StatefulWidget {
  final TouristSpot spot;

  const BookingScreen({super.key, required this.spot});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberOfPeopleController =
      TextEditingController();
  DateTime? _selectedDate;

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget overviewPage() {
    return ListView(
      children: [
        Image.network(widget.spot.imageUrl, fit: BoxFit.cover),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Text(widget.spot.name,
                  style: GoogleFonts.comfortaa(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Text("BACKGROUND",
                  style: GoogleFonts.comfortaa(
                      fontSize: 14, fontWeight: FontWeight.w900)),
              Text(widget.spot.description,
                  style: GoogleFonts.comfortaa(fontSize: 12),
                  textAlign: TextAlign.justify),

              const Divider(),
              Align(
                alignment: Alignment.bottomRight,
                child: Text('₱${widget.spot.price}/Person',
                    style: GoogleFonts.comfortaa(
                        fontSize: 14, color: const Color.fromARGB(255, 14, 86, 170))),
              ),
              const Divider(),

              Text("Virtual Tour",
                  style: GoogleFonts.comfortaa(
                      fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              // Display virtual images as clickable images
              Column(
                children: widget.spot.virtualImages.map((imageUrl) {
                  return GestureDetector(
                    onTap: () {
                      // When tapped, navigate to the 360-degree view screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VirtualImage360ViewScreen(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Stack(
                        children: [
                          // Blurred image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                8), // Optional: for rounded corners
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              height: 200, // Adjust height if needed
                              width: double.infinity,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(
                                    0.5), // semi-transparent background
                                borderRadius: BorderRadius.circular(
                                    8), // Optional: for rounded corners
                              ),
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
        ),
      ],
    );
  }

  Widget bookingPage() {
    return ListView(
      children: [
        Image.network(widget.spot.imageUrl, fit: BoxFit.cover),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Text(widget.spot.name,
                  style: GoogleFonts.comfortaa(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              Center(
                child: Text("Booking Form",
                    style: GoogleFonts.comfortaa(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _fullnameController,
                hintText: 'Fullname',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _contactNumberController,
                hintText: 'Contact Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCall,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _emailController,
                hintText: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedMail01,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _numberOfPeopleController,
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
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedUserAdd01,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
              const SizedBox(height: 10),
              DatePickerWidget(
                onDateSelected: (DateTime date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                selectedDate: _selectedDate,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (_fullnameController.text.isEmpty ||
                      _contactNumberController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _numberOfPeopleController.text.isEmpty ||
                      _selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Center(
                              child: Text(
                                  'Please fill all fields and select a date.')),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }

                  User? user = _auth.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }

                  final bookingData = {
                    'fullname': _fullnameController.text,
                    'contactNumber': _contactNumberController.text,
                    'email': _emailController.text,
                    'numberOfPeople': _numberOfPeopleController.text,
                    'date': _selectedDate!.toIso8601String(),
                    'status': 'Pending',
                    'imageUrl': widget.spot.imageUrl,
                    'touristName': widget.spot.name,
                    'price': widget.spot.price,
                    'description': widget.spot.description,
                    'address': widget.spot.address,
                    'isActive': true
                  };

                  _databaseRef
                      .child('Booking')
                      .child(user.uid)
                      .push()
                      .set(bookingData)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Center(
                              child: Text('Booking submitted successfully')),
                          backgroundColor: Colors.green),
                    );
                    _fullnameController.clear();
                    _contactNumberController.clear();
                    _emailController.clear();
                    _numberOfPeopleController.clear();
                    setState(() {
                      _selectedDate = null;
                    });
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to submit booking: $error')),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      const Color.fromARGB(255, 14, 86, 170).withOpacity(0.8),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Submit Booking',
                  style: GoogleFonts.comfortaa(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget activitiesPage() {
    return ListView(
      children: [
        // Display main image
        Image.network(widget.spot.imageUrl, fit: BoxFit.cover),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Text(widget.spot.name,
                  style: GoogleFonts.comfortaa(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),

              // Activities section
              Text("Activities",
                  style: GoogleFonts.comfortaa(
                      fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),

              // Loop through activities and display each in a card
              ...widget.spot.activities.map((activity) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        activity.image,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      activity.title,
                      style: GoogleFonts.comfortaa(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft02,
              color: Colors.black,
              size: 24.0),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                color: Color.fromARGB(255, 14, 86, 170),
                size: 24.0),
            const SizedBox(width: 10),
            Text(
              widget.spot.name,
              style: GoogleFonts.comfortaa(
                fontSize: 14,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          overviewPage(),
          bookingPage(),
          activitiesPage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color.fromARGB(255, 255, 255, 255),
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
                bodySmall: GoogleFonts.comfortaa(color: Colors.black),
              ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentPage,
          onTap: (int index) {
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          },
          items: const [
            BottomNavigationBarItem(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  color: Colors.black,
                  size: 24.0,
                ),
                label: 'Overview'),
            BottomNavigationBarItem(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedBook01,
                  color: Colors.black,
                  size: 24.0,
                ),
                label: 'Booking'),
            BottomNavigationBarItem(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedActivity01,
                  color: Colors.black,
                  size: 24.0,
                ),
                label: 'Activities'),
          ],
          unselectedItemColor: Colors.black,
          selectedItemColor: const Color.fromARGB(255, 14, 86, 170),
          selectedLabelStyle:
              GoogleFonts.comfortaa(fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              GoogleFonts.comfortaa(fontWeight: FontWeight.normal),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    HugeIcon? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: Colors.black54,
      style: GoogleFonts.comfortaa(color: Colors.black),
      decoration: InputDecoration(
        hintStyle: GoogleFonts.comfortaa(color: Colors.black54),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.black.withOpacity(0.2),
        filled: true,
        prefixIcon: icon,
      ),
      validator: validator,
    );
  }
}

class DatePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

  const DatePickerWidget({super.key, required this.onDateSelected, this.selectedDate});

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    // Adjust the initialDate if it's a Sunday
    DateTime initialDate = widget.selectedDate ?? DateTime.now();
    if (initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(const Duration(days: 1)); // Skip to Monday
    }

    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          selectableDayPredicate: (DateTime date) {
            return date.weekday != DateTime.sunday;
          },
        );
        if (pickedDate != null) {
          widget.onDateSelected(pickedDate);
          setState(() {});
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar01,
              color: Colors.white,
              size: 24.0,
            ),
            const SizedBox(width: 10),
            Text(
              widget.selectedDate == null
                  ? 'Select Date of Visit'
                  : DateFormat('dd/MM/yyyy').format(widget.selectedDate!),
              style: GoogleFonts.comfortaa(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}


class VirtualImage360ViewScreen extends StatelessWidget {
  final String imageUrl;

  const VirtualImage360ViewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft02,
              color: Colors.white,
              size: 24.0),
        ),
        title: Text(
          "360 View",
          style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 14, 86, 170),
      ),
      body: Center(
        // Panorama widget for version 1.0.6
        child: PanoramaViewer(
          child: Image.network(imageUrl), // Pass the 360-degree image URL
        ),
      ),
    );
  }
}
