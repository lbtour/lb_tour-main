import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lb_tour/repository/authentication_repository.dart';
import 'package:lb_tour/screens/authentication/forgot-password.dart';
import 'package:lb_tour/screens/authentication/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  var height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 20),
              _header(context),
              _inputField(context),
              _forgotPassword(context),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          "assets/images/lobo-logo.png",
          height: 150,
          width: 150,
        ),
        Text(
          "Welcome to LB Tour",
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

  Widget _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        TextField(
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
        ),
        const SizedBox(height: 20),
        TextField(
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
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _loginUser,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            "Login",
            style: GoogleFonts.comfortaa(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void _loginUser() async {
    setState(() {
      _isLoading = true;
    });
    final authRepo = AuthenticationRepository.instance;

    try {
      await authRepo.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
        context: context,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
        );
      },
      child: Text(
        "Forgot Password?",
        style: GoogleFonts.comfortaa(
          fontSize: width * 0.032,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: GoogleFonts.comfortaa(
            fontSize: width * 0.032,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            "Sign up here!",
            style: GoogleFonts.comfortaa(
              fontSize: width * 0.032,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
