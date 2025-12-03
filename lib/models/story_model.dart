import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  String? videoThumbnail;
  List<dynamic> videoUrl = [];
  String? vendorID;
  Timestamp? createdAt;
  String? status;

  StoryModel({this.videoThumbnail, this.videoUrl = const [], this.vendorID, this.createdAt, this.status});

  StoryModel.fromJson(Map<String, dynamic> json) {
    videoThumbnail = json['videoThumbnail'] ?? '';
    videoUrl = json['videoUrl'] ?? [];
    vendorID = json['vendorID'] ?? '';
    createdAt = json['createdAt'] ?? Timestamp.now();
    status = json['status'] ?? 'pending';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['videoThumbnail'] = videoThumbnail;
    data['videoUrl'] = videoUrl;
    data['vendorID'] = vendorID;
    data['createdAt'] = createdAt;
    data['status'] = status;
    return data;
  }
}
