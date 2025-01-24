import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lb_tour/notifier/booking_notifier.dart';
import 'package:lb_tour/screens/splashscreen/splashscreen.dart';
import 'package:lb_tour/repository/authentication_repository.dart';

import 'api/firebase_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  Get.lazyPut(()=>AuthenticationRepository());


  // Initialize BookingStatusNotifier globally (optional)
  Get.put(BookingStatusNotifier());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
