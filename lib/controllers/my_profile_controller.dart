import 'dart:async';
import 'dart:developer';

import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MyProfileController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getThem();
    super.onInit();
  }

  RxString isDarkMode = "Light".obs;
  RxBool isDarkModeSwitch = false.obs;

  getThem() {
    isDarkMode.value = Preferences.getString(Preferences.themKey);
    if (isDarkMode.value == "Dark") {
      isDarkModeSwitch.value = true;
    } else if (isDarkMode.value == "Light") {
      isDarkModeSwitch.value = false;
    } else {
      isDarkModeSwitch.value = false;
    }
    isLoading.value = false;
  }

  Future<bool> deleteUserFromServer() async {
    // Check if websiteUrl is valid (not a placeholder)
    if (Constant.websiteUrl.isEmpty || 
        Constant.websiteUrl.contains('youruserpanel.com') || 
        Constant.websiteUrl.contains('example.com') ||
        !Constant.websiteUrl.startsWith('http')) {
      log("deleteUserFromServer: Invalid websiteUrl, skipping server deletion: ${Constant.websiteUrl}");
      // Don't fail the entire deletion process if API URL is invalid
      return true; // Return true to allow local deletion to continue
    }

    var url = '${Constant.websiteUrl}/api/delete-user';
    try {
      // Get user ID - prefer Firebase Auth UID, fallback to Constant.userModel.id
      String userId;
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          userId = FireStoreUtils.getCurrentUid();
        } else if (Constant.userModel?.id != null && Constant.userModel!.id!.isNotEmpty) {
          userId = Constant.userModel!.id!;
        } else {
          log("deleteUserFromServer: No user ID found");
          return true; // Allow local deletion to continue
        }
      } catch (e) {
        if (Constant.userModel?.id != null && Constant.userModel!.id!.isNotEmpty) {
          userId = Constant.userModel!.id!;
        } else {
          log("deleteUserFromServer: Failed to get user ID: $e");
          return true; // Allow local deletion to continue
        }
      }

      var response = await http.post(
        Uri.parse(url),
        body: {
          'uuid': userId,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log("deleteUserFromServer: Request timeout");
          throw TimeoutException('Request timeout');
        },
      );
      
      log("deleteUserFromServer :: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        log("deleteUserFromServer: Server returned status code ${response.statusCode}");
        // Don't fail the entire deletion process if server deletion fails
        return true; // Allow local deletion to continue
      }
    } on TimeoutException {
      log("deleteUserFromServer: Request timeout");
      // Don't fail the entire deletion process if server request times out
      return true; // Allow local deletion to continue
    } catch (e) {
      log("deleteUserFromServer error: $e");
      // Don't fail the entire deletion process if server deletion fails
      return true; // Allow local deletion to continue
    }
  }
}
