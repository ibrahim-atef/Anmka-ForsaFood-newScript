import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:customer/models/user_model.dart';
import 'package:flutter/services.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osmMap;
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    if (currentLocation.value == null) return;

    markers.clear(); // Optional: clear previous markers if needed

    for (var restaurant in homeController.allNearestRestaurant) {
      final double distanceInMeters = Geolocator.distanceBetween(
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
        restaurant.latitude!,
        restaurant.longitude!,
      );
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
        final Rect rect =
            Rect.fromLTWH(0.0, 0.0, size.toDouble(), size.toDouble());

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

      final customIcon =
          await getCustomMarkerFromAsset('assets/images/ic_logo.png');

      if (distanceInMeters <= circleRadius.value) {
        final markerId = MarkerId(restaurant.id.toString());

        final marker = Marker(
          markerId: markerId,
          position: LatLng(restaurant.latitude!, restaurant.longitude!),
          infoWindow: InfoWindow(
            title: restaurant.title,
            snippet: restaurant.location,
            onTap: () {
              Get.to(
                const RestaurantDetailsScreen(),
                arguments: {"vendorModel": restaurant},
              );
            },
          ),
          icon: customIcon, // Use fallback
        );

        markers[markerId] = marker;
      }
    }
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
    if (Constant.selectedMapType == "osm") {
      departureOsmIcon = Image.asset("assets/images/map_selected.png",
          width: 30, height: 30); //OSM
    } else {
      final Uint8List parking = await Constant()
          .getBytesFromAsset("assets/images/map_selected.png", 20);
      parkingMarker = BitmapDescriptor.bytes(parking);
      for (var element in homeController.allNearestRestaurant) {
        addMarker(
            latitude: element.latitude,
            longitude: element.longitude,
            id: element.id.toString(),
            rotation: 0,
            descriptor: parkingMarker!,
            title: element.title.toString());
      }
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
