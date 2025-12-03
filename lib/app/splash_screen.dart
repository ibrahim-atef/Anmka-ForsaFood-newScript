import 'package:customer/controllers/splash_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppThemeData.primary300,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    "assets/images/splach.png",
                    height: 150,
                    width: 150, // لازم تحدد عرض متساوٍ للطول عشان يكون دائري
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  "Welcome to Foodie".tr,
                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50, fontSize: 28, fontFamily: AppThemeData.bold),
                ),
                Text(
                  "Your Favorite Food Delivered Fast!".tr,
                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
