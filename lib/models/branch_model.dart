import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  String? id;

  // Basic info
  String? title;
  String? description;
  String? location;
  String? countryCode;
  String? phonenumber;
  String? photo;
  List<dynamic>? photos;
  String? categoryID;
  String? categoryTitle;

  // Coordinates
  double? latitude;
  double? longitude;
  GeoPoint? geopoint;
  String? geohash;
  GeoPoint? coordinates;

  // Status and features
  bool? isEnabled;
  bool? reststatus;
  bool? hidephotos;
  bool? enabledDiveInFuture;
  String? deliveryTimeRange;
  String? openDineTime;
  String? closeDineTime;

  // Author/subscription
  String? author;
  String? authorName;
  String? authorProfilePic;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  String? subscriptionTotalOrders;
  Map<String, dynamic>? subscriptionPlan;

  // Admin commission
  Map<String, dynamic>? adminCommission;
  String? commissionType;
  num? fixCommission;

  // Misc
  String? zoneId;
  Timestamp? createdAt;
  Map<String, dynamic>? features;
  Map<String, dynamic>? filters;
  List<dynamic>? restaurantMenuPhotos;
  List<dynamic>? specialDiscount;
  bool? specialDiscountEnable;
  List<dynamic>? planPoints;
  List<dynamic>? workingHours;

  BranchModel({
    this.id,
    this.title,
    this.description,
    this.location,
    this.countryCode,
    this.phonenumber,
    this.photo,
    this.photos,
    this.categoryID,
    this.categoryTitle,
    this.latitude,
    this.longitude,
    this.geopoint,
    this.geohash,
    this.coordinates,
    this.isEnabled,
    this.reststatus,
    this.hidephotos,
    this.enabledDiveInFuture,
    this.deliveryTimeRange,
    this.openDineTime,
    this.closeDineTime,
    this.author,
    this.authorName,
    this.authorProfilePic,
    this.subscriptionPlanId,
    this.subscriptionExpiryDate,
    this.subscriptionTotalOrders,
    this.subscriptionPlan,
    this.adminCommission,
    this.commissionType,
    this.fixCommission,
    this.zoneId,
    this.createdAt,
    this.features,
    this.filters,
    this.restaurantMenuPhotos,
    this.specialDiscount,
    this.specialDiscountEnable,
    this.planPoints,
    this.workingHours,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return BranchModel(
      id: json['id'] ?? documentId,
      title: json['title'] ?? json['name'],
      description: json['description'],
      location: json['location'],
      countryCode: json['countryCode']?.toString(),
      phonenumber: json['phonenumber'],
      photo: json['photo'],
      photos: json['photos'] ?? [],
      categoryID: json['categoryID'],
      categoryTitle: json['categoryTitle'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      geopoint: json['geopoint'],
      geohash: json['geohash'],
      coordinates: json['coordinates'],
      isEnabled: json['isEnabled'] ?? json['reststatus'] ?? true,
      reststatus: json['reststatus'],
      hidephotos: json['hidephotos'],
      enabledDiveInFuture: json['enabledDiveInFuture'],
      deliveryTimeRange: json['delivery_time_range'],
      openDineTime: json['openDineTime'],
      closeDineTime: json['closeDineTime'],
      author: json['author'],
      authorName: json['authorName'],
      authorProfilePic: json['authorProfilePic'],
      subscriptionPlanId: json['subscriptionPlanId'],
      subscriptionExpiryDate: json['subscriptionExpiryDate'],
      subscriptionTotalOrders: json['subscriptionTotalOrders']?.toString(),
      subscriptionPlan: json['subscription_plan'],
      adminCommission: json['adminCommission'],
      commissionType: json['commissionType'],
      fixCommission: json['fix_commission'],
      zoneId: json['zoneId'],
      createdAt: json['createdAt'],
      features: json['features'],
      filters: json['filters'],
      restaurantMenuPhotos: json['restaurantMenuPhotos'],
      specialDiscount: json['specialDiscount'],
      specialDiscountEnable: json['specialDiscountEnable'],
      planPoints: json['plan_points'],
      workingHours: json['workingHours'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'countryCode': countryCode,
      'phonenumber': phonenumber,
      'photo': photo,
      'photos': photos,
      'categoryID': categoryID,
      'categoryTitle': categoryTitle,
      'latitude': latitude,
      'longitude': longitude,
      'geopoint': geopoint,
      'geohash': geohash,
      'coordinates': coordinates,
      'isEnabled': isEnabled,
      'reststatus': reststatus,
      'hidephotos': hidephotos,
      'enabledDiveInFuture': enabledDiveInFuture,
      'delivery_time_range': deliveryTimeRange,
      'openDineTime': openDineTime,
      'closeDineTime': closeDineTime,
      'author': author,
      'authorName': authorName,
      'authorProfilePic': authorProfilePic,
      'subscriptionPlanId': subscriptionPlanId,
      'subscriptionExpiryDate': subscriptionExpiryDate,
      'subscriptionTotalOrders': subscriptionTotalOrders,
      'subscription_plan': subscriptionPlan,
      'adminCommission': adminCommission,
      'commissionType': commissionType,
      'fix_commission': fixCommission,
      'zoneId': zoneId,
      'createdAt': createdAt,
      'features': features,
      'filters': filters,
      'restaurantMenuPhotos': restaurantMenuPhotos,
      'specialDiscount': specialDiscount,
      'specialDiscountEnable': specialDiscountEnable,
      'plan_points': planPoints,
      'workingHours': workingHours,
    };
  }
}






