import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/authentication/login.dart';

class BookingController extends GetxController {
  // Reactive variable to track the selected booking status
  var selectedStatus = 'Pending'.obs;

  // Example booking data
  final bookings = {
    'Pending': [
      {'title': 'Flight to New York', 'date': 'Jan 10, 2025'},
    ],
    'Approved': [
      {'title': 'Hotel Reservation', 'date': 'Feb 5, 2025'},
    ],
    'Finished': [
      {'title': 'Tour in Paris', 'date': 'Dec 15, 2024'},
    ],
    'Cancelled': [
      {'title': 'Cruise to Bahamas', 'date': 'Nov 20, 2024'},
    ],
  };
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.put(BookingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAccountDetailsSection(),
          const SizedBox(height: 30),
          _buildBookingStatusButtons(bookingController),
          const SizedBox(height: 20),
          _buildBookingListContainer(bookingController),
          const SizedBox(height: 30),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsSection() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          child: Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'john.doe@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
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
      return ElevatedButton(
        onPressed: () {
          controller.selectedStatus.value = status;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.selectedStatus.value == status
              ? Colors.blue
              : Colors.grey,
        ),
        child: Text(status),
      );
    });
  }

  Widget _buildBookingListContainer(BookingController controller) {
    return Obx(() {
      final bookings = controller.bookings[controller.selectedStatus.value] ?? [];
      return Container(
        padding: const EdgeInsets.all(16.0),
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
        child: bookings.isEmpty
            ? const Center(
          child: Text(
            'No bookings available.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : Column(
          children: bookings.map((booking) {
            return ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(booking['title']!),
              subtitle: Text(booking['date']!),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Logout and redirect to login
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
