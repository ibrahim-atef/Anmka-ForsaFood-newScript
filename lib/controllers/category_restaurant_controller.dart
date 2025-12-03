import 'package:customer/constant/constant.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CategoryRestaurantController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool dineIn = true.obs;

  @override
  void onInit() {
    print("🔍 CategoryRestaurantController: onInit() called");
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {
    // تنظيف الموارد عند إغلاق الكنترولر
    super.onClose();
  }

  Rx<VendorCategoryModel> vendorCategoryModel = VendorCategoryModel().obs;
  RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;

  getArgument() async {
    print("🔍 CategoryRestaurantController: getArgument() called");
    dynamic argumentData = Get.arguments;
    print("🔍 CategoryRestaurantController: argumentData = $argumentData");
    
    if (argumentData != null) {
      vendorCategoryModel.value = argumentData['vendorCategoryModel'];
      dineIn.value = argumentData['dineIn'];
      print("🔍 CategoryRestaurantController: vendorCategoryModel = ${vendorCategoryModel.value.toJson()}");
      print("🔍 CategoryRestaurantController: dineIn = ${dineIn.value}");

      await getZone();
      print("🔍 CategoryRestaurantController: Starting to fetch restaurants for category: ${vendorCategoryModel.value.id}");
      
      FireStoreUtils.getAllNearestRestaurantByCategoryId(categoryId:vendorCategoryModel.value.id.toString(),isDining: dineIn.value).listen((event) async {
        print("🔍 CategoryRestaurantController: Received ${event.length} restaurants");
        allNearestRestaurant.clear();
        allNearestRestaurant.addAll(event);
        print("🔍 CategoryRestaurantController: Updated allNearestRestaurant list with ${allNearestRestaurant.length} items");
      });
    } else {
      print("❌ CategoryRestaurantController: argumentData is null!");
    }

    isLoading.value = false;
    print("🔍 CategoryRestaurantController: isLoading set to false");
  }

  getZone() async {
    print("🔍 CategoryRestaurantController: getZone() called");
    print("🔍 CategoryRestaurantController: Constant.selectedLocation = ${Constant.selectedLocation.toJson()}");
    print("🔍 CategoryRestaurantController: Constant.selectedLocation.location = ${Constant.selectedLocation.location?.toJson()}");
    
    await FireStoreUtils.getZone().then((value) {
      print("🔍 CategoryRestaurantController: getZone() result = ${value?.length} zones");
      
      if (value != null && Constant.selectedLocation.location != null) {
        print("🔍 CategoryRestaurantController: Processing zones for location: ${Constant.selectedLocation.location!.latitude}, ${Constant.selectedLocation.location!.longitude}");
        
        for (int i = 0; i < value.length; i++) {
          print("🔍 CategoryRestaurantController: Checking zone $i: ${value[i].name}");
          if (Constant.isPointInPolygon(LatLng(Constant.selectedLocation.location!.latitude ?? 0.0, Constant.selectedLocation.location!.longitude ?? 0.0), value[i].area!)) {
            Constant.selectedZone = value[i];
            Constant.isZoneAvailable = true;
            print("✅ CategoryRestaurantController: Found matching zone: ${value[i].name}");
            break;
          } else {
            Constant.isZoneAvailable = false;
            print("❌ CategoryRestaurantController: Location not in zone: ${value[i].name}");
          }
        }
      } else {
        Constant.isZoneAvailable = false;
        print("❌ CategoryRestaurantController: No zones or location available");
        if (value == null) print("❌ CategoryRestaurantController: value is null");
        if (Constant.selectedLocation.location == null) print("❌ CategoryRestaurantController: selectedLocation.location is null");
      }
    }).catchError((error) {
      print("❌ CategoryRestaurantController: getZone() error: $error");
      Constant.isZoneAvailable = false;
    });
  }
}
