import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String hintText,
  required FormFieldValidator<String> validator,
  TextInputType keyboardType = TextInputType.text,
  Widget? prefixIcon,
}) {
  return TextFormField(
    style: GoogleFonts.roboto(fontSize: 16),
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    validator: validator,
  );
}
