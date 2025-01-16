import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../ccontroller/booking_controller.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';

class ActivitiesPage extends StatefulWidget {
  final TouristSpot spot;

  const ActivitiesPage({Key? key, required this.spot, required Null Function(String selectedActivityImage) onActivitySelected}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late int _selectedActivityIndex; // Track the selected activity index
  final BookingController bookingController = Get.find();

  @override
  void initState() {
    super.initState();
    _selectedActivityIndex = 0; // Initially select the first activity
    if (widget.spot.activities.isNotEmpty) {
      bookingController.updateSelectedActivityImage(widget.spot.activities[0].image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            widget.spot.name,
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),

          Text(
            "Activities",
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(widget.spot.activities.length, (index) {
            final activity = widget.spot.activities[index];
            final isSelected = _selectedActivityIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedActivityIndex = index; // Update selected index
                  bookingController.updateSelectedActivityImage(activity.image); // Notify controller
                });
              },
              child: Card(
                color: isSelected
                    ? Color.fromARGB(255, 14, 86, 170)
                    : Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      activity.image,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    activity.title,
                    style: GoogleFonts.roboto(
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  trailing:
                       Icon(
                    Icons.check_circle,
                    color: isSelected
                        ? Colors.white
                        : Colors.black45,
                  )

                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
