import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lb_tour/screens/account/submit_ticket_widget.dart';
import 'package:lb_tour/screens/account/user_booking_page.dart';
import '../../ccontroller/booking_controller.dart';
import '../../repository/authentication_repository.dart';
import '../authentication/login.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  String? fullName;
  String? email;
  String avatar = 'assets/avatar1.png'; // Default avatar

  @override
  void initState() {
    super.initState();
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
        });
      }
    }
  }

  void _selectAvatar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose an Avatar"),
          content: SizedBox(
            height: 200, // Set the height for the dialog content
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: Row(
                children: List.generate(5, (index) {
                  final avatarPath = 'assets/avatar${index + 1}.png';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        avatar = avatarPath;
                      });
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
          const SizedBox(height: 10),
          SubmitTicketWidget(),
          const SizedBox(height: 10),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
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
                ? Colors.blue
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
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
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
              else ...limitedBookings.map((booking) {
                return ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(booking['title']!),
                  subtitle: Text(booking['date']!),
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
                  child: const Text('View All'),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          AuthenticationRepository.instance.logout();
          Get.offAll(() => const LoginScreen());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}