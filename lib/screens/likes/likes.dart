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
        backgroundColor: Theme.of(context).dialogBackgroundColor, // ✅ Match theme
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // ✅ Smooth rounded corners
        ),
        title: Text(
          existingFeedback == null ? "Add Feedback" : "Edit Feedback",
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: feedbackController,
          maxLines: 3,
          style: GoogleFonts.roboto(fontSize: 16),
          decoration: InputDecoration(
            hintText: "Write your feedback...",
            hintStyle: GoogleFonts.roboto(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
            child: Text(
              existingFeedback == null ? "Submit" : "Update",
              style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.roboto(fontSize: 16, color: Colors.red),
            ),
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
                        Text(
                          spot.name.length > 50 ? '${spot.name.substring(0, 50)}...' : spot.name,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Ensures text gets truncated
                          maxLines: 1, // Limits to a single line
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '₱${spot.price}/Person',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),

                        const SizedBox(height: 5),
                        Text(
                          '${spot.likes} Likes',
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                        const SizedBox(height: 5),Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: 40,
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
                            padding: const EdgeInsets.symmetric(horizontal: 24.0), // Consistent padding
                          ),
                          onPressed: () {
                            final selectedSpot = controller.selectedSpot.value;
                            if (selectedSpot != null) {

                              Get.to(
                                  () => BookingScreen(
                                    spot: selectedSpot,
                                    initialPage: (selectedSpot.name == 'Olo Olo Mangrove Forest' ||
                                        selectedSpot.name == 'Mt. Nalayag' ||
                                        selectedSpot.name == 'Lagadlarin Mangrove Forest')
                                        ? 1
                                        : 0,

                                ),
                              );
                            }
                          },
                          child: Text(
                            (controller.selectedSpot.value?.name == 'Olo Olo Mangrove Forest' ||
                                controller.selectedSpot.value?.name == 'Mt. Nalayag'||
                                controller.selectedSpot.value?.name == 'Lagadlarin Mangrove Forest')
                                ? "Book Now"
                                : "Check Tourist Spot",
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                fontSize: 14,
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
                        final hasFeedback = userId != null &&
                            controller.feedbacks[spot.id]?.any((feedback) => feedback.fullName == controller.fullName.value) == true;

                        return Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Color.fromARGB(255, 14, 86, 170)),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            ),
                            onPressed: () async {
                              String? existingFeedback;

                              if (hasFeedback) {
                                final feedbackList = controller.getFeedbackForSpot(spot.id);
                                if (feedbackList != null && userId != null) {
                                  final userFullName = await controller.getUserFullName(userId);
                                  final feedback = feedbackList.firstWhere(
                                        (feedback) => feedback.fullName == userFullName,
                                    orElse: () => UserFeedback(fullName: '', message: ''),
                                  );
                                  existingFeedback = feedback.message.isNotEmpty ? feedback.message : null;
                                }
                              }

                              showFeedbackForm(context, spot, existingFeedback: existingFeedback);
                            },
                            child: Text(
                              hasFeedback ? "Edit Feedback" : "Add Feedback",
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 14, color: Color.fromARGB(255, 14, 86, 170)),
                              ),
                            ),
                          ),
                        );
                      })

                    ],
                  ),





SizedBox(height: 15,),
                        GestureDetector(
                          onTap: () {
                            showFeedbackModal(context); // ✅ Opens the modal on tap
                          },
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(

                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                                border: Border.all(color: Color.fromARGB(255, 14, 86, 170)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'View Feedback',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(255, 14, 86, 170)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 5,),


                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.6, // ✅ Adjusted height dynamically
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // ✅ Two items per row
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.45, // ✅ Keeps layout proportions
                          ),
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
                                          height: 150,
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
                                                    fontSize: screenWidth * 0.04, // ✅ Dynamic font size
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '₱${spot.price}/Person',
                                                  style: GoogleFonts.roboto(
                                                    color: Colors.white,
                                                    fontSize: screenWidth * 0.03, // ✅ Dynamic font size
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // ✅ CONSTRAIN FEEDBACK VIEW TO PREVENT OVERFLOW
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: screenHeight * 0.15, // ✅ Limits feedback expansion
                                      ),

                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),



        ],
      ),
    );
  }
}


void showFeedbackModal(BuildContext context) {
  final controller = Get.find<TouristSpotController>();
  final spot = controller.selectedSpot.value;

  if (spot == null) {
    return;
  }

  final feedbacks = controller.getFeedbackForSpot(spot.id);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full-screen height modal
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5, // Start at 50% of screen height
        minChildSize: 0.3, // Minimum height 30%
        maxChildSize: 0.9, // Maximum height 90%
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "Feedbacks",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 28, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // Feedback List
                Expanded(
                  child: feedbacks != null && feedbacks.isNotEmpty
                      ? ListView.builder(
                    controller: scrollController, // Allows smooth scrolling inside modal
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbacks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          tileColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            feedback.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(feedback.message),
                        ),
                      );
                    },
                  )
                      : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "No feedback available.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
