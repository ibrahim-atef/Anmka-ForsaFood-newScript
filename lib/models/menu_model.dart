import 'package:cloud_firestore/cloud_firestore.dart';

class MenuModel {
  String? menuId;
  String? name;
  String? id;
  String? photo;
  String? price;
  String? description;

  MenuModel({
    this.menuId,
    this.name,
    this.id,
    this.photo,
    this.price,
    this.description,
  });

  MenuModel.fromJson(Map<String, dynamic> json) {
    menuId = json['menu_id'];

    name = json['product_name'];
    id = json['id'];

    photo = json['product_photo'];
    price = json['product_price'];
    description = json['product_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['menu_id'] = menuId;

    data['product_name'] = name;

    data['id'] = id;

    data['product_photo'] = photo;
    data['product_price'] = price;

    data['product_description'] = description;

    return data;
  }
}

class ItemAttribute {
  List<Attributes>? attributes;
  List<Variants>? variants;

  ItemAttribute({this.attributes, this.variants});

  ItemAttribute.fromJson(Map<String, dynamic> json) {
    if (json['attributes'] != null) {
      attributes = <Attributes>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attributes.fromJson(v));
      });
    }
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(Variants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (attributes != null) {
      data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    }
    if (variants != null) {
      data['variants'] = variants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attributes {
  String? attributeId;
  List<String>? attributeOptions;

  Attributes({this.attributeId, this.attributeOptions});

  Attributes.fromJson(Map<String, dynamic> json) {
    attributeId = json['attribute_id'];
    attributeOptions = json['attribute_options'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attribute_id'] = attributeId;
    data['attribute_options'] = attributeOptions;
    return data;
  }
}

class Variants {
  String? variantId;
  String? variantImage;
  String? variantPrice;
  String? variantQuantity;
  String? variantSku;

  Variants(
      {this.variantId,
      this.variantImage,
      this.variantPrice,
      this.variantQuantity,
      this.variantSku});

  Variants.fromJson(Map<String, dynamic> json) {
    variantId = json['variant_id'];
    variantImage = json['variant_image'];
    variantPrice = json['variant_price'] ?? '0';
    variantQuantity = json['variant_quantity'] ?? '0';
    variantSku = json['variant_sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['variant_image'] = variantImage;
    data['variant_price'] = variantPrice;
    data['variant_quantity'] = variantQuantity;
    data['variant_sku'] = variantSku;
    return data;
  }
}

class ReviewsAttribute {
  num? reviewsCount;
  num? reviewsSum;

  ReviewsAttribute({
    this.reviewsCount,
    this.reviewsSum,
  });

  ReviewsAttribute.fromJson(Map<String, dynamic> json) {
    reviewsCount = json['reviewsCount'] ?? 0;
    reviewsSum = json['reviewsSum'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reviewsCount'] = reviewsCount;
    data['reviewsSum'] = reviewsSum;
    return data;
  }
}
