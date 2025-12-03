import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/chat_screens/chat_screen.dart';
import 'package:customer/app/order_list_screen/live_tracking_screen.dart';
import 'package:customer/app/rate_us_screen/rate_product_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/order_details_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});



  
  Future<void> openMap(double latitude, double longitude) async {
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final appleMapsUrl = 'https://maps.apple.com/?q=$latitude,$longitude';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
      await launchUrl(Uri.parse(appleMapsUrl));
    } else {
      throw 'Could not launch map.';
    }
  }
 

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: OrderDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: Text(
                "Order Details".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: OrderTimeCountdown(
                              orderCreatedAt: controller.orderModel.value.createdAt,
                              vendorID: controller.orderModel.value.vendorID,
                            ),
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Order ${Constant.orderId(orderId: controller.orderModel.value.id.toString(), createdAt: controller.orderModel.value.createdAt)}".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 18,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () {
                                        _showQRCodeDialog(context, controller.orderModel.value.id.toString(), themeChange);
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
                              RoundedButtonFill(
                                title: controller.orderModel.value.status.toString().tr,
                                color: Constant.statusColor(status: controller.orderModel.value.status.toString()),
                                width: 32,
                                height: 4.5,
                                radius: 10,
                                textColor: Constant.statusText(status: controller.orderModel.value.status.toString()),
                                onPress: () async {},
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          controller.orderModel.value.takeAway == true
                              ? Container(
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${controller.orderModel.value.vendor!.title}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.semiBold,
                                                  fontSize: 16,
                                                  color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                ),
                                              ),
                                              Text(
                                                "${controller.orderModel.value.vendor!.location}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.medium,
                                                  fontSize: 14,
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller.orderModel.value.status == Constant.orderPlaced ||
                                                controller.orderModel.value.status == Constant.orderRejected ||
                                                controller.orderModel.value.status == Constant.orderCompleted
                                            ? const SizedBox()
                                            : InkWell(
                                                onTap: () {
                                                  Constant.makePhoneCall(controller.orderModel.value.vendor!.phonenumber.toString());
                                                },
                                                child: Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(120),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        controller.orderModel.value.status == Constant.orderPlaced ||
                                                controller.orderModel.value.status == Constant.orderRejected ||
                                                controller.orderModel.value.status == Constant.orderCompleted
                                            ? const SizedBox()
                                            : InkWell(
                                                onTap: () async {
                                                  ShowToastDialog.showLoader("Please wait".tr);

                                                  UserModel? customer = await FireStoreUtils.getUserProfile(controller.orderModel.value.authorID.toString());
                                                  UserModel? restaurantUser = await FireStoreUtils.getUserProfile(controller.orderModel.value.vendor!.author.toString());
                                                  VendorModel? vendorModel = await FireStoreUtils.getVendorById(restaurantUser!.vendorID.toString());
                                                  ShowToastDialog.closeLoader();

                                                  Get.to(const ChatScreen(), arguments: {
                                                    "customerName": '${customer!.fullName()}',
                                                    "restaurantName": vendorModel!.title,
                                                    "orderId": controller.orderModel.value.id,
                                                    "restaurantId": restaurantUser.id,
                                                    "customerId": customer.id,
                                                    "customerProfileImage": customer.profilePictureURL,
                                                    "restaurantProfileImage": vendorModel.photo,
                                                    "token": restaurantUser.fcmToken,
                                                    "chatType": "restaurant",
                                                  });
                                                },
                                                child: Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: ShapeDecoration(
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                      borderRadius: BorderRadius.circular(120),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SvgPicture.asset("assets/icons/ic_wechat.svg"),
                                                  ),
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      children: [
                                        Timeline.tileBuilder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics: const NeverScrollableScrollPhysics(),
                                          theme: TimelineThemeData(
                                            nodePosition: 0,
                                            // indicatorPosition: 0,
                                          ),
                                          builder: TimelineTileBuilder.connected(
                                            contentsAlign: ContentsAlign.basic,
                                            indicatorBuilder: (context, index) {
                                              return SvgPicture.asset("assets/icons/ic_location.svg");
                                            },
                                            connectorBuilder: (context, index, connectorType) {
                                              return const DashedLineConnector(
                                                color: AppThemeData.grey300,
                                                gap: 3,
                                              );
                                            },
                                            contentsBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: index == 0
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      "${controller.orderModel.value.vendor!.title}",
                                                                      textAlign: TextAlign.start,
                                                                      style: TextStyle(
                                                                        fontFamily: AppThemeData.semiBold,
                                                                        fontSize: 16,
                                                                        color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                                      ),
                                                                    ),
                                                                  
                                                                  IconButton(onPressed: (){
                                                                    openMap(controller.orderModel.value.address!.location!.latitude!, controller.orderModel.value.address!.location!.longitude!);
                                                                  }, icon: FaIcon(FontAwesomeIcons.mapLocationDot, color: Colors.black)),
                                                                  
                                                                  ],
                                                                ),
                                                                Text(
                                                                  "${controller.orderModel.value.vendor!.location}",
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),

                                                                Text(
                                                                  "${controller.orderModel.value.address?.location?.latitude}",
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),


                                                                                                                                Text(
                                                                  "${controller.orderModel.value.address?.location?.longitude}",
                                                                  textAlign: TextAlign.start,
                                                                  style: TextStyle(
                                                                    fontFamily: AppThemeData.medium,
                                                                    fontSize: 14,
                                                                    color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                  ),
                                                                ),


                                                              ],
                                                            ),
                                                          ),
                                                          controller.orderModel.value.status == Constant.orderPlaced ||
                                                                  controller.orderModel.value.status == Constant.orderRejected ||
                                                                  controller.orderModel.value.status == Constant.orderCompleted
                                                              ? const SizedBox()
                                                              : InkWell(
                                                                  onTap: () {
                                                                    Constant.makePhoneCall(controller.orderModel.value.vendor!.phonenumber.toString());
                                                                  },
                                                                  child: Container(
                                                                    width: 42,
                                                                    height: 42,
                                                                    decoration: ShapeDecoration(
                                                                      shape: RoundedRectangleBorder(
                                                                        side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                        borderRadius: BorderRadius.circular(120),
                                                                      ),
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                                    ),
                                                                  ),
                                                                ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          controller.orderModel.value.status == Constant.orderPlaced ||
                                                                  controller.orderModel.value.status == Constant.orderRejected ||
                                                                  controller.orderModel.value.status == Constant.orderCompleted
                                                              ? const SizedBox()
                                                              : InkWell(
                                                                  onTap: () async {
                                                                    ShowToastDialog.showLoader("Please wait".tr);

                                                                    UserModel? customer = await FireStoreUtils.getUserProfile(controller.orderModel.value.authorID.toString());
                                                                    UserModel? restaurantUser =
                                                                        await FireStoreUtils.getUserProfile(controller.orderModel.value.vendor!.author.toString());
                                                                    VendorModel? vendorModel = await FireStoreUtils.getVendorById(restaurantUser!.vendorID.toString());
                                                                    ShowToastDialog.closeLoader();

                                                                    Get.to(const ChatScreen(), arguments: {
                                                                      "customerName": '${customer!.fullName()}',
                                                                      "restaurantName": vendorModel!.title,
                                                                      "orderId": controller.orderModel.value.id,
                                                                      "restaurantId": restaurantUser.id,
                                                                      "customerId": customer.id,
                                                                      "customerProfileImage": customer.profilePictureURL,
                                                                      "restaurantProfileImage": vendorModel.photo,
                                                                      "token": restaurantUser.fcmToken,
                                                                      "chatType": "restaurant",
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                    width: 42,
                                                                    height: 42,
                                                                    decoration: ShapeDecoration(
                                                                      shape: RoundedRectangleBorder(
                                                                        side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                        borderRadius: BorderRadius.circular(120),
                                                                      ),
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: SvgPicture.asset("assets/icons/ic_wechat.svg"),
                                                                    ),
                                                                  ),
                                                                )
                                                        ],
                                                      )
                                                    : Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "${controller.orderModel.value.address!.addressAs}",
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily: AppThemeData.semiBold,
                                                              fontSize: 16,
                                                              color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                            ),
                                                          ),
                                                          Text(
                                                            controller.orderModel.value.address!.getFullAddress(),
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily: AppThemeData.medium,
                                                              fontSize: 14,
                                                              color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              );
                                            },
                                            itemCount: 2,
                                          ),
                                        ),
                                        controller.orderModel.value.status == Constant.orderRejected
                                            ? const SizedBox()
                                            : Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                                    child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                  ),
                                                  controller.orderModel.value.status == Constant.orderCompleted && controller.orderModel.value.driver != null
                                                      ? Row(
                                                          children: [
                                                            SvgPicture.asset("assets/icons/ic_check_small.svg"),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              // "mystery box",
                                                              controller.orderModel.value.driver!.fullName(),
                                                              textAlign: TextAlign.right,
                                                              style: TextStyle(
                                                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                                fontFamily: AppThemeData.semiBold,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "Order Delivered.".tr,
                                                              textAlign: TextAlign.right,
                                                              style: TextStyle(
                                                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                                fontFamily: AppThemeData.regular,
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : controller.orderModel.value.status == Constant.orderAccepted || controller.orderModel.value.status == Constant.driverPending
                                                          ? Row(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SvgPicture.asset("assets/icons/ic_timer.svg"),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    "Your Order has been Preparing and assign to the driver\n Preparation Time ${controller.orderModel.value.estimatedTimeToPrepare}"
                                                                        .tr,
                                                                    textAlign: TextAlign.start,
                                                                    style: TextStyle(
                                                                      color: themeChange.getThem() ? AppThemeData.warning400 : AppThemeData.warning400,
                                                                      fontFamily: AppThemeData.semiBold,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : controller.orderModel.value.driver != null
                                                              ? Row(
                                                                  children: [
                                                                    ClipOval(
                                                                      child: NetworkImageWidget(
                                                                        imageUrl: controller.orderModel.value.author!.profilePictureURL.toString(),
                                                                        fit: BoxFit.cover,
                                                                        height: Responsive.height(5, context),
                                                                        width: Responsive.width(10, context),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            // "mystery box",
                                                                            controller.orderModel.value.driver!.fullName().toString(),
                                                                            textAlign: TextAlign.start,
                                                                            style: TextStyle(
                                                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                              fontFamily: AppThemeData.semiBold,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: 16,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            controller.orderModel.value.driver!.email.toString(),
                                                                            textAlign: TextAlign.start,
                                                                            style: TextStyle(
                                                                              color: themeChange.getThem() ? AppThemeData.success400 : AppThemeData.success400,
                                                                              fontFamily: AppThemeData.regular,
                                                                              fontWeight: FontWeight.w400,
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        Constant.makePhoneCall(controller.orderModel.value.driver!.phoneNumber.toString());
                                                                      },
                                                                      child: Container(
                                                                        width: 42,
                                                                        height: 42,
                                                                        decoration: ShapeDecoration(
                                                                          shape: RoundedRectangleBorder(
                                                                            side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                            borderRadius: BorderRadius.circular(120),
                                                                          ),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: SvgPicture.asset("assets/icons/ic_phone_call.svg"),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () async {
                                                                        ShowToastDialog.showLoader("Please wait".tr);

                                                                        UserModel? customer = await FireStoreUtils.getUserProfile(controller.orderModel.value.authorID.toString());
                                                                        UserModel? restaurantUser =
                                                                            await FireStoreUtils.getUserProfile(controller.orderModel.value.driverID.toString());

                                                                        ShowToastDialog.closeLoader();

                                                                        Get.to(const ChatScreen(), arguments: {
                                                                          "customerName": '${customer!.fullName()}',
                                                                          "restaurantName": restaurantUser!.fullName(),
                                                                          "orderId": controller.orderModel.value.id,
                                                                          "restaurantId": restaurantUser.id,
                                                                          "customerId": customer.id,
                                                                          "customerProfileImage": customer.profilePictureURL,
                                                                          "restaurantProfileImage": restaurantUser.profilePictureURL,
                                                                          "token": restaurantUser.fcmToken,
                                                                          "chatType": "Driver",
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                        width: 42,
                                                                        height: 42,
                                                                        decoration: ShapeDecoration(
                                                                          shape: RoundedRectangleBorder(
                                                                            side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                                                            borderRadius: BorderRadius.circular(120),
                                                                          ),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: SvgPicture.asset("assets/icons/ic_wechat.svg"),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                )
                                                              : const SizedBox(),
                                                ],
                                              ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            "Your Order".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              fontSize: 16,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: controller.orderModel.value.products!.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  CartProductModel cartProductModel = controller.orderModel.value.products![index];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(14)),
                                            child: Stack(
                                              children: [
                                                Image.asset(
                                                  "assets/images/mysterybox.png",
                                                    height: Responsive.height(8, context),
                                                    width: Responsive.width(16, context),
                                                    fit: BoxFit.cover,
                                                ),
                                                // NetworkImageWidget(
                                                //   imageUrl: cartProductModel.photo.toString(),
                                                //   height: Responsive.height(8, context),
                                                //   width: Responsive.width(16, context),
                                                //   fit: BoxFit.cover,
                                                // ),
                                                Container(
                                                  height: Responsive.height(8, context),
                                                  width: Responsive.width(16, context),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: const Alignment(-0.00, -1.00),
                                                      end: const Alignment(0, 1),
                                                      colors: [Colors.black.withOpacity(0), const Color(0xFF111827)],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "mystery box",
                                                        // "${cartProductModel.name}",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily: AppThemeData.regular,
                                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "x ${cartProductModel.quantity}",
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.regular,
                                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                double.parse(cartProductModel.discountPrice == null || cartProductModel.discountPrice!.isEmpty
                                                            ? "0.0"
                                                            : cartProductModel.discountPrice.toString()) <=
                                                        0
                                                    ? Text(
                                                        Constant.amountShow(amount: cartProductModel.price),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                          fontFamily: AppThemeData.semiBold,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      )
                                                    : Row(
                                                        children: [
                                                          Text(
                                                            Constant.amountShow(amount: cartProductModel.discountPrice.toString()),
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                              fontFamily: AppThemeData.semiBold,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            Constant.amountShow(amount: cartProductModel.price),
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              decoration: TextDecoration.lineThrough,
                                                              decorationColor: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                              fontFamily: AppThemeData.semiBold,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                Align(
                                                  alignment: Alignment.centerRight,
                                                  child: RoundedButtonFill(
                                                    title: "Rate us".tr,
                                                    height: 3.8,
                                                    width: 20,
                                                    color: themeChange.getThem() ? AppThemeData.warning300 : AppThemeData.warning300,
                                                    textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                    onPress: () async {
                                                      Get.to(const RateProductScreen(), arguments: {"orderModel": controller.orderModel.value, "productId": cartProductModel.id});
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      cartProductModel.variantInfo == null || cartProductModel.variantInfo!.variantOptions!.isEmpty
                                          ? Container()
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Variants",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.semiBold,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Wrap(
                                                    spacing: 6.0,
                                                    runSpacing: 6.0,
                                                    children: List.generate(
                                                      cartProductModel.variantInfo!.variantOptions!.length,
                                                      (i) {
                                                        return Container(
                                                          decoration: ShapeDecoration(
                                                            color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                                            child: Text(
                                                              "${cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)} : ${cartProductModel.variantInfo!.variantOptions![cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                fontFamily: AppThemeData.medium,
                                                                color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).toList(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      cartProductModel.extras == null || cartProductModel.extras!.isEmpty
                                          ? const SizedBox()
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Addons",
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily: AppThemeData.semiBold,
                                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      Constant.amountShow(
                                                          amount: (double.parse(cartProductModel.extrasPrice.toString()) * double.parse(cartProductModel.quantity.toString()))
                                                              .toString()),
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.semiBold,
                                                        color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Wrap(
                                                  spacing: 6.0,
                                                  runSpacing: 6.0,
                                                  children: List.generate(
                                                    cartProductModel.extras!.length,
                                                    (i) {
                                                      return Container(
                                                        decoration: ShapeDecoration(
                                                          color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                                          child: Text(
                                                            cartProductModel.extras![i].toString(),
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily: AppThemeData.medium,
                                                              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).toList(),
                                                ),
                                              ],
                                            ),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            "Bill Details".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              fontSize: 16,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Item totals".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: controller.subTotal.value.toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  controller.orderModel.value.takeAway == true
                                      ? const SizedBox()
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Delivery Fee".tr,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.regular,
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(
                                                  amount: controller.orderModel.value.deliveryCharge == null || controller.orderModel.value.deliveryCharge!.isEmpty
                                                      ? "0.0"
                                                      : controller.orderModel.value.deliveryCharge.toString()),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Coupon Discount".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "- (${Constant.amountShow(amount: controller.orderModel.value.discount.toString())})",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  controller.orderModel.value.specialDiscount != null && controller.orderModel.value.specialDiscount!['special_discount'] != null
                                      ? Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Special Discount".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.regular,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "- (${Constant.amountShow(amount: controller.specialDiscountAmount.value.toString())})",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily: AppThemeData.regular,
                                                    color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const SizedBox(
                                    height: 10,
                                  ),

                                  controller.orderModel.value.takeAway == true
                                      ? const SizedBox()
                                      : Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Delivery Tips".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily: AppThemeData.regular,
                                                      color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(amount: controller.orderModel.value.tipAmount.toString()),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                  
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.builder(
                                    itemCount: controller.orderModel.value.taxSetting!.length,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      TaxModel taxModel = controller.orderModel.value.taxSetting![index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${taxModel.title.toString()} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.regular,
                                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              Constant.amountShow(
                                                  amount: Constant.calculateTax(
                                                          amount: (controller.subTotal.value -
                                                                  double.parse(controller.orderModel.value.discount.toString()) -
                                                                  controller.specialDiscountAmount.value)
                                                              .toString(),
                                                          taxModel: taxModel)
                                                      .toString()),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "To Pay".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: controller.totalAmount.value.toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            "Order Details".tr,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.semiBold,
                              fontSize: 16,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Delivery type".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.orderModel.value.takeAway == true
                                            ? "TakeAway".tr
                                            : controller.orderModel.value.scheduleTime == null
                                                ? "Standard".tr
                                                : "Schedule".tr,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          color: controller.orderModel.value.scheduleTime != null
                                              ? AppThemeData.primary300
                                              : themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Payment Method".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.orderModel.value.paymentMethod.toString(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Date and Time".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.timestampToDateTime(controller.orderModel.value.createdAt!),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Phone Number".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.regular,
                                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        controller.orderModel.value.author!.phoneNumber.toString(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.regular,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          controller.orderModel.value.notes == null || controller.orderModel.value.notes!.isEmpty
                              ? const SizedBox()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Remarks".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                        child: Text(
                                          controller.orderModel.value.notes.toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: controller.orderModel.value.status == Constant.orderShipped ||
                    controller.orderModel.value.status == Constant.orderInTransit ||
                    controller.orderModel.value.status == Constant.orderCompleted
                ? Container(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: controller.orderModel.value.status == Constant.orderShipped || controller.orderModel.value.status == Constant.orderInTransit
                          ? RoundedButtonFill(
                              title: "Track Order".tr,
                              height: 5.5,
                              color: AppThemeData.warning300,
                              textColor: AppThemeData.grey900,
                              onPress: () async {
                                Get.to(const LiveTrackingScreen(), arguments: {"orderModel": controller.orderModel.value});
                              },
                            )
                          : RoundedButtonFill(
                              title: "Reorder".tr,
                              height: 5.5,
                              color: AppThemeData.primary300,
                              textColor: AppThemeData.grey50,
                              onPress: () async {
                                for (var element in controller.orderModel.value.products!) {
                                  controller.addToCart(cartProductModel: element);
                                  ShowToastDialog.showToast("Item Added In a cart");
                                }
                              },
                            ),
                    ),
                  )
                : const SizedBox(),
          );
        });
  }
}








class OrderTimeCountdown extends StatefulWidget {
  final Timestamp? orderCreatedAt; // الوقت الذي تم فيه إنشاء الطلب
  final String? vendorID; // Vendor ID to fetch DeliveryTimeRange
  OrderTimeCountdown({this.orderCreatedAt, this.vendorID});

  @override
  _OrderTimeCountdownState createState() => _OrderTimeCountdownState();
}

class _OrderTimeCountdownState extends State<OrderTimeCountdown> {
  Timer? _timer;
  late Duration _remainingTime;
  int _deliveryTimeMinutes = 60; // Default to 1 hour (60 minutes)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendorDeliveryTime();
  }

  // Fetch vendor DeliveryTimeRange from Firebase
  Future<void> _fetchVendorDeliveryTime() async {
    if (widget.vendorID != null && widget.vendorID!.isNotEmpty) {
      try {
        VendorModel? vendorModel = await FireStoreUtils.getVendorById(widget.vendorID!);
        if (vendorModel != null && vendorModel.deliveryTimeRange != null && vendorModel.deliveryTimeRange!.isNotEmpty) {
          // Parse DeliveryTimeRange (it's a string like "45" meaning 45 minutes)
          int? parsedTime = int.tryParse(vendorModel.deliveryTimeRange!);
          if (parsedTime != null && parsedTime > 0) {
            _deliveryTimeMinutes = parsedTime;
          }
        }
      } catch (e) {
        // If error, use default 1 hour
        _deliveryTimeMinutes = 60;
      }
    }

    // Calculate remaining time after fetching delivery time
    if (widget.orderCreatedAt != null) {
      _remainingTime = _calculateRemainingTime(widget.orderCreatedAt!);
      // If time is already expired, set to zero
      if (_remainingTime.isNegative) {
        _remainingTime = Duration.zero;
      }
    } else {
      _remainingTime = Duration.zero;
    }

    setState(() {
      _isLoading = false;
    });

    // بدء التوقيت التنازلي فقط إذا كان هناك وقت متبقي
    if (_remainingTime.inSeconds > 0) {
      _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
    }
  }

  // دالة لحساب الوقت المتبقي
  Duration _calculateRemainingTime(Timestamp createdAt) {
    DateTime now = DateTime.now();
    DateTime orderTime = createdAt.toDate(); // تحويل Timestamp إلى DateTime
    return orderTime.add(Duration(minutes: _deliveryTimeMinutes)).difference(now); // إضافة المدة من Firebase أو ساعة افتراضية
  }

  // دالة لتحديث الوقت كل ثانية
  void _updateTime(Timer timer) {
    setState(() {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime = _remainingTime - Duration(seconds: 1);
      } else {
        _remainingTime = Duration.zero; // إيقاف التوقيت عند الوصول إلى صفر
        _timer?.cancel(); // إيقاف التايمر
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // إيقاف التايمر عند التخلص من الودجت
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // تحويل الوقت المتبقي إلى تنسيق مناسب (دقائق وثواني)
    String minutes = (_remainingTime.inMinutes).toString().padLeft(2, '0');
    String seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الدائرة المتحركة
          CustomPaint(
            size: Size(100, 100),
            painter: CountdownPainter(_remainingTime, _deliveryTimeMinutes),
          ),
          // عرض الوقت داخل الدائرة
          if (_remainingTime.inSeconds > 0)
            Text(
              "$minutes:$seconds", // عرض الوقت المتبقي
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          // عرض "انتهى الوقت" في حالة انتهاء الوقت
          if (_remainingTime.inSeconds <= 0)
            Text(
              "Time Expired",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}

// CustomPainter لرسم الدائرة المتحركة
class CountdownPainter extends CustomPainter {
  final Duration remainingTime;
  final int deliveryTimeMinutes;

  CountdownPainter(this.remainingTime, this.deliveryTimeMinutes);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    // رسم الدائرة الأساسية
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    // حساب نسبة الوقت المتبقي - استخدام المدة الفعلية من Firebase
    int totalSeconds = deliveryTimeMinutes * 60; // تحويل الدقائق إلى ثواني
    double progress = totalSeconds > 0 ? 1.0 - (remainingTime.inSeconds / totalSeconds) : 0.0;

    // تغيير اللون حسب التقدم في العد التنازلي
    Color circleColor;
    if (progress > 0.5) {
      circleColor = Colors.green;
    } else if (progress > 0.2) {
      circleColor = AppThemeData.primary300;
    } else {
      circleColor = Colors.red;
    }

    // رسم الدائرة المتحركة
    paint
      ..color = circleColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    double sweepAngle = 2 * 3.14159 * progress; // زاوية الجزء المرسوم

    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      -3.14159 / 2, // بداية من الأعلى
      sweepAngle, // زاوية التقدم
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // إعادة الرسم كلما تغير الوقت
  }
}

/// Show QR Code Dialog
void _showQRCodeDialog(BuildContext context, String orderId, DarkThemeProvider themeChange) {
  showDialog(
    context: context,
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
              // Title
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

