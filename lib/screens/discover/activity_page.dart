import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/tourist_spot/tourist_spot_model.dart';

class ActivitiesPage extends StatelessWidget {
  final TouristSpot spot;

  const ActivitiesPage({Key? key, required this.spot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(spot.name,
              style: GoogleFonts.comfortaa(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Text("Activities",
              style: GoogleFonts.comfortaa(
                  fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...spot.activities.map((activity) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Image.network(activity.image, height: 50, width: 50),
                title: Text(activity.title),
              ),
            );
          }),
        ],
      ),
    );
  }
}
