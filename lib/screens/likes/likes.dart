import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For current user ID
import 'package:lb_tour/screens/discover/booking.dart';
import '../../ccontroller/tourist_controller.dart';
import '../../models/feedback/user_feedback_model.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';

class TopRatedScreen extends StatelessWidget {
  final TouristSpotController controller = Get.put(TouristSpotController());

  void showFeedbackForm(BuildContext context, TouristSpot spot, {String? existingFeedback}) {
    TextEditingController feedbackController = TextEditingController(text: existingFeedback);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingFeedback == null ? "Add Feedback" : "Edit Feedback"),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: "Write your feedback...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (feedbackController.text.isNotEmpty) {
                controller.addOrEditFeedback(spot.id, feedbackController.text);
                Navigator.pop(context);
              }
            },
            child: Text(existingFeedback == null ? "Submit" : "Update"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Obx(() {
            final spot = controller.selectedSpot.value;
            if (spot == null) {
              return const SizedBox.shrink();
            }

            return Card(
              color: Colors.white,
              elevation: 6,
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    spot.imageUrl,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              spot.name,
                              style: GoogleFonts.comfortaa(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₱${spot.price}/Person',
                              style: GoogleFonts.comfortaa(
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${spot.likes} Likes',
                          style: GoogleFonts.comfortaa(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            final selectedSpot = controller.selectedSpot.value;
                            if (selectedSpot != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(spot: selectedSpot),
                                ),
                              );
                            }
                          },
                          child: const Text("Book Now"),
                        ),
                        const SizedBox(height: 10),
                        Obx(() {
                          final spot = controller.selectedSpot.value;
                          if (spot == null) {
                            return const SizedBox.shrink();
                          }

                          final userId = FirebaseAuth.instance.currentUser?.uid;

                          return FutureBuilder<bool>(
                            future: userId != null ? controller.doesUserHaveFeedback(spot.id) : Future.value(false),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return ElevatedButton(
                                  onPressed: null,
                                  child: Text(
                                    "Checking...",
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                );
                              } else if (snapshot.hasData && snapshot.data == true) {
                                return ElevatedButton(
                                  onPressed: () async {
                                    final feedbackList = controller.getFeedbackForSpot(spot.id);
                                    String? existingFeedback;

                                    if (feedbackList != null && userId != null) {
                                      final userFullName = await controller.getUserFullName(userId);
                                      final feedback = feedbackList.firstWhere(
                                            (feedback) => feedback.fullName == userFullName,
                                        orElse: () => UserFeedback(fullName: '', message: ''),
                                      );
                                      existingFeedback = feedback.message.isNotEmpty ? feedback.message : null;
                                    }

                                    showFeedbackForm(context, spot, existingFeedback: existingFeedback);
                                  },
                                  child: Text(
                                    "Edit Feedback",
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                );
                              } else {
                                return ElevatedButton(
                                  onPressed: () {
                                    showFeedbackForm(context, spot);
                                  },
                                  child: Text(
                                    "Add Feedback",
                                    style: GoogleFonts.comfortaa(),
                                  ),
                                );
                              }
                            },
                          );
                        }),





                        const SizedBox(height: 10),
                        ExpansionTile(
                          title: const Text("View Feedbacks"),
                          children: controller.getFeedbackForSpot(spot.id)?.map((feedback) {
                            return ListTile(
                              title: Text(feedback.fullName), // Display full name
                              subtitle: Text(feedback.message),
                            );
                          }).toList() ??
                              [const Text("No feedback available")],
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.touristSpots.length,
                itemBuilder: (context, index) {
                  final spot = controller.touristSpots[index];
                  return GestureDetector(
                    onTap: () {
                      controller.selectSpot(spot);
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Image.network(
                                spot.imageUrl,
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.black.withOpacity(0.5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        spot.name,
                                        style: GoogleFonts.comfortaa(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₱${spot.price}/Person',
                                        style: GoogleFonts.comfortaa(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              '${spot.likes} Likes',
                              style: GoogleFonts.comfortaa(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}