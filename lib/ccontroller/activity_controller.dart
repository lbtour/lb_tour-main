import 'package:get/get.dart';

class ActivityController extends GetxController {
  var selectedActivityImage = ''.obs;

  void updateSelectedActivity(String image) {
    selectedActivityImage.value = image;
  }
}
