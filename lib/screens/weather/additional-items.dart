import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdditionalItems extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionalItems({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Colors.white,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          label,
          style: GoogleFonts.comfortaa(color: Colors.white),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          value,
          style: GoogleFonts.comfortaa(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}