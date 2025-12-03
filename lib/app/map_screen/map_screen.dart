import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    final LatLng restaurantLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('موقع المطعم'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: restaurantLocation,
          zoom: 14.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('restaurant'),
            position: restaurantLocation,
            infoWindow: const InfoWindow(title: 'المطعم'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;

          // تحريك الكاميرا بعد تحميل الخريطة
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: restaurantLocation,
                zoom: 16.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
