import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivityController extends GetxController {
  var selectedActivityIndex = (-1).obs;
  var selectedActivityImage = "".obs;
  ScrollController scrollController = ScrollController();

  void updateSelectedActivity(int index, String image) {
    print("updateSelectedActivity() called with index: $index, image: $image"); // Debug log
    selectedActivityIndex.value = index;
    selectedActivityImage.value = image;


    // Ensure scrolling happens after UI updates
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        print("Activity selected: $index, scrolling to top...");
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        print("ScrollController has no clients, skipping scroll.");
      }
    });
  }
}