import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../ccontroller/tourist_controller.dart';

class FeedbackWidget extends StatefulWidget {
  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TouristSpotController>();

    return Obx(() {
      final spot = controller.selectedSpot.value;
      if (spot == null) {
        return Center(child: Text("No spot selected."));
      }

      final feedbacks = controller.getFeedbackForSpot(spot.id);

      return ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.transparent, // Customize color as needed
            ),
            const SizedBox(width: 8), // Space between text and arrow
            Text(
              isExpanded ? "Hide Feedback" : "View Feedbacks",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 8), // Space between text and arrow
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 24,
              color: Colors.blue, // Customize color as needed
            ),
          ],
        ),
        trailing: const SizedBox.shrink(), // Remove default ExpansionTile icon
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded; // Update the expansion state
          });
        },
        children: feedbacks != null
            ? feedbacks.map((feedback) {
          return ListTile(
            title: Text(
              feedback.fullName,
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              feedback.message,
              textAlign: TextAlign.center,
            ),
          );
        }).toList()
            : [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                "No feedback available.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    });
  }
}
