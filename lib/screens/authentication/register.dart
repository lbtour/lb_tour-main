import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lb_tour/screens/authentication/login.dart';
import 'package:lb_tour/repository/authentication_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 20),
              _header(context, width),
              _inputField(context, width),
              _signup(context, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double width) {
    return Column(
      children: [
        Image.asset(
          "assets/images/lobo-logo.png",
          height: 150,
          width: 150,
        ),
        Text(
          "Sign Up",
          style: GoogleFonts.comfortaa(
            fontSize: width * 0.068,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          "Please fill up the necessary credentials.",
          style: GoogleFonts.comfortaa(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context, double width) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  cursorColor: Colors.black54,
                  decoration: InputDecoration(
                    hintStyle: GoogleFonts.comfortaa(color: Colors.black54),
                    hintText: "First Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.black.withOpacity(0.2),
                    filled: true,
                    prefixIcon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  cursorColor: Colors.black54,
                  decoration: InputDecoration(
                    hintStyle: GoogleFonts.comfortaa(color: Colors.black54),
                    hintText: "Last Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.black.withOpacity(0.2),
                    filled: true,
                    prefixIcon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            cursorColor: Colors.black54,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.comfortaa(color: Colors.black54),
              hintText: "Email Address",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.black.withOpacity(0.2),
              filled: true,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMail01,
                color: Colors.white,
                size: 24.0,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            cursorColor: Colors.black54,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.comfortaa(color: Colors.black54),
              hintText: "Password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.black.withOpacity(0.2),
              filled: true,
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedLock,
                color: Colors.white,
                size: 24.0,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await AuthenticationRepository.instance.registerUser(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        context: context,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}
Widget _signup(BuildContext context, double width) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Already have an account?",
        style: GoogleFonts.comfortaa(
          fontSize: width * 0.032,
          color: Colors.black,
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: Text(
          "Log in here!",
          style: GoogleFonts.comfortaa(
            fontSize: width * 0.032,
            color: Colors.black54,
          ),
        ),
      ),
    ],
  );
}
