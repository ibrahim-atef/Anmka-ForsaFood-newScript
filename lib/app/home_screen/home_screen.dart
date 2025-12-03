import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/app/home_screen/category_restaurant_screen.dart';
import 'package:customer/app/home_screen/discount_restaurant_list_screen.dart';
import 'package:customer/app/home_screen/restaurant_list_screen.dart';
import 'package:customer/app/home_screen/story_view.dart';
import 'package:customer/app/home_screen/view_all_category_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/app/scan_qrcode_screen/scan_qr_code_screen.dart';
import 'package:customer/app/search_screen/search_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/controllers/home_controller.dart';
import 'package:customer/controllers/map_view_controller.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/custom_dialog_box.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/widget/place_picker_osm.dart';
import 'package:customer/widget/restaurant_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osmMap;
import '../../themes/text_field_widget.dart';

import 'dart:ui' as ui;

import 'package:collection/collection.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem()
              ? AppThemeData.grey900
              : AppThemeData.grey50,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0.00, -3),
                colors: [
                  themeChange.getThem()
                      ? AppThemeData.secondary600
                      : AppThemeData.secondary50,
                  themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.surface
                ],
                end: const Alignment(0, 1),
              ),
            ),
            child: controller.isLoading.value
                ? Constant.loader()
                : Constant.isZoneAvailable == false ||
                        controller.allNearestRestaurant.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          await controller.getData();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/location.gif",
                                height: 120,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "No Restaurants Found in Your Area".tr,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey100
                                        : AppThemeData.grey800,
                                    fontSize: 22,
                                    fontFamily: AppThemeData.semiBold),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Currently, there are no available restaurants in your zone. Try changing your location to find nearby options."
                                    .tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey500,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              RoundedButtonFill(
                                title: "Change Zone".tr,
                                width: 55,
                                height: 5.5,
                                color: AppThemeData.primary300,
                                textColor: AppThemeData.grey50,
                                onPress: () async {
                                  Get.offAll(const LocationPermissionScreen());
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await controller.getData();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).viewPadding.top),
                          child: controller.isListView.value == false
                              ? const MapView()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  DashBoardController
                                                      dashBoardController =
                                                      Get.put(
                                                          DashBoardController());
                                                  if (Constant.walletSetting ==
                                                      false) {
                                                    dashBoardController
                                                        .selectedIndex
                                                        .value = 3;
                                                  } else {
                                                    dashBoardController
                                                        .selectedIndex
                                                        .value = 4;
                                                  }
                                                },
                                                child: ClipOval(
                                                  child: NetworkImageWidget(
                                                    imageUrl: Constant
                                                                .userModel ==
                                                            null
                                                        ? ""
                                                        : Constant.userModel!
                                                            .profilePictureURL
                                                            .toString(),
                                                    height: 40,
                                                    width: 40,
                                                    fit: BoxFit.cover,
                                                    errorWidget: Image.asset(
                                                      Constant.userPlaceHolder,
                                                      fit: BoxFit.cover,
                                                      height: 40,
                                                      width: 40,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Constant.userModel == null
                                                        ? InkWell(
                                                            onTap: () {
                                                              Get.offAll(
                                                                  const LoginScreen());
                                                            },
                                                            child: Text(
                                                              "Login".tr,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .medium,
                                                                color: themeChange
                                                                        .getThem()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey900,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          )
                                                        : Text(
                                                            "${Constant.userModel!.fullName()}",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                    InkWell(
                                                      onTap: () async {
                                                        if (Constant
                                                                .userModel !=
                                                            null) {
                                                          Get.to(const AddressListScreen())!
                                                              .then(
                                                            (value) {
                                                              if (value !=
                                                                  null) {
                                                                ShippingAddress
                                                                    addressModel =
                                                                    value;
                                                                Constant.selectedLocation =
                                                                    addressModel;
                                                                controller
                                                                    .getData();
                                                              }
                                                            },
                                                          );
                                                        } else {
                                                          Constant
                                                              .checkPermission(
                                                                  onTap:
                                                                      () async {
                                                                    ShowToastDialog.showLoader(
                                                                        "Please wait"
                                                                            .tr);
                                                                    ShippingAddress
                                                                        addressModel =
                                                                        ShippingAddress();
                                                                    try {
                                                                      await Geolocator
                                                                          .requestPermission();
                                                                      await Geolocator
                                                                          .getCurrentPosition();
                                                                      ShowToastDialog
                                                                          .closeLoader();
                                                                      if (Constant
                                                                              .selectedMapType ==
                                                                          'osm') {
                                                                        Get.to(
                                                                            () =>
                                                                                const LocationPicker())?.then(
                                                                            (value) {
                                                                          if (value !=
                                                                              null) {
                                                                            ShippingAddress
                                                                                addressModel =
                                                                                ShippingAddress();
                                                                            addressModel.addressAs =
                                                                                "Home";
                                                                            addressModel.locality =
                                                                                value.displayName!.toString();
                                                                            addressModel.location =
                                                                                UserLocation(latitude: value.lat, longitude: value.lon);
                                                                            Constant.selectedLocation =
                                                                                addressModel;
                                                                            controller.getData();
                                                                          }
                                                                        });
                                                                      } else {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                PlacePicker(
                                                                              apiKey: Constant.mapAPIKey,
                                                                              onPlacePicked: (result) async {
                                                                                ShippingAddress addressModel = ShippingAddress();
                                                                                addressModel.addressAs = "Home";
                                                                                addressModel.locality = result.formattedAddress!.toString();
                                                                                addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                                                                Constant.selectedLocation = addressModel;
                                                                                controller.getData();
                                                                                Get.back();
                                                                              },
                                                                              initialPosition: const LatLng(-33.8567844, 151.213108),
                                                                              useCurrentLocation: true,
                                                                              selectInitialPosition: true,
                                                                              usePinPointingSearch: true,
                                                                              usePlaceDetailSearch: true,
                                                                              zoomGesturesEnabled: true,
                                                                              zoomControlsEnabled: true,
                                                                              resizeToAvoidBottomInset: false, // only works in page mode, less flickery, remove if wrong offsets
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                    } catch (e) {
                                                                      await placemarkFromCoordinates(
                                                                              19.228825,
                                                                              72.854118)
                                                                          .then(
                                                                              (valuePlaceMaker) {
                                                                        Placemark
                                                                            placeMark =
                                                                            valuePlaceMaker[0];
                                                                        addressModel.location = UserLocation(
                                                                            latitude:
                                                                                19.228825,
                                                                            longitude:
                                                                                72.854118);
                                                                        String
                                                                            currentLocation =
                                                                            "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.postalCode}, ${placeMark.country}";
                                                                        addressModel.locality =
                                                                            currentLocation;
                                                                      });

                                                                      Constant.selectedLocation =
                                                                          addressModel;
                                                                      ShowToastDialog
                                                                          .closeLoader();
                                                                      controller
                                                                          .getData();
                                                                    }
                                                                  },
                                                                  context:
                                                                      context);
                                                        }
                                                      },
                                                   
                                                      child: Text.rich(
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: (Constant.selectedLocation.address != null && Constant.selectedLocation.address!.isNotEmpty) ||
                                                                      (Constant.selectedLocation.locality != null && Constant.selectedLocation.locality!.isNotEmpty)
                                                                  ? Constant.selectedLocation.getFullAddress()
                                                                  : "Select location".tr,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppThemeData
                                                                        .medium,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                color: themeChange
                                                                        .getThem()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey900,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            WidgetSpan(
                                                              child: SvgPicture
                                                                  .asset(
                                                                      "assets/icons/ic_down.svg"),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Obx(
                                                () => badges.Badge(
                                                  showBadge: cartItem.isEmpty
                                                      ? false
                                                      : true,
                                                  badgeContent: Text(
                                                    "${cartItem.length}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontFamily:
                                                          AppThemeData.semiBold,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey50
                                                          : AppThemeData.grey50,
                                                    ),
                                                  ),
                                                  badgeStyle:
                                                      const badges.BadgeStyle(
                                                    shape: badges
                                                        .BadgeShape.circle,
                                                    badgeColor: AppThemeData
                                                        .secondary300,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      (await Get.to(
                                                          const CartScreen()));
                                                      controller.getCartData();
                                                    },
                                                    child: ClipOval(
                                                      child: Container(
                                                        width: 42,
                                                        height: 42,
                                                        decoration:
                                                            ShapeDecoration(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                width: 1,
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey700
                                                                    : AppThemeData
                                                                        .grey200),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        120),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child:
                                                              SvgPicture.asset(
                                                            "assets/icons/ic_shoping_cart.svg",
                                                            colorFilter: ColorFilter.mode(
                                                                themeChange
                                                                        .getThem()
                                                                    ? AppThemeData
                                                                        .grey50
                                                                    : AppThemeData
                                                                        .grey900,
                                                                BlendMode
                                                                    .srcIn),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.to(const SearchScreen(),
                                                  arguments: {
                                                    "vendorList": controller
                                                        .allNearestRestaurant
                                                  });
                                            },
                                            child: TextFieldWidget(
                                              hintText:
                                                  'Search the dish, restaurant, food, meals'
                                                      .tr,
                                              controller: null,
                                              enable: false,
                                              prefix: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: SvgPicture.asset(
                                                    "assets/icons/ic_search.svg"),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            controller.storyList.isEmpty ||
                                                    Constant.storyEnable ==
                                                        false
                                                ? const SizedBox()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: StoryView(
                                                        controller: controller),
                                                  ),
                                            SizedBox(
                                              height:
                                                  controller.storyList.isEmpty
                                                      ? 0
                                                      : 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  titleView(themeChange,
                                                      "Explore the Categories",
                                                      () {
                                                    Get.to(
                                                        const ViewAllCategoryScreen());
                                                  }),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  CategoryView(
                                                      controller: controller),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 32,
                                            ),
                                            controller.bannerModel.isEmpty
                                                ? const SizedBox()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: BannerView(
                                                        controller: controller),
                                                  ),
                                            controller.couponRestaurantList
                                                    .isEmpty
                                                ? const SizedBox()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        titleView(
                                                            themeChange,
                                                            "Largest Discounts"
                                                                .tr, () {
                                                          Get.to(
                                                              const DiscountRestaurantListScreen(),
                                                              arguments: {
                                                                "vendorList":
                                                                    controller
                                                                        .couponRestaurantList,
                                                                "couponList":
                                                                    controller
                                                                        .couponList,
                                                                "title":
                                                                    "Discounts Restaurants"
                                                              });
                                                        }),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        OfferView(
                                                            controller:
                                                                controller),
                                                      ],
                                                    ),
                                                  ),
                                            const SizedBox(
                                              height: 28,
                                            ),
                                            controller.newArrivalRestaurantList
                                                    .isEmpty
                                                ? const SizedBox()
                                                : Container(
                                                    decoration: const BoxDecoration(
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                "assets/images/ic_new_arrival_bg.png"),
                                                            fit: BoxFit.cover)),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 16),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  "New Arrivals"
                                                                      .tr,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .semiBold,
                                                                    fontSize:
                                                                        16,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey50
                                                                        : AppThemeData
                                                                            .grey50,
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Get.to(
                                                                      const RestaurantListScreen(),
                                                                      arguments: {
                                                                        "vendorList":
                                                                            controller.newArrivalRestaurantList,
                                                                        "title":
                                                                            "New Arrival"
                                                                      })?.then(
                                                                      (v) {
                                                                    controller
                                                                        .getFavouriteRestaurant();
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "View all".tr,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .regular,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .primary300
                                                                        : AppThemeData
                                                                            .primary300,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          NewArrival(
                                                              controller:
                                                                  controller),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            controller.bannerBottomModel.isEmpty
                                                ? const SizedBox()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    child: BannerBottomView(
                                                        controller: controller),
                                                  ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Container(
                                                decoration: ShapeDecoration(
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey700
                                                      : AppThemeData.grey200,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            120),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            controller.isPopular
                                                                .value = true;
                                                          },
                                                          child: Container(
                                                            decoration: controller
                                                                        .isPopular
                                                                        .value ==
                                                                    false
                                                                ? null
                                                                : ShapeDecoration(
                                                                    color: AppThemeData
                                                                        .grey900,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              120),
                                                                    ),
                                                                  ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          10),
                                                              child: Text(
                                                                "Popular Restaurants"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .semiBold,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .primary300
                                                                      : AppThemeData
                                                                          .primary300,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            controller.isPopular
                                                                .value = false;
                                                          },
                                                          child: Container(
                                                            decoration: controller
                                                                        .isPopular
                                                                        .value ==
                                                                    true
                                                                ? null
                                                                : ShapeDecoration(
                                                                    color: AppThemeData
                                                                        .grey900,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              120),
                                                                    ),
                                                                  ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          10),
                                                              child: Text(
                                                                "All Restaurants"
                                                                    .tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .semiBold,
                                                                  color: controller
                                                                              .isPopular
                                                                              .value ==
                                                                          true
                                                                      ? themeChange
                                                                              .getThem()
                                                                          ? AppThemeData
                                                                              .grey400
                                                                          : AppThemeData
                                                                              .grey500
                                                                      : themeChange
                                                                              .getThem()
                                                                          ? AppThemeData
                                                                              .primary300
                                                                          : AppThemeData
                                                                              .primary300,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 20),
                                              child: controller.isPopular.value
                                                  ? PopularRestaurant(
                                                      controller: controller)
                                                  : AllRestaurant(
                                                      controller: controller),
                                            )
                                            // controller.isPopular.value
                                            //     ? PopularRestaurant(
                                            //   controller: controller,
                                            // )
                                            //     : PopularRestaurant(
                                            //   controller: controller,
                                            // ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                        ),
                      ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            decoration: BoxDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey800
                    : AppThemeData.grey100,
                borderRadius: const BorderRadius.all(Radius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeChange.getThem()
                          ? AppThemeData.grey900
                          : AppThemeData.grey50,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              controller.isListView.value = true;
                            },
                            child: ClipOval(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: controller.isListView.value
                                          ? AppThemeData.primary300
                                          : null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_view_grid_list.svg",
                                      colorFilter: ColorFilter.mode(
                                          controller.isListView.value
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey500,
                                          BlendMode.srcIn),
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              controller.isListView.value = false;
                              controller.update();
                            },
                            child: ClipOval(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color:
                                          controller.isListView.value == false
                                              ? AppThemeData.primary300
                                              : null),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_map_draw.svg",
                                      colorFilter: ColorFilter.mode(
                                          controller.isListView.value == false
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey500,
                                          BlendMode.srcIn),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(const ScanQrCodeScreen());
                    },
                    child: ClipOval(
                      child: Container(
                          decoration: BoxDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              "assets/icons/ic_scan_code.svg",
                              colorFilter: ColorFilter.mode(
                                  themeChange.getThem()
                                      ? AppThemeData.grey400
                                      : AppThemeData.grey500,
                                  BlendMode.srcIn),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 14,
                  ),
                  DropdownButton<String>(
                    isDense: false,
                    underline: const SizedBox(),
                    value: controller.selectedOrderTypeValue.value.tr,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: <String>['Delivery'.tr, 'TakeAway'.tr]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: 16,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      if (cartItem.isEmpty) {
                        await Preferences.setString(
                            Preferences.foodDeliveryType, value!);
                        controller.selectedOrderTypeValue.value = value;
                        controller.getData();
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogBox(
                                title: "Alert".tr,
                                descriptions:
                                    "Do you really want to change the delivery option? Your cart will be empty."
                                        .tr,
                                positiveString: "Ok".tr,
                                negativeString: "Cancel".tr,
                                positiveClick: () async {
                                  await Preferences.setString(
                                      Preferences.foodDeliveryType, value!);
                                  controller.selectedOrderTypeValue.value =
                                      value;
                                  controller.getData();
                                  DatabaseHelper.instance
                                      .deleteAllCartProducts();
                                  controller.cartProvider.clearDatabase();
                                  controller.getCartData();
                                  Get.back();
                                },
                                negativeClick: () {
                                  Get.back();
                                },
                                img: null,
                              );
                            });
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  titleView(DarkThemeProvider themeChange, String name, Function()? onPress) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name.tr,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: AppThemeData.bold,
              color: themeChange.getThem()
                  ? AppThemeData.grey50
                  : AppThemeData.grey900,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            onPress!();
          },
          child: Text(
            "View all".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: themeChange.getThem()
                  ? AppThemeData.primary300
                  : AppThemeData.primary300,
            ),
          ),
        )
      ],
    );
  }
}

class PopularRestaurant extends StatelessWidget {
  final HomeController controller;

  const PopularRestaurant({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: controller.popularRestaurantList.length,
      itemBuilder: (BuildContext context, int index) {
        VendorModel vendorModel = controller.popularRestaurantList[index];
        return InkWell(
          onTap: () {
            Get.to(const RestaurantDetailsScreen(),
                arguments: {"vendorModel": vendorModel})?.then((v) {
              controller.getFavouriteRestaurant();
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
                bottom: controller.popularRestaurantList.length - 1 == index
                    ? 60
                    : 20),
            child: Container(
              decoration: ShapeDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        child: Stack(
                          children: [
                            RestaurantImageView(
                              vendorModel: vendorModel,
                            ),
                            Container(
                              height: Responsive.height(20, context),
                              width: Responsive.width(100, context),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-0.00, -1.00),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    const Color(0xFF111827)
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () async {
                                  if (controller.favouriteList
                                      .where((p0) =>
                                          p0.restaurantId == vendorModel.id)
                                      .isNotEmpty) {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.removeWhere(
                                        (item) =>
                                            item.restaurantId ==
                                            vendorModel.id);
                                    await FireStoreUtils
                                        .removeFavouriteRestaurant(
                                            favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList
                                        .add(favouriteModel);
                                    await FireStoreUtils.setFavouriteRestaurant(
                                        favouriteModel);
                                  }
                                },
                                child: Obx(
                                  () => controller.favouriteList
                                          .where((p0) =>
                                              p0.restaurantId == vendorModel.id)
                                          .isNotEmpty
                                      ? SvgPicture.asset(
                                          "assets/icons/ic_like_fill.svg",
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/ic_like.svg",
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(Responsive.width(-3, context),
                            Responsive.height(17.5, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.primary600
                                    : AppThemeData.primary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_star.svg",
                                      colorFilter: ColorFilter.mode(
                                          AppThemeData.primary300,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount!.toStringAsFixed(0), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemeData.primary300
                                            : AppThemeData.primary300,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.secondary600
                                    : AppThemeData.secondary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_map_distance.svg",
                                      colorFilter: const ColorFilter.mode(
                                          AppThemeData.secondary300,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "${Constant.getDistance(
                                        lat1: vendorModel.latitude.toString(),
                                        lng1: vendorModel.longitude.toString(),
                                        lat2: Constant
                                            .selectedLocation.location!.latitude
                                            .toString(),
                                        lng2: Constant.selectedLocation
                                            .location!.longitude
                                            .toString(),
                                      )} ${Constant.distanceType}",
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemeData.secondary300
                                            : AppThemeData.secondary300,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorModel.title.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.semiBold,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                        Text(
                          vendorModel.location.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w500,
                            color: themeChange.getThem()
                                ? AppThemeData.grey400
                                : AppThemeData.grey400,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AllRestaurant extends StatelessWidget {
  final HomeController controller;

  const AllRestaurant({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: controller.allNearestRestaurant.length,
      itemBuilder: (BuildContext context, int index) {
        VendorModel vendorModel = controller.allNearestRestaurant[index];
        return InkWell(
          onTap: () {
            Get.to(const RestaurantDetailsScreen(),
                arguments: {"vendorModel": vendorModel})?.then((v) {
              controller.getFavouriteRestaurant();
            });
          },
          child: Padding(
            padding: EdgeInsets.only(
                bottom: controller.allNearestRestaurant.length - 1 == index
                    ? 60
                    : 20),
            child: Container(
              decoration: ShapeDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        child: Stack(
                          children: [
                            RestaurantImageView(
                              vendorModel: vendorModel,
                            ),
                            Container(
                              height: Responsive.height(20, context),
                              width: Responsive.width(100, context),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-0.00, -1.00),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    const Color(0xFF111827)
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () async {
                                  if (controller.favouriteList
                                      .where((p0) =>
                                          p0.restaurantId == vendorModel.id)
                                      .isNotEmpty) {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.removeWhere(
                                        (item) =>
                                            item.restaurantId ==
                                            vendorModel.id);
                                    await FireStoreUtils
                                        .removeFavouriteRestaurant(
                                            favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList
                                        .add(favouriteModel);
                                    await FireStoreUtils.setFavouriteRestaurant(
                                        favouriteModel);
                                  }
                                },
                                child: Obx(
                                  () => controller.favouriteList
                                          .where((p0) =>
                                              p0.restaurantId == vendorModel.id)
                                          .isNotEmpty
                                      ? SvgPicture.asset(
                                          "assets/icons/ic_like_fill.svg",
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/ic_like.svg",
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(Responsive.width(-3, context),
                            Responsive.height(17.5, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.primary600
                                    : AppThemeData.primary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_star.svg",
                                      colorFilter: ColorFilter.mode(
                                          AppThemeData.primary300,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemeData.primary300
                                            : AppThemeData.primary300,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.secondary600
                                    : AppThemeData.secondary50,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_map_distance.svg",
                                      colorFilter: const ColorFilter.mode(
                                          AppThemeData.secondary300,
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "${Constant.getDistance(
                                        lat1: vendorModel.latitude.toString(),
                                        lng1: vendorModel.longitude.toString(),
                                        lat2: Constant
                                            .selectedLocation.location!.latitude
                                            .toString(),
                                        lng2: Constant.selectedLocation
                                            .location!.longitude
                                            .toString(),
                                      )} ${Constant.distanceType}",
                                      style: TextStyle(
                                        color: themeChange.getThem()
                                            ? AppThemeData.secondary300
                                            : AppThemeData.secondary300,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendorModel.title.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.semiBold,
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                          ),
                        ),
                        Text(
                          vendorModel.location.toString(),
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w500,
                            color: themeChange.getThem()
                                ? AppThemeData.grey400
                                : AppThemeData.grey400,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NewArrival extends StatelessWidget {
  final HomeController controller;

  const NewArrival({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: Responsive.height(24, context),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: controller.newArrivalRestaurantList.length >= 10
            ? 10
            : controller.newArrivalRestaurantList.length,
        itemBuilder: (BuildContext context, int index) {
          VendorModel vendorModel = controller.newArrivalRestaurantList[index];
          return InkWell(
            onTap: () {
              Get.to(const RestaurantDetailsScreen(),
                  arguments: {"vendorModel": vendorModel})?.then((v) {
                controller.getFavouriteRestaurant();
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: Responsive.width(55, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Stack(
                          children: [
                            NetworkImageWidget(
                              imageUrl: vendorModel.photo.toString(),
                              fit: BoxFit.cover,
                              height: Responsive.height(100, context),
                              width: Responsive.width(100, context),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(0.00, 1.00),
                                  end: const Alignment(0, -1),
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    AppThemeData.grey900
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: InkWell(
                                onTap: () async {
                                  if (controller.favouriteList
                                      .where((p0) =>
                                          p0.restaurantId == vendorModel.id)
                                      .isNotEmpty) {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList.removeWhere(
                                        (item) =>
                                            item.restaurantId ==
                                            vendorModel.id);
                                    await FireStoreUtils
                                        .removeFavouriteRestaurant(
                                            favouriteModel);
                                  } else {
                                    FavouriteModel favouriteModel =
                                        FavouriteModel(
                                            restaurantId: vendorModel.id,
                                            userId:
                                                FireStoreUtils.getCurrentUid());
                                    controller.favouriteList
                                        .add(favouriteModel);
                                    await FireStoreUtils.setFavouriteRestaurant(
                                        favouriteModel);
                                  }
                                },
                                child: Obx(
                                  () => controller.favouriteList
                                          .where((p0) =>
                                              p0.restaurantId == vendorModel.id)
                                          .isNotEmpty
                                      ? SvgPicture.asset(
                                          "assets/icons/ic_like_fill.svg",
                                        )
                                      : SvgPicture.asset(
                                          "assets/icons/ic_like.svg",
                                        ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      vendorModel.title.toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: AppThemeData.semiBold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey50,
                      ),
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/ic_star.svg",
                              colorFilter: ColorFilter.mode(
                                  AppThemeData.primary300, BlendMode.srcIn),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w500,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                                "assets/icons/ic_map_distance.svg"),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${Constant.getDistance(
                                lat1: vendorModel.latitude.toString(),
                                lng1: vendorModel.longitude.toString(),
                                lat2: Constant
                                    .selectedLocation.location!.latitude
                                    .toString(),
                                lng2: Constant
                                    .selectedLocation.location!.longitude
                                    .toString(),
                              )} ${Constant.distanceType}",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: AppThemeData.medium,
                                fontWeight: FontWeight.w500,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey400
                                    : AppThemeData.grey400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      vendorModel.location.toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontFamily: AppThemeData.medium,
                        fontWeight: FontWeight.w500,
                        color: themeChange.getThem()
                            ? AppThemeData.grey400
                            : AppThemeData.grey400,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OfferView extends StatelessWidget {
  final HomeController controller;

  const OfferView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: Responsive.height(17, context),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: controller.couponRestaurantList.length >= 15
            ? 15
            : controller.couponRestaurantList.length,
        itemBuilder: (BuildContext context, int index) {
          VendorModel vendorModel = controller.couponRestaurantList[index];
          CouponModel offerModel = controller.couponList[index];
          return InkWell(
            onTap: () {
              Get.to(const RestaurantDetailsScreen(),
                  arguments: {"vendorModel": vendorModel});
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: Responsive.width(38, context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Stack(
                          children: [
                            NetworkImageWidget(
                              imageUrl: vendorModel.photo.toString(),
                              fit: BoxFit.cover,
                              height: Responsive.height(100, context),
                              width: Responsive.width(100, context),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: const Alignment(-0.00, -1.00),
                                  end: const Alignment(0, 1),
                                  colors: [
                                    Colors.black.withOpacity(0),
                                    AppThemeData.grey900
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Upto",
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: AppThemeData.regular,
                                      fontWeight: FontWeight.w900,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey50,
                                    ),
                                  ),
                                  Text(
                                    "${offerModel.discountType == "Fix Price" ? "${Constant.currencyModel!.symbol}" : ""}${offerModel.discount}${offerModel.discountType == "Percentage" ? "% off".tr : "off".tr}",
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: AppThemeData.semiBold,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey50,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      vendorModel.title.toString(),
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontFamily: AppThemeData.semiBold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/ic_star.svg",
                          colorFilter: ColorFilter.mode(
                              AppThemeData.primary300, BlendMode.srcIn),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum.toString())} (${vendorModel.reviewsCount!.toStringAsFixed(0)})",
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            fontFamily: AppThemeData.medium,
                            fontWeight: FontWeight.w500,
                            color: themeChange.getThem()
                                ? AppThemeData.grey300
                                : AppThemeData.grey600,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BannerView extends StatelessWidget {
  final HomeController controller;

  const BannerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: controller.pageController.value,
            scrollDirection: Axis.horizontal,
            itemCount: controller.bannerModel.length,
            padEnds: false,
            pageSnapping: true,
            allowImplicitScrolling: true,
            onPageChanged: (value) {
              controller.currentPage.value = value;
            },
            itemBuilder: (BuildContext context, int index) {
              BannerModel bannerModel = controller.bannerModel[index];
              return InkWell(
                onTap: () async {
                  if (bannerModel.redirect_type == "store") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            bannerModel.redirect_id.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first.");
                    }
                  } else if (bannerModel.redirect_type == "product") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    ProductModel? productModel =
                        await FireStoreUtils.getProductById(
                            bannerModel.redirect_id.toString());
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            productModel!.vendorID.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first.");
                    }
                  } else if (bannerModel.redirect_type == "external_link") {
                    final uri = Uri.parse(bannerModel.redirect_id.toString());
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ShowToastDialog.showToast("Could not launch");
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: NetworkImageWidget(
                      imageUrl: bannerModel.photo.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              controller.bannerModel.length,
              (index) {
                return Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 5),
                    alignment: Alignment.centerLeft,
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.currentPage.value == index
                          ? AppThemeData.primary300
                          : Colors.black12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class BannerBottomView extends StatelessWidget {
  final HomeController controller;

  const BannerBottomView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: controller.pageBottomController.value,
            scrollDirection: Axis.horizontal,
            itemCount: controller.bannerBottomModel.length,
            padEnds: false,
            pageSnapping: true,
            allowImplicitScrolling: true,
            onPageChanged: (value) {
              controller.currentBottomPage.value = value;
            },
            itemBuilder: (BuildContext context, int index) {
              BannerModel bannerModel = controller.bannerBottomModel[index];
              return InkWell(
                onTap: () async {
                  if (bannerModel.redirect_type == "store") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            bannerModel.redirect_id.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first.");
                    }
                  } else if (bannerModel.redirect_type == "product") {
                    ShowToastDialog.showLoader("Please wait".tr);
                    ProductModel? productModel =
                        await FireStoreUtils.getProductById(
                            bannerModel.redirect_id.toString());
                    VendorModel? vendorModel =
                        await FireStoreUtils.getVendorById(
                            productModel!.vendorID.toString());

                    if (vendorModel!.zoneId == Constant.selectedZone!.id) {
                      ShowToastDialog.closeLoader();
                      Get.to(const RestaurantDetailsScreen(),
                          arguments: {"vendorModel": vendorModel});
                    } else {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Sorry, The Zone is not available in your area. change the other location first.");
                    }
                  } else if (bannerModel.redirect_type == "external_link") {
                    final uri = Uri.parse(bannerModel.redirect_id.toString());
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ShowToastDialog.showToast("Could not launch");
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: NetworkImageWidget(
                      imageUrl: bannerModel.photo.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              controller.bannerBottomModel.length,
              (index) {
                return Obx(
                  () => Container(
                    margin: const EdgeInsets.only(right: 5),
                    alignment: Alignment.centerLeft,
                    height: 9,
                    width: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.currentBottomPage.value == index
                          ? AppThemeData.primary300
                          : Colors.black12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryView extends StatelessWidget {
  final HomeController controller;

  const CategoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: 124,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: controller.vendorCategoryModel.length,
        itemBuilder: (context, index) {
          VendorCategoryModel vendorCategoryModel =
              controller.vendorCategoryModel[index];
          return InkWell(
            onTap: () {
              Get.to(const CategoryRestaurantScreen(), arguments: {
                "vendorCategoryModel": vendorCategoryModel,
                "dineIn": false
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              child: SizedBox(
                width: 78,
                child: Container(
                  decoration: ShapeDecoration(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey50,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: themeChange.getThem()
                            ? AppThemeData.grey800
                            : AppThemeData.grey100,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: ClipOval(
                          child: NetworkImageWidget(
                            imageUrl: vendorCategoryModel.photo.toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Text(
                          '${vendorCategoryModel.title}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey900,
                            fontFamily: AppThemeData.medium,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class StoryView extends StatelessWidget {
  final HomeController controller;

  const StoryView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: controller.storyList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          StoryModel storyModel = controller.storyList[index];
          
          // التحقق من أن الـ Story لم يمض عليه أكثر من 24 ساعة
          if (storyModel.createdAt != null) {
            DateTime now = DateTime.now();
            DateTime twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
            DateTime storyDate = storyModel.createdAt!.toDate();
            
            if (storyDate.isBefore(twentyFourHoursAgo)) {
              return const SizedBox(); // إخفاء الـ Story المنتهي الصلاحية
            }
          }
          
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MoreStories(
                          storyList: controller.storyList,
                          index: index,
                        )));
              },
              child: SizedBox(
                width: 134,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Stack(
                    children: [
                      NetworkImageWidget(
                        imageUrl: storyModel.videoThumbnail.toString(),
                        fit: BoxFit.cover,
                        height: Responsive.height(100, context),
                        width: Responsive.width(100, context),
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.30),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 8),
                        child: FutureBuilder(
                            future: FireStoreUtils.getVendorById(
                                storyModel.vendorID.toString()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Constant.loader();
                              } else {
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (snapshot.data == null) {
                                  return const SizedBox();
                                } else {
                                  VendorModel vendorModel = snapshot.data!;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipOval(
                                        child: NetworkImageWidget(
                                          imageUrl:
                                              vendorModel.photo.toString(),
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vendorModel.title.toString(),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/icons/ic_star.svg"),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "${Constant.calculateReview(reviewCount: vendorModel.reviewsCount.toString(), reviewSum: vendorModel.reviewsSum!.toStringAsFixed(0))} reviews",
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color:
                                                        AppThemeData.warning300,
                                                    fontSize: 10,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MapView extends StatelessWidget {
  const MapView({super.key});

  Future<BitmapDescriptor> getCustomMarkerFromAsset(String path,
      {int size = 100}) async {
    final ByteData byteData = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: size,
      targetHeight: size,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final Paint paint = Paint();
    final Rect rect = Rect.fromLTWH(0.0, 0.0, size.toDouble(), size.toDouble());

    canvas.clipPath(Path()..addOval(rect));
    canvas.drawImageRect(
      originalImage,
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(),
          originalImage.height.toDouble()),
      rect,
      paint,
    );

    final ui.Image circleImage =
        await recorder.endRecording().toImage(size, size);
    final ByteData? pngBytes =
        await circleImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List data = pngBytes!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(data);
  }

  @override
  Widget build(BuildContext context) {
    return GetX<MapViewController>(
      init: MapViewController(),
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.terrain,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                markers: Set<Marker>.of(controller.markers.values),
                onMapCreated: (GoogleMapController mapController) async {
                  controller.mapController = mapController;

                  await controller.getCurrentLocation();

                  if (controller.currentLocation.value != null) {
                    controller.mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: controller.currentLocation.value!,
                          zoom: 16,
                        ),
                      ),
                    );
                    controller.updateMarkersWithinRadius(); // 👈 only call this
                  }
                },
                mapToolbarEnabled: true,
                minMaxZoomPreference: const MinMaxZoomPreference(3.0, 20.0),
                zoomGesturesEnabled: true,

                // Draw circle
                circles: controller.currentLocation.value != null
                    ? {
                        Circle(
                          circleId: const CircleId("current_location"),
                          center: controller.currentLocation.value!,
                          radius: controller.circleRadius.value,
                          strokeWidth: 2,
                          fillColor: const Color(0xFF006491).withOpacity(0.2),
                        ),
                      }
                    : {},
                initialCameraPosition: CameraPosition(
                  // zoom: 5,
                  target: controller.currentLocation.value ??
                      const LatLng(30.0444, 31.2357), // Default: Cairo
                ),
              ),
              Positioned(
                bottom: 150,
                right: 20,
                child: FloatingActionButton.extended(
                  backgroundColor: AppThemeData.primary400,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final TextEditingController locationController =
                            TextEditingController();
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          title: const Text("Search Location"),
                          content: TextField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              hintText: "Enter location (e.g. Cairo)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final place = locationController.text.trim();
                                if (place.isNotEmpty) {
                                  try {
                                    List<Location> locations =
                                        await locationFromAddress(place);
                                    if (locations.isNotEmpty) {
                                      final loc = locations.first;
                                      ShippingAddress addressModel =
                                          ShippingAddress();
                                      addressModel.addressAs = "Home";
                                      addressModel.location = UserLocation(
                                          latitude: loc.latitude,
                                          longitude: loc.longitude);

                                      List<Placemark> placemarks =
                                          await placemarkFromCoordinates(
                                              loc.latitude, loc.longitude);
                                      if (placemarks.isNotEmpty) {
                                        Placemark pm = placemarks[0];
                                        addressModel.locality =
                                            "${pm.name}, ${pm.subLocality}, ${pm.locality}, ${pm.administrativeArea}, ${pm.postalCode}, ${pm.country}";
                                      }
                                      // Update the circle position

                                      Constant.selectedLocation = addressModel;

                                      Get.find<MapViewController>()
                                          .updateCircleLocation(
                                              loc.latitude, loc.longitude);
                                      Get.find<HomeController>().getData();

                                      // Refresh content
                                      Navigator.of(context).pop();
                                    } else {
                                      Get.snackbar("Not Found",
                                          "No location found for '$place'",
                                          backgroundColor: Colors.orange,
                                          colorText: Colors.white);
                                    }
                                  } catch (e) {
                                    Get.snackbar("Error",
                                        "Failed to search location: $e",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white);
                                  }
                                }
                              },
                              child: const Text("Search"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  label: const Text("Search Location"),
                  icon: const Icon(Icons.search),
                ),
              ),

              // Radius Slider
              Positioned(
                bottom: 60,
                left: 20,
                right: 20,
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Slider(
                          value: controller.circleRadius.value,
                          min: 500,
                          max: 10000,
                          divisions: 20,
                          activeColor: AppThemeData.primary400,
                          label: "${controller.circleRadius.value.round()} m",
                          onChanged: controller.updateCircleRadius,
                        ),
                        Center(
                          child: Text(
                            "Radius: ${controller.circleRadius.value.round()} meters",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    )),
              )

              // Move circle button
            ],
          ),
        );
      },
    );
  }
}
// Assume MapViewController and RestaurantDetailsScreen are defined elsewhere
