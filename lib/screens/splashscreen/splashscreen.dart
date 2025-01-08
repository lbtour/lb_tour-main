import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lb_tour/repository/authentication_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {

    super.initState();
    Timer(const Duration(seconds: 3), () {
      AuthenticationRepository.instance.screenRedirect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Image.asset(
          'assets/images/lobo-logo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
