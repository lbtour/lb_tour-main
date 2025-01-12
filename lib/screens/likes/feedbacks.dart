import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final String spotId;
  final List<String> feedbacks;

  const FeedbackScreen({Key? key, required this.spotId, required this.feedbacks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Feedbacks"),
        backgroundColor: Colors.green,
      ),
      body: feedbacks.isNotEmpty
          ? ListView.builder(
        itemCount: feedbacks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.feedback),
              title: Text(feedbacks[index]),
            ),
          );
        },
      )
          : const Center(
        child: Text(
          "No feedback available",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
