
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
