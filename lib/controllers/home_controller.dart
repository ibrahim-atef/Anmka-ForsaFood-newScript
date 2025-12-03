import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  DashBoardController dashBoardController = Get.find<DashBoardController>();
  final CartProvider cartProvider = CartProvider();

  getCartData() async {
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);
      },
    );
    update();
  }

  RxBool isLoading = true.obs;
  RxBool isListView = true.obs;
  RxBool isPopular = true.obs;
  RxString selectedOrderTypeValue = "Delivery".tr.obs;

  Rx<PageController> pageController =
      PageController(viewportFraction: 0.877).obs;
  Rx<PageController> pageBottomController =
      PageController(viewportFraction: 0.877).obs;
  RxInt currentPage = 0.obs;
  RxInt currentBottomPage = 0.obs;

  late TabController tabController;

  @override
  void onInit() {
    // TODO: implement onInit
    getVendorCategory();
    getData();
    super.onInit();
  }

  RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;

  RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;
  RxList<VendorModel> newArrivalRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> popularRestaurantList = <VendorModel>[].obs;
  RxList<VendorModel> couponRestaurantList = <VendorModel>[].obs;
  RxList<CouponModel> couponList = <CouponModel>[].obs;

  RxList<StoryModel> storyList = <StoryModel>[].obs;
  RxList<BannerModel> bannerModel = <BannerModel>[].obs;
  RxList<BannerModel> bannerBottomModel = <BannerModel>[].obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

  getData() async {
    print("🏠 ========== HomeController.getData() STARTED ==========");
    isLoading.value = true;
    getCartData();

    // selectedOrderTypeValue.value = Preferences.getString(Preferences.foodDeliveryType, defaultValue: "Delivery".tr).tr;
    print("🏠 HomeController: Getting zones...");
    await getZone();
    print("🏠 HomeController: Zones retrieved. selectedZone = ${Constant.selectedZone?.id}, selectedLocation = ${Constant.selectedLocation.location?.latitude},${Constant.selectedLocation.location?.longitude}");
    
    if (Constant.selectedZone == null) {
      print("❌ HomeController: selectedZone is NULL! Cannot fetch restaurants.");
      isLoading.value = false;
      return;
    }
    
    if (Constant.selectedLocation.location == null) {
      print("❌ HomeController: selectedLocation.location is NULL! Cannot fetch restaurants.");
      isLoading.value = false;
      return;
    }
    
    print("✅ HomeController: selectedZone.id = ${Constant.selectedZone!.id}");
    print("✅ HomeController: selectedLocation = (${Constant.selectedLocation.location!.latitude}, ${Constant.selectedLocation.location!.longitude})");
    print("✅ HomeController: radius = ${Constant.radius}km");
    
    print("🏠 HomeController: Starting to listen to getAllNearestRestaurant stream...");
    FireStoreUtils.getAllNearestRestaurant().listen((event) async {
      print("🏠 HomeController: Received ${event.length} restaurants from stream");
      
      if (event.isEmpty) {
        print("⚠️ HomeController: Stream returned EMPTY list!");
        print("⚠️ HomeController: This could mean:");
        print("   1. No restaurants found in selected zone");
        print("   2. No restaurants within radius");
        print("   3. All restaurants filtered out by subscription checks");
      }
      
      popularRestaurantList.clear();
      newArrivalRestaurantList.clear();
      allNearestRestaurant.clear();

      print("🏠 HomeController: Adding ${event.length} restaurants to lists...");
      allNearestRestaurant.addAll(event);
      newArrivalRestaurantList.addAll(event);
      popularRestaurantList.addAll(event);

      print("🏠 HomeController: allNearestRestaurant.length = ${allNearestRestaurant.length}");
      print("🏠 HomeController: newArrivalRestaurantList.length = ${newArrivalRestaurantList.length}");
      print("🏠 HomeController: popularRestaurantList.length = ${popularRestaurantList.length}");
      
      if (allNearestRestaurant.isEmpty) {
        print("⚠️ HomeController: allNearestRestaurant is EMPTY after adding!");
        print("⚠️ HomeController: No restaurants will be displayed in RestaurantView");
      }

      print("🏠 HomeController: Sorting restaurants...");
      popularRestaurantList.sort(
        (a, b) => Constant.calculateReview(
                reviewCount: b.reviewsCount.toString(),
                reviewSum: b.reviewsSum.toString())
            .compareTo(Constant.calculateReview(
                reviewCount: a.reviewsCount.toString(),
                reviewSum: a.reviewsSum.toString())),
      );

      newArrivalRestaurantList.sort(
        (a, b) => (b.createdAt ?? Timestamp.now())
            .toDate()
            .compareTo((a.createdAt ?? Timestamp.now()).toDate()),
      );

      await FireStoreUtils.getHomeCoupon().then(
        (value) {
          couponRestaurantList.clear();
          couponList.clear();
          for (var element1 in value) {
            for (var element in allNearestRestaurant) {
              if (element1.resturantId == element.id &&
                  element1.expiresAt!.toDate().isAfter(DateTime.now())) {
                couponList.add(element1);
                couponRestaurantList.add(element);
              }
            }
          }
        },
      );

      await FireStoreUtils.getStory().then((value) {
        storyList.clear();
        
        for (var element1 in value) {
          // البحث عن المطعم المقترن بالـ Story
          for (var element in allNearestRestaurant) {
            if (element1.vendorID == element.id) {
              storyList.add(element1);
              break; // إضافة Story واحد فقط لكل مطعم
            }
          }
        }
        
        print("📱 Total active stories (within 24h): ${storyList.length}");
      });
      
      print("🏠 HomeController: All data processing completed");
      print("🏠 HomeController: Final allNearestRestaurant.length = ${allNearestRestaurant.length}");
      print("🏠 HomeController: Final newArrivalRestaurantList.length = ${newArrivalRestaurantList.length}");
      print("🏠 HomeController: Final popularRestaurantList.length = ${popularRestaurantList.length}");
      print("🏠 HomeController: Final couponRestaurantList.length = ${couponRestaurantList.length}");
      
      if (allNearestRestaurant.isNotEmpty) {
        print("✅ HomeController: First 3 restaurants:");
        for (int i = 0; i < allNearestRestaurant.length && i < 3; i++) {
          print("   $i: id=${allNearestRestaurant[i].id}, title=${allNearestRestaurant[i].title}");
        }
      }
      
      isLoading.value = false;
      print("🏠 HomeController: isLoading set to false");
    update();
      print("🏠 HomeController: update() called");
      print("🏠 ========== HomeController.getData() COMPLETED ==========");
    }, onError: (error) {
      print("❌ HomeController: Stream ERROR: $error");
      print("❌ HomeController: Error type: ${error.runtimeType}");
    isLoading.value = false;
      update();
    });
  }

  getVendorCategory() async {
    await FireStoreUtils.getHomeVendorCategory().then(
      (value) {
        vendorCategoryModel.value = value;
      },
    );

    await FireStoreUtils.getHomeTopBanner().then(
      (value) {
        bannerModel.value = value;
      },
    );

    await FireStoreUtils.getHomeBottomBanner().then(
      (value) {
        bannerBottomModel.value = value;
      },
    );

    await getFavouriteRestaurant();
  }

  getFavouriteRestaurant() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }
  }

  getZone() async {
    await FireStoreUtils.getZone().then((value) {
      print(value);
      print("getZone()");
      if (value != null) {
        for (int i = 0; i < value.length; i++) {
          if (Constant.isPointInPolygon(
              LatLng(Constant.selectedLocation.location?.latitude ?? 29.491140,
                  Constant.selectedLocation.location?.longitude ?? 32),
              value[i].area!)) {
            Constant.selectedZone = value[i];
            Constant.isZoneAvailable = true;
            break;
          } else {
            Constant.selectedZone = value[i];
            Constant.isZoneAvailable = false;
          }
        }
      }
    });
  }
}
