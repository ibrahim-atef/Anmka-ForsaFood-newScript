import 'package:customer/app/auth_screen/otp_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/services/otp_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;
  
  final OtpService _otpService = OtpService();

  sendCode() async {
    if (phoneNUmberEditingController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter mobile number".tr);
      return;
    }

    if (phoneNUmberEditingController.value.text.length < 8) {
      ShowToastDialog.showToast("Please enter a valid phone number".tr);
      return;
    }

    ShowToastDialog.showLoader("Sending OTP...".tr);
    
    try {
      final countryCode = countryCodeEditingController.value.text.isEmpty 
          ? '+20' 
          : countryCodeEditingController.value.text;
      
      final result = await _otpService.sendOtp(
        phoneNUmberEditingController.value.text.trim(),
        countryCode: countryCode.replaceFirst('+', ''),
      );

      ShowToastDialog.closeLoader();

      if (result == SendResult.success) {
        final normalizedPhone = _otpService.normalizePhone(
          phoneNUmberEditingController.value.text.trim(),
          countryCode: countryCode.replaceFirst('+', ''),
        );
        
        ShowToastDialog.showToast("OTP sent successfully".tr);
        
        Get.to(const OtpScreen(), arguments: {
          "countryCode": countryCode,
          "phoneNumber": normalizedPhone.replaceFirst(countryCode, ''),
          "fullPhoneNumber": normalizedPhone, // Store full number for verification
        });
      } else if (result == SendResult.rateLimited) {
        ShowToastDialog.showToast("Please wait before requesting a new OTP".tr);
      } else {
        ShowToastDialog.showToast("Failed to send OTP. Please try again.".tr);
      }
    } catch (e) {
      debugPrint("Error sending OTP: $e");
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("An error occurred. Please try again.".tr);
    }
  }
}
