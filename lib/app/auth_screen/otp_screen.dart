import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/auth_screen/signup_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/otp_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OtpController>(
        init: OtpController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Verify Your Number 📱".tr,
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                          ),
                          Text(
                            "Enter the OTP sent to your mobile number. ${controller.countryCode.value} ${Constant.maskingString(controller.phoneNumber.value, 3)}".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                              fontSize: 16,
                              fontFamily: AppThemeData.regular,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: PinCodeTextField(
                              length: 6,
                              appContext: context,
                              keyboardType: TextInputType.phone,
                              enablePinAutofill: true,
                              hintCharacter: "-",
                              textStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.regular),
                              pinTheme: PinTheme(
                                  fieldHeight: 50,
                                  fieldWidth: 45, // Reduced from 50 to fit better
                                  inactiveFillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  selectedFillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  activeFillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  selectedColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  activeColor: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                  inactiveColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  disabledColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  shape: PinCodeFieldShape.box,
                                  errorBorderColor: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey300,
                                  borderRadius: const BorderRadius.all(Radius.circular(10))),
                              cursorColor: AppThemeData.primary300,
                              enableActiveFill: true,
                              controller: controller.otpController.value,
                              onCompleted: (v) async {},
                              onChanged: (value) {},
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          RoundedButtonFill(
                            title: "Verify & Next".tr,
                            color: AppThemeData.primary300,
                            textColor: AppThemeData.grey50,
                            onPress: () async {
                              if (controller.otpController.value.text.length == 6) {
                                await controller.verifyOtp();
                              } else {
                                ShowToastDialog.showToast("Enter Valid otp".tr);
                              }
                            },
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text.rich(
                            textAlign: TextAlign.start,
                            TextSpan(
                              text: "${'Did’t receive any code? '.tr} ",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                fontFamily: AppThemeData.medium,
                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      controller.otpController.value.clear();
                                      controller.sendOTP();
                                    },
                                  text: 'Send Again'.tr,
                                  style: TextStyle(
                                      color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: AppThemeData.medium,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppThemeData.primary300),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        });
  }
}
