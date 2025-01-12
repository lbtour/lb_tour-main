import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lb_tour/screens/account/submit_ticket_widget.dart';
import 'package:lb_tour/screens/authentication/login.dart';
import 'package:lb_tour/repository/authentication_repository.dart';

class BookingController extends GetxController {
  // Reactive variable to track the selected booking status
  var selectedStatus = 'Pending'.obs;

  // Example dynamic booking data (this could come from an API in a real app)
  final bookings = {
    'Pending': [
      {'title': 'Flight to New York', 'date': 'Jan 10, 2025'},
      {'title': 'Hotel in Tokyo', 'date': 'Mar 15, 2025'},
      {'title': 'Conference in London', 'date': 'Apr 22, 2025'},
      {'title': 'Business Meeting in Berlin', 'date': 'May 5, 2025'},
    ],
    'Approved': [
      {'title': 'Hotel Reservation', 'date': 'Feb 5, 2025'},
    ],
    'Finished': [
      {'title': 'Tour in Paris', 'date': 'Dec 15, 2024'},
    ],
    'Cancelled': [
      {'title': 'Cruise to Bahamas', 'date': 'Nov 20, 2024'},
      {'title': 'Island Trip', 'date': 'Oct 10, 2024'},
      {'title': 'Flight to Singapore', 'date': 'Sep 5, 2024'},
      {'title': 'Hotel Stay in Dubai', 'date': 'Aug 1, 2024'},
      {'title': 'Business Meeting in Berlin', 'date': 'Jul 25, 2024'},
      {'title': 'Vacation in Maldives', 'date': 'Jun 15, 2024'},
      {'title': 'Family Trip to Sydney', 'date': 'May 20, 2024'},
      {'title': 'Road Trip in USA', 'date': 'Apr 10, 2024'},
      {'title': 'Adventure in Iceland', 'date': 'Mar 1, 2024'},
      {'title': 'Mountain Hike', 'date': 'Feb 10, 2024'},
    ],
  }.obs;
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
          Container(
              height: 360,
              child: _buildBookingListContainer(bookingController, context)),
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
        padding: EdgeInsets.all(5),
        width: 100,
        child: ElevatedButton(
          onPressed: () {
            controller.selectedStatus.value = status;
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0),
            backgroundColor: controller.selectedStatus.value == status
                ? Colors.blue
                : Colors.grey,
          ),
          child: Text(
            status,
            style: TextStyle(fontSize: 14, color: Colors.white),
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


class AllBookingsPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> bookings;

  const AllBookingsPage({
    required this.title,
    required this.bookings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title Bookings'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(booking['title']!),
            subtitle: Text(booking['date']!),
          );
        },
      ),
    );
  }
}
