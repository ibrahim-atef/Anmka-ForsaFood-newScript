import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/otp_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  Rx<TextEditingController> otpController = TextEditingController().obs;

  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString fullPhoneNumber = "".obs; // Full phone number with country code
  RxBool isLoading = true.obs;

  final OtpService _otpService = OtpService();

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      countryCode.value = argumentData['countryCode'] ?? '+20';
      phoneNumber.value = argumentData['phoneNumber'] ?? '';
      fullPhoneNumber.value = argumentData['fullPhoneNumber'] ?? 
          (countryCode.value + phoneNumber.value);
    }
    isLoading.value = false;
    update();
  }

  Future<bool> sendOTP() async {
    try {
      ShowToastDialog.showLoader("Resending OTP...".tr);
      
      final result = await _otpService.resendOtp(
        fullPhoneNumber.value,
        countryCode: countryCode.value.replaceFirst('+', ''),
      );

      ShowToastDialog.closeLoader();

      if (result == SendResult.success) {
        ShowToastDialog.showToast("OTP resent successfully".tr);
        otpController.value.clear();
        return true;
      } else if (result == SendResult.rateLimited) {
        ShowToastDialog.showToast("Please wait before requesting a new OTP".tr);
        return false;
      } else {
        ShowToastDialog.showToast("Failed to resend OTP. Please try again.".tr);
        return false;
      }
    } catch (e) {
      debugPrint("Error resending OTP: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("An error occurred. Please try again.".tr);
      return false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.value.text.length != 6) {
      ShowToastDialog.showToast("Please enter a valid 6-digit OTP".tr);
      return;
    }

    ShowToastDialog.showLoader("Verifying OTP...".tr);

    try {
      final result = await _otpService.verifyOtp(
        fullPhoneNumber.value,
        otpController.value.text.trim(),
        countryCode: countryCode.value.replaceFirst('+', ''),
      );

      if (result == VerifyResult.success) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Phone verified successfully".tr);
        
        // Check if user exists in Firestore by phone number
        await _handleUserLoginOrSignup();
      } else if (result == VerifyResult.expired) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("OTP has expired. Please request a new one.".tr);
        otpController.value.clear();
      } else if (result == VerifyResult.invalid) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Invalid OTP. Please try again.".tr);
        otpController.value.clear();
      } else if (result == VerifyResult.blocked) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Too many failed attempts. Please try again after 1 hour.".tr);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("An error occurred. Please try again.".tr);
      }
    } catch (e) {
      debugPrint("Error verifying OTP: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("An error occurred. Please try again.".tr);
    }
  }

  Future<void> _handleUserLoginOrSignup() async {
    try {
      // Search for user by phone number
      final userQuery = await FirebaseFirestore.instance
          .collection(CollectionName.users)
          .where('phoneNumber', isEqualTo: phoneNumber.value)
          .where('countryCode', isEqualTo: countryCode.value)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // Existing user - login
        final userDoc = userQuery.docs.first;
        final userModel = UserModel.fromJson(userDoc.data());
        
        if (userModel.role == Constant.userRoleCustomer) {
          if (userModel.active == true) {
            userModel.fcmToken = await NotificationService.getToken();
            await FireStoreUtils.updateUser(userModel);
            
            if (userModel.shippingAddress != null && userModel.shippingAddress!.isNotEmpty) {
              if (userModel.shippingAddress!.where((element) => element.isDefault == true).isNotEmpty) {
                Constant.selectedLocation = userModel.shippingAddress!.where((element) => element.isDefault == true).single;
              } else {
                Constant.selectedLocation = userModel.shippingAddress!.first;
              }
              Get.offAll(const DashBoardScreen());
            } else {
              Get.offAll(const LocationPermissionScreen());
            }
          } else {
            ShowToastDialog.showToast("This user is disabled. Please contact administrator.".tr);
            Get.offAll(const LoginScreen());
          }
        } else {
          ShowToastDialog.showToast("Invalid user role".tr);
          Get.offAll(const LoginScreen());
        }
      } else {
        // New user - redirect to signup
        final userModel = UserModel();
        userModel.countryCode = countryCode.value;
        userModel.phoneNumber = phoneNumber.value;
        userModel.provider = 'phone';
        
        Get.off(const SignupScreen(), arguments: {
          "userModel": userModel,
          "type": "mobileNumber",
        });
      }
    } catch (e) {
      debugPrint("Error handling user login/signup: $e");
      ShowToastDialog.showToast("An error occurred. Please try again.".tr);
    }
  }
}
