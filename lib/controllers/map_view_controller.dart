import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:flutter/services.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osmMap;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapViewController extends GetxController {
  GoogleMapController? mapController;
  Rxn<GoogleMapController> mapControllers = Rxn<GoogleMapController>();

  BitmapDescriptor? parkingMarker;
  BitmapDescriptor? currentLocationMarker;

  HomeController homeController = Get.find<HomeController>();

  late osmMap.MapController mapOsmController;
  Map<String, osmMap.GeoPoint> osmMarkers = <String, osmMap.GeoPoint>{};
  Image? departureOsmIcon; //OSM
  Rx<LatLng?> currentLocation = Rx<LatLng?>(null); // 👈 لحفظ الموقع الحالي
  final RxDouble circleRadius = 1000.0.obs; // radius in meters

  @override
  void onInit() {
    // TODO: implement onInit
    getCurrentLocation(); // 👈 استدعاء عند التشغيل

    addMarkerSetup();
    if (Constant.selectedMapType == 'osm') {
      mapOsmController = osmMap.MapController(
          initPosition:
              osmMap.GeoPoint(latitude: 20.9153, longitude: -100.7439),
          useExternalTracking: false); //OSM
    }
    super.onInit();
  }

  Future<void> updateMarkersWithinRadius() async {
    print("🗺️ Updating markers on map");
    markers.clear();

    int totalRestaurants = homeController.allNearestRestaurant.length;
    print("🏪 Total restaurants to display: $totalRestaurants");

    for (var restaurant in homeController.allNearestRestaurant) {
      try {
        // إنشاء المؤشر المخصص للمطعم
        final BitmapDescriptor customIcon = await _createRestaurantMarker(restaurant);

        final markerId = MarkerId(restaurant.id.toString());
        
        // حساب المسافة إذا كان الموقع الحالي متاح
        String distanceText = "";
        if (currentLocation.value != null) {
          final double distanceInMeters = Geolocator.distanceBetween(
            currentLocation.value!.latitude,
            currentLocation.value!.longitude,
            restaurant.latitude!,
            restaurant.longitude!,
          );
          double distanceInKm = distanceInMeters / 1000;
          distanceText = distanceInKm < 1 
              ? "${distanceInMeters.toStringAsFixed(0)}m away"
              : "${distanceInKm.toStringAsFixed(1)}km away";
        }

        // حساب التقييم
        String rating = Constant.calculateReview(
          reviewCount: restaurant.reviewsCount.toString(),
          reviewSum: restaurant.reviewsSum.toString(),
        );

        final marker = Marker(
          markerId: markerId,
          position: LatLng(restaurant.latitude!, restaurant.longitude!),
          infoWindow: InfoWindow(
            title: restaurant.title ?? "Restaurant",
            snippet: "$distanceText • ⭐ $rating • ${restaurant.location ?? ''}",
            onTap: () {
              print("🏪 Opening restaurant: ${restaurant.title}");
              Get.to(
                () => const RestaurantDetailsScreen(),
                arguments: {"vendorModel": restaurant},
              );
            },
          ),
          icon: customIcon,
        );

        markers[markerId] = marker;
        print("✅ Added marker for: ${restaurant.title}");
      } catch (e) {
        print("❌ Error creating marker for ${restaurant.title}: $e");
      }
    }

    print("🗺️ Total markers added: ${markers.length}");
    update();
  }

  /// إنشاء مؤشر مخصص جميل للمطعم
  Future<BitmapDescriptor> _createRestaurantMarker(VendorModel restaurant) async {
    try {
      // محاولة تحميل صورة المطعم من الإنترنت
      if (restaurant.photo != null && restaurant.photo!.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(restaurant.photo!)).timeout(
            const Duration(seconds: 3),
          );
          
          if (response.statusCode == 200) {
            return await _createCircularMarkerWithImage(
              response.bodyBytes,
              size: 120,
              borderColor: Colors.white,
              borderWidth: 4,
            );
          }
        } catch (e) {
          print("⚠️ Could not load restaurant image: ${restaurant.title}, using fallback");
        }
      }

      // استخدام الصورة الافتراضية
      return await _createCircularMarkerFromAsset(
        'assets/images/ic_logo.png',
        size: 120,
        borderColor: Colors.white,
        borderWidth: 4,
      );
    } catch (e) {
      print("❌ Error in _createRestaurantMarker: $e");
      // الرجوع لمؤشر افتراضي بسيط
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  /// إنشاء مؤشر دائري من صورة بايتات
  Future<BitmapDescriptor> _createCircularMarkerWithImage(
    Uint8List imageBytes, {
    int size = 120,
    Color borderColor = Colors.white,
    double borderWidth = 4,
  }) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: size,
      targetHeight: size,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    return await _createCircularMarkerFromImage(
      image,
      size: size,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }

  /// إنشاء مؤشر دائري من صورة أصول
  Future<BitmapDescriptor> _createCircularMarkerFromAsset(
    String assetPath, {
    int size = 120,
    Color borderColor = Colors.white,
    double borderWidth = 4,
  }) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: size,
      targetHeight: size,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    return await _createCircularMarkerFromImage(
      image,
      size: size,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }

  /// إنشاء مؤشر دائري من صورة UI
  Future<BitmapDescriptor> _createCircularMarkerFromImage(
    ui.Image image, {
    int size = 120,
    Color borderColor = Colors.white,
    double borderWidth = 4,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    // رسم الظل
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(
      Offset(size / 2, size / 2 + 2),
      (size / 2) - borderWidth,
      shadowPaint,
    );

    // رسم الحدود البيضاء
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      (size / 2),
      borderPaint,
    );

    // قص الدائرة للصورة
    final clipPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size / 2, size / 2),
        radius: (size / 2) - borderWidth,
      ));
    
    canvas.clipPath(clipPath);

    // رسم الصورة داخل الدائرة
    final srcRect = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dstRect = Rect.fromLTWH(
      borderWidth,
      borderWidth,
      size.toDouble() - (borderWidth * 2),
      size.toDouble() - (borderWidth * 2),
    );
    
    canvas.drawImageRect(image, srcRect, dstRect, paint);

    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(size, size);
    final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  void updateCircleLocation(double lat, double lng) {
    currentLocation.value = LatLng(lat, lng);

    ShippingAddress addressModel = ShippingAddress();
    addressModel.location = UserLocation(latitude: lat, longitude: lng);
    // if (mapControllers.value! != null) {
    //   mapControllers.value!.animateCamera(
    //     CameraUpdate.newLatLng(
    //       LatLng(lat, lng),
    //     ),
    //   );
    // }
    print("lat $lat");
    print("lng $lng");

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }
    updateMarkersWithinRadius();
  }

  void updateCircleRadius(double radius) {
    circleRadius.value = radius;
    updateMarkersWithinRadius();
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation.value = LatLng(position.latitude, position.longitude);
      Constant.selectedLocation.location!.latitude = position.latitude;
      Constant.selectedLocation.location!.longitude = position.longitude;
    }

    print("location :: ${currentLocation.value}");
  }

  addMarkerSetup() async {
    print("🗺️ Setting up markers");
    if (Constant.selectedMapType == "osm") {
      departureOsmIcon = Image.asset("assets/images/map_selected.png",
          width: 30, height: 30); //OSM
    } else {
      print("🏪 Adding ${homeController.allNearestRestaurant.length} restaurants to map");
      await updateMarkersWithinRadius();
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  addMarker(
      {required double? latitude,
      required double? longitude,
      required String id,
      required BitmapDescriptor descriptor,
      required double? rotation,
      required String title}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      infoWindow: InfoWindow(
        title: title,
        onTap: () {
          int index = homeController.allNearestRestaurant
              .indexWhere((p0) => p0.id == id);
          Get.to(const RestaurantDetailsScreen(), arguments: {
            "vendorModel": homeController.allNearestRestaurant[index]
          });
        },
      ),
      position: LatLng(latitude ?? 0.0, longitude ?? 0.0),
      rotation: rotation ?? 0.0,
    );
    markers[markerId] = marker;
  }
}
