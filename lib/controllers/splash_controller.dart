import 'dart:async';
import 'dart:developer';

import 'package:customer/app/auth_screen/email_verification_screen.dart';
import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/app/on_boarding_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/auth_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  redirectScreen() async {
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      Get.offAll(const OnBoardingScreen());
    } else {
      bool isLogin = await FireStoreUtils.isLogin();
      if (isLogin == true) {
        // Check email verification for email/password users
        final authService = AuthService();
        if (authService.requiresEmailVerification()) {
          // Get user email BEFORE signing out
          String? userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
          
          // Sign out unverified user
          await FirebaseAuth.instance.signOut();
          
          // Navigate to email verification screen
          Get.offAll(() => EmailVerificationScreen(
            email: userEmail,
          ));
          return;
        }
        
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
            .then((value) async {
          if (value != null) {
            UserModel userModel = value;
            log(userModel.toJson().toString());
            if (userModel.role == Constant.userRoleCustomer) {
              if (userModel.active == true) {
                userModel.fcmToken = await NotificationService.getToken();
                await FireStoreUtils.updateUser(userModel);
                if (userModel.shippingAddress != null &&
                    userModel.shippingAddress!.isNotEmpty) {
                  if (userModel.shippingAddress!
                      .where((element) => element.isDefault == true)
                      .isNotEmpty) {
                    Constant.selectedLocation = userModel.shippingAddress!
                        .where((element) => element.isDefault == true)
                        .single;
                  } else {
                    Constant.selectedLocation =
                        userModel.shippingAddress!.first;
                  }
                  Get.offAll(const DashBoardScreen());
                } else {
                  Get.offAll(const DashBoardScreen());
                }
              } else {
                await FirebaseAuth.instance.signOut();
                Get.offAll(const LoginScreen());
              }
            } else {
              await FirebaseAuth.instance.signOut();
              Get.offAll(const LoginScreen());
            }
          }
        });
      } else {
        await FirebaseAuth.instance.signOut();
        Get.offAll(const LoginScreen());
      }
    }
  }
}
