import 'package:flutter/material.dart';

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
          return GestureDetector(
            onTap: () {
              _showBookingDetails(context, booking);
            },
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(booking['title']!),
              subtitle: Text(booking['date']!),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }

  void _showBookingDetails(BuildContext context, Map<String, String> booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(booking['title'] ?? 'Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${booking['date'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Status: ${booking['status'] ?? 'N/A'}'),
              const SizedBox(height: 8),
              Text('Description: ${booking['description'] ?? 'No details available'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
