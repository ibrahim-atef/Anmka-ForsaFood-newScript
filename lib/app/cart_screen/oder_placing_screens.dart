import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/controllers/order_placing_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderPlacingScreen extends StatelessWidget {
  const OrderPlacingScreen({super.key});



Widget buildInfoRow({
  required String icon,
  required String title,
  required String value,
  required dynamic themeChange,
  bool isSvg = true,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isSvg)
            Image.asset(              
              icon,
              width: 30,
              height: 40,
              ),
              if (isSvg)
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                AppThemeData.primary300,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 16,
                  color: AppThemeData.primary300,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppThemeData.medium,
              fontSize: 14,
              color: themeChange.getThem()
                  ? AppThemeData.grey400
                  : AppThemeData.grey500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildInfoRowWithQR({
  required String icon,
  required String title,
  required String value,
  required String orderId,
  required dynamic themeChange,
  bool isSvg = true,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isSvg)
            Image.asset(              
              icon,
              width: 30,
              height: 40,
              ),
              if (isSvg)
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                AppThemeData.primary300,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 16,
                  color: AppThemeData.primary300,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 14,
                  color: themeChange.getThem()
                      ? AppThemeData.grey400
                      : AppThemeData.grey500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  _showQRCodeDialog(orderId, themeChange);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      size: 16,
                      color: AppThemeData.primary300,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Show QR Code".tr,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 14,
                        color: AppThemeData.primary300,
                        decoration: TextDecoration.underline,
                        decorationColor: AppThemeData.primary300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showQRCodeDialog(String orderId, dynamic themeChange) {
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order QR Code".tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                      fontFamily: AppThemeData.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                "Scan this QR code to view order details".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey600,
                  fontFamily: AppThemeData.regular,
                ),
              ),
              const SizedBox(height: 24),
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: orderId,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ),
              const SizedBox(height: 16),
              // Order ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppThemeData.primary300.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppThemeData.primary300.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.confirmation_number_outlined,
                      size: 18,
                      color: AppThemeData.primary300,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Order ID: $orderId",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppThemeData.primary300,
                          fontFamily: AppThemeData.medium,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeData.primary300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Close".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: OrderPlacingController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : controller.isPlacing.value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order Placed".tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey900,
                                fontSize: 34,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // Text(
                            //   "Your delicious meal is on its way! Sit tight and we’ll handle the rest.".tr,
                            //   textAlign: TextAlign.start,
                            //   style: TextStyle(
                            //     color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                            //     fontSize: 16,
                            //     fontFamily: AppThemeData.regular,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                            const SizedBox(
                              height: 40,
                            ),
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: 
  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    buildInfoRowWithQR(
      icon: "assets/icons/ic_order.png",
      title: "Order ID",
      value: Constant.orderId(orderId: controller.orderModel.value.id.toString(), createdAt: controller.orderModel.value.createdAt),
      orderId: controller.orderModel.value.id.toString(),
      themeChange: themeChange,
      isSvg: false,
    ),
    // buildInfoRow(
    //   icon: "assets/icons/ic_order.png",
    //   title: "Resturant name".tr,
    //   value: controller.orderModel.value.vendor!.authorName!,
    //   themeChange: themeChange,
    //   isSvg: false,
    // ),
    // buildInfoRow(
    //   icon: "assets/icons/ic_takeaway.svg",
    //   title: "TakeAway".tr,
    //   value: controller.orderModel.value.takeAway.toString(),
    //   themeChange: themeChange,
    // ),
    // buildInfoRow(
    //   icon: "assets/icons/ic_payment.svg",
    //   title: "Payment Method".tr,
    //   value: controller.orderModel.value.paymentMethod.toString(),
    //   themeChange: themeChange,
    // ),
// buildInfoRow(
//   icon: "assets/icons/ic_order.png",
//   title: "Status",
//   value: controller.orderModel.value.status ?? "N/A",
//   themeChange: themeChange,
//   isSvg: false,
// ),


    buildInfoRow(
      icon: "assets/icons/ic_order.png",
      title: "Location".tr,
      value: controller.orderModel.value.address!.locality.toString(),
      themeChange: themeChange,
      isSvg: false,

    ),

  if (controller.orderModel.value.notes != null && controller.orderModel.value.notes!.isNotEmpty)
  buildInfoRow(
    icon: "assets/icons/ic_order.png",
    title: "Notes",
    value: controller.orderModel.value.notes!,
    themeChange: themeChange,
    isSvg: false,
  ),

  ],
)

                            
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/images/ic_timer.gif",
                                height: 140,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Placing your order".tr,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey900,
                                fontSize: 34,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // Text(
                            //   "Review your items and proceed to checkout for a delicious experience.".tr,
                            //   textAlign: TextAlign.start,
                            //   style: TextStyle(
                            //     color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                            //     fontSize: 16,
                            //     fontFamily: AppThemeData.regular,
                            //     fontWeight: FontWeight.w400,
                            //   ),
                            // ),
                            const SizedBox(
                              height: 40,
                            ),
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_location.svg",
                                          colorFilter: ColorFilter.mode(
                                              AppThemeData.primary300,
                                              BlendMode.srcIn),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Delivery Address",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.primary300
                                                  : AppThemeData.primary300,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      controller.orderModel.value.address!
                                          .getFullAddress(),
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.medium,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey400
                                            : AppThemeData.grey500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_book.svg",
                                          colorFilter: ColorFilter.mode(
                                              AppThemeData.primary300,
                                              BlendMode.srcIn),
                                          height: 22,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Order Summary",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.primary300
                                                  : AppThemeData.primary300,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: controller
                                          .orderModel.value.products!.length,
                                      itemBuilder: (context, index) {
                                        CartProductModel cartProductModel =
                                            controller.orderModel.value
                                                .products![index];
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${cartProductModel.quantity} x"
                                                  .tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey100
                                                    : AppThemeData.grey900,
                                                fontSize: 14,
                                                fontFamily:
                                                    AppThemeData.regular,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Text(
                                              "${cartProductModel.name}".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey100
                                                    : AppThemeData.grey900,
                                                fontSize: 14,
                                                fontFamily:
                                                    AppThemeData.regular,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemeData.grey900
                  : AppThemeData.grey50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: controller.isPlacing.value
                    ? RoundedButtonFill(
                        title: "Track Order".tr,
                        height: 5.5,
                        color: AppThemeData.primary300,
                        textColor: AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {
                          Get.offAll(const DashBoardScreen());
                          DashBoardController controller =
                              Get.put(DashBoardController());
                          controller.selectedIndex.value = 3;
                        },
                      )
                    : RoundedButtonFill(
                        title: "Track Order".tr,
                        height: 5.5,
                        color: themeChange.getThem()
                            ? AppThemeData.grey700
                            : AppThemeData.grey200,
                        textColor: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {},
                      ),
              ),
            ),
          );
        });
  }
}
