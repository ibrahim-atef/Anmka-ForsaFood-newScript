import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/widget/osm_search_place_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';


// ==============================  osm_search_place_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osm_nominatim/osm_nominatim.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../themes/app_them_data.dart';
import '../themes/text_field_widget.dart';   // استبدله بنسخة TextField العادية لو وِدجتك لا تدعم onChanged
import '../utils/dark_theme_provider.dart';
import 'osm_search_place_controller.dart';


class OsmSearchPlaceController extends GetxController {
  /// حقل إدخال النص
  final Rx<TextEditingController> searchTxtController =
      TextEditingController().obs;

  /// قائمة النتائج المعروضة
  final RxList<Place> suggestionsList = <Place>[].obs;

  /// عميل Nominatim بــ user‑agent إجباري
  // final Nominatim nominatim = Nominatim(userAgent: "egy-stem-app/1.0");

  Timer? _debounce; // لمنع وابل الطلبات

  Future<List<Place>> _searchByNameWithUA({
    required String query,
    int limit = 10,
    String? language,
  }) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'format': 'jsonv2',
        'q': query,
        'limit': limit.toString(),
        if (language != null) 'accept-language': language,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'ForsaFood/1.0 (support@anmka.com)',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Nominatim HTTP ${response.statusCode}');
    }

    // Check if response is HTML instead of JSON
    if (response.body.trim().startsWith('<')) {
      throw Exception('Nominatim returned HTML instead of JSON (likely rate limited)');
    }

    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data
        .map<Place>((p) => Place.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// Custom reverse search function with User-Agent header to avoid HTML responses
  Future<Place?> reverseSearchWithUA({
    required double lat,
    required double lon,
    int zoom = 14,
    bool addressDetails = true,
    bool extraTags = true,
    bool nameDetails = true,
  }) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
        'zoom': zoom.toString(),
        'addressdetails': addressDetails ? '1' : '0',
        'extratags': extraTags ? '1' : '0',
        'namedetails': nameDetails ? '1' : '0',
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'ForsaFood/1.0 (support@anmka.com)',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Nominatim reverse HTTP ${response.statusCode}');
    }

    // Check if response is HTML instead of JSON
    if (response.body.trim().startsWith('<')) {
      throw Exception('Nominatim returned HTML instead of JSON (likely rate limited)');
    }

    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
    return Place.fromJson(data);
  }

  @override
  void onInit() {
    super.onInit();
    // مراقبة التغييرات فى النص
    searchTxtController.value.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchTxtController.value.text.trim();

    // طول قصير → امسح القائمة
    if (query.length < 3) {
      suggestionsList.clear();
      return;
    }

    // Debounce 600ms
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _fetchSuggestions(query);
    });
  }



Future<void> _fetchSuggestions(String query) async {
  debugPrint("→ Searching for: $query");          // ⬅️ بداية البحث

  try {
    // Use custom request with proper User-Agent to avoid HTML/blocked responses
    final results = await _searchByNameWithUA(
      query: query,
      limit: 10,
      language: 'en',
    );

    debugPrint("← Got ${results.length} results"); // ⬅️ عدد النتائج

    if (results.isNotEmpty) {
      for (final p in results) {
        debugPrint("• ${p.displayName}  (${p.lat}, ${p.lon})");
      }
      suggestionsList.assignAll(results);
    } else {
      suggestionsList.clear();
      debugPrint("No results found for: $query");
    }
  } catch (e, st) {
    debugPrint("Nominatim search error: $e");
    debugPrintStack(stackTrace: st);              // ⬅️ ستاك كامل لو فيه مشكلة
    // Show a message to the user that search is unavailable
    suggestionsList.clear();
  }
}



  @override
  void onClose() {
    _debounce?.cancel();
    searchTxtController.value.dispose();
    super.onClose();
  }
}


// ==============================  osm_search_places_api.dart


class OsmSearchPlacesApi extends StatelessWidget {
  const OsmSearchPlacesApi({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OsmSearchPlaceController>(
      init: OsmSearchPlaceController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppThemeData.primary300,
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: themeChange.getThem()
                      ? AppThemeData.grey50
                      : AppThemeData.grey50),
              onPressed: Get.back,
            ),
            title: Text(
              'Search Places'.tr,
              style: TextStyle(
                  color: themeChange.getThem()
                      ? AppThemeData.grey50
                      : AppThemeData.grey50,
                  fontSize: 16),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // ---- حقل البحث -------------------------------------------------
                TextFieldWidget(
                  controller: controller.searchTxtController.value,
                  hintText: 'Search your location here'.tr,
                  onchange: (_) {},                // تأكد أن وِدجتك تمّرر التغيير
                  suffix: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () =>
                        controller.searchTxtController.value.clear(),
                  ),
                ),
                const SizedBox(height: 12),
                // ---- قائمة الاقتراحات -----------------------------------------
                Expanded(
                  child: Obx(
                    () => ListView.separated(
                      itemCount: controller.suggestionsList.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, thickness: .6),
                      itemBuilder: (_, index) {
                        final place = controller.suggestionsList[index];
                        return ListTile(
                          title: Text(place.displayName ?? 'Unnamed place'),
                          subtitle: Text(
                              '${place.lat}, ${place.lon}', style: const TextStyle(fontSize: 12)),
                          onTap: () {
                            final info = SearchInfo(
                              point: GeoPoint(
                                latitude: place.lat,
                                longitude: place.lon,
                              ),
                              address: Address(name: place.displayName),
                            );
                            Get.back(result: info);
                          },
                        );
                      },
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
}



