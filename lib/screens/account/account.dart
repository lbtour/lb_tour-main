import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lb_tour/screens/account/user_booking_page.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../ccontroller/booking_controller.dart';
import '../../repository/authentication_repository.dart';
import '../authentication/login.dart';

class AccountPage extends StatefulWidget {
  final String? selectedStatus;

  const AccountPage({super.key, this.selectedStatus});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  String? fullName;
  String? email;
  String avatar = 'assets/images/avatar/Avatar (1).jpg'; // Default avatar

  @override
  void initState() {
    super.initState();

    // Initialize the controller and set its status if provided
    final bookingController = Get.put(BookingController());
    if (widget.selectedStatus != null) {
      bookingController.selectedStatus.value = widget.selectedStatus!;
    }

    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      email = user.email;
      final snapshot = await _databaseRef.child('users').child(user.uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          fullName = "${data['firstName']} ${data['lastName']}";
          avatar = data['avatar'] ?? avatar;
        });
      }
    }
  }

  Future<void> _saveAvatarSelection(String avatarPath) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _databaseRef.child('users').child(user.uid).update({'avatar': avatarPath});
    }
  }

  void _selectAvatar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an Avatar"),
          content: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(5, (index) {
                  final avatarPath = 'assets/images/avatar/Avatar (${index + 1}).jpg';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        avatar = avatarPath;
                      });
                      _saveAvatarSelection(avatarPath);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(avatarPath),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.put(BookingController());

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(5.0),
        children: [
          _buildAccountDetailsSection(),
          const SizedBox(height: 10),
          _buildBookingStatusButtons(bookingController),
          const SizedBox(height: 20),
          SizedBox(
            height: 360,
            child: _buildBookingListContainer(bookingController, context),
          ),
          const SizedBox(height: 20),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _selectAvatar,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(avatar),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName ?? 'Loading...',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email ?? 'Loading...',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStatusButtons(BookingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statusButton(controller, 'Pending'),
        _statusButton(controller, 'Approved'),
        _statusButton(controller, 'Finished'),
        _statusButton(controller, 'Cancelled'),
      ],
    );
  }

  Widget _statusButton(BookingController controller, String status) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(5),
        width: 100,
        child: ElevatedButton(
          onPressed: () {
            controller.selectedStatus.value = status;
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            backgroundColor: controller.selectedStatus.value == status
                ? Color.fromARGB(255, 14, 86, 170)
                : Colors.grey,
          ),
          child: Text(
            status,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      );
    });
  }

  Widget _buildBookingListContainer(BookingController controller, BuildContext context) {
    return Obx(() {
      final bookings = controller.bookings[controller.selectedStatus.value] ?? [];
      final limitedBookings = bookings.take(4).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 14, 86, 170).withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              if (bookings.isEmpty)
                const Center(
                  child: Text(
                    'No bookings available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              else
                ...limitedBookings.map((booking) {
                  String formattedDate = '';
                  try {
                    final parsedDate = DateTime.parse(booking['date']!);
                    formattedDate = DateFormat('MMMM d, y').format(parsedDate);
                  } catch (e) {
                    formattedDate = 'Invalid date';
                  }

                  return GestureDetector(
                    onTap: () {
                      _showBookingDetails(context, booking, controller.selectedStatus.value);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today,color: Color.fromARGB(255, 14, 86, 170),),
                      title: Text(booking['title']!),
                      subtitle: Text(formattedDate),
                      trailing:  Icon(Icons.arrow_forward_ios,color: Color.fromARGB(255, 14, 86, 170),size: 18,),
                    ),
                  );
                }).toList(),
              if (bookings.length > 4)
                TextButton(
                  onPressed: () {
                    Get.to(() => AllBookingsPage(
                      title: controller.selectedStatus.value,
                      bookings: bookings,
                    ));
                  },
                  child: Text('View All',style: GoogleFonts.roboto(color: Color.fromARGB(255, 14, 86, 170), ),),
                ),
            ],
          ),
        ),
      );
    });
  }

  void _showBookingDetails(BuildContext context, Map<String, String> booking, String status) {
    String formattedDate = 'Invalid date';
    try {
      if (booking['date'] != null) {
        final parsedDate = DateTime.parse(booking['date']!);
        formattedDate = DateFormat('MMMM d, y').format(parsedDate);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }

    final location = booking['address'] ?? 'No location available';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Dialog(
            insetPadding: EdgeInsets.zero, // Remove all padding
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                
                        color: Color.fromARGB(255, 14, 86, 170),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          booking['touristName'] ?? 'Booking Details',
                          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                
                    // Booking Details
                    _buildDetailRow('Tourist Name:', booking['title'] ?? 'N/A'),
                    _buildDetailRow('Date:', formattedDate),
                    _buildDetailRow('Full Name:', booking['fullname'] ?? 'N/A'),
                    _buildDetailRow('Contact Number:', booking['contactNumber'] ?? 'N/A'),
                    _buildDetailRow('Price:', '₱${booking['price'] ?? 'N/A'}'),
                    _buildDetailRow('Status:', status),
                    _buildDetailRow('Email:', booking['email'] ?? 'N/A'),
                
                    const SizedBox(height: 16),
                
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Get Directions Button
                        ElevatedButton.icon(
                          onPressed: () {
                            // Close the AlertDialog first
                            Navigator.pop(context);

                            // Open the modal bottom sheet
                            Future.delayed(Duration(milliseconds: 200), () {
                              _navigateToLocation(location, booking['touristName'] ?? 'Destination');
                            });
                          },
                          icon: const Icon(Icons.directions, color: Colors.white),
                          label: Text(
                            'Get Directions',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 14, 86, 170),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),


                        // Close Button
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 14, 86, 170),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0 ,horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color.fromARGB(255, 14, 86, 170),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLocation(String location, String name) {
    if (location != 'No location available') {
      _openMap(context, location, name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available.')),
      );
    }
  }

  static Future<void> _openMap(BuildContext context, String address, String name) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Choose a map',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...availableMaps.map((map) {
                // Assign the custom icons based on the map name
                String iconPath;
                if (map.mapName.toLowerCase().contains('google')) {
                  iconPath = 'assets/images/maps_icon/google maps.png';
                } else if (map.mapName.toLowerCase().contains('waze')) {
                  iconPath = 'assets/images/maps_icon/waze.png';
                } else {
                  iconPath = ''; // Fallback for unknown map apps
                }

                return ListTile(
                  leading: iconPath.isNotEmpty
                      ? Image.asset(
                    iconPath,
                    width: 32, // Set the desired width
                    height: 32, // Set the desired height
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.map), // Default icon for unsupported apps
                  title: Text(map.mapName),
                  onTap: () async {
                    Navigator.pop(context); // Close modal
                    try {
                      // Extract coordinates from the location string
                      final regex = RegExp(r'@([-+]?[0-9]*\.?[0-9]+),([-+]?[0-9]*\.?[0-9]+)');
                      final match = regex.firstMatch(address);

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
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available map applications.')),
      );
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          AuthenticationRepository.instance.logout();
          Get.offAll(() => const LoginScreen());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text(
          'Logout',
          style: GoogleFonts.roboto(

            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
