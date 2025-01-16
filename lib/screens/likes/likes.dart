import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For current user ID
import 'package:lb_tour/screens/discover/booking.dart';
import 'package:lb_tour/screens/likes/feedbackexpansiontile.dart';
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
                            Expanded(
                              child: Text(
                                spot.name.length > 50 ? '${spot.name.substring(0, 50)}...' : spot.name,
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis, // Ensures text gets truncated
                                maxLines: 1, // Limits to a single line
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              '₱${spot.price}/Person',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),
                        Text(
                          '${spot.likes} Likes',
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                        const SizedBox(height: 5),Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          border: Border.all(color: Color.fromARGB(255, 14, 86, 170)), // Border color
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent, // Background color of the button
                            shadowColor: Colors.transparent, // Remove shadow
                            elevation: 0, // Remove elevation
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Match container's radius
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Consistent padding
                          ),
                          onPressed: () {
                            final selectedSpot = controller.selectedSpot.value;
                            if (selectedSpot != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    spot: selectedSpot,
                                    initialPage: (selectedSpot.name == 'Olo Olo Mangrove Forest' ||
                                        selectedSpot.name == 'Mt. Nalayag' ||
                                        selectedSpot.name == 'Lagadlarin Mangrove Forest')
                                        ? 1
                                        : 0,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            (controller.selectedSpot.value?.name == 'Olo Olo Mangrove Forest' ||
                                controller.selectedSpot.value?.name == 'Lagadlarin Mangrove Forest')
                                ? "Book Now"
                                : "Check Tourist Spot",
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 14, 86, 170), // Text color matches border
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(() {
                        final spot = controller.selectedSpot.value;
                        if (spot == null) {
                          return const SizedBox.shrink();
                        }

                        final userId = FirebaseAuth.instance.currentUser?.uid;

                        return FutureBuilder<bool>(
                          future: userId != null ? controller.doesUserHaveFeedback(spot.id) : Future.value(false),
                          builder: (context, snapshot) {
                            final buttonStyle = ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), // Consistent padding
                            );

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(color: Color.fromARGB(255, 14, 86, 170)),
                                ),
                                child: ElevatedButton(
                                  style: buttonStyle,
                                  onPressed: null,
                                  child: Text(
                                    "Checking...",
                                    style: GoogleFonts.comfortaa(
                                      textStyle: TextStyle(fontSize: 16, color: Color.fromARGB(255, 14, 86, 170)),
                                    ),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasData && snapshot.data == true) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(color: Color.fromARGB(255, 14, 86, 170)),
                                ),
                                child: ElevatedButton(
                                  style: buttonStyle,
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
                                    style: GoogleFonts.roboto(
                                      textStyle: TextStyle(fontSize: 16, color: Color.fromARGB(255, 14, 86, 170)),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.all(Radius.circular(30)),
                                  border: Border.all(color: Color.fromARGB(255, 14, 86, 170)),
                                ),
                                child: ElevatedButton(
                                  style: buttonStyle,
                                  onPressed: () {
                                    showFeedbackForm(context, spot);
                                  },
                                  child: Text(
                                    "Add Feedback",
                                    style: GoogleFonts.roboto(
                                      textStyle: TextStyle(fontSize: 16, color: Color.fromARGB(255, 14, 86, 170)),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }),
                    ],
                  ),


                      const SizedBox(height: 5),





FeedbackWidget(),


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
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '₱${spot.price}/Person',
                                        style: GoogleFonts.roboto(
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