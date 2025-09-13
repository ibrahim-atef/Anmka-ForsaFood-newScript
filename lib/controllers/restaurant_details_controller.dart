import 'dart:async';
import 'dart:developer';

import 'package:customer/constant/constant.dart';
import 'package:customer/models/AttributesModel.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RestaurantDetailsController extends GetxController {
  Rx<TextEditingController> searchEditingController = TextEditingController().obs;

  RxBool isLoading = true.obs;
  Rx<PageController> pageController = PageController().obs;
  RxInt currentPage = 0.obs;

  RxBool isVag = false.obs;
  RxBool isNonVag = false.obs;
  RxBool isMenuOpen = false.obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> allProductList = <ProductModel>[].obs;
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;

  RxList<CouponModel> couponList = <CouponModel>[].obs;

  @override
  void onInit() {
    print("🔍 RestaurantDetailsController: onInit() called");
    getArgument();
    super.onInit();
  }

  void animateSlider() {
    print("🔍 RestaurantDetailsController: animateSlider() called");
    print("🔍 RestaurantDetailsController: vendorModel.value.photos = ${vendorModel.value.photos}");
    print("🔍 RestaurantDetailsController: vendorModel.value.photo = ${vendorModel.value.photo}");
    
    if (vendorModel.value.photos != null && vendorModel.value.photos!.isNotEmpty) {
      print("🔍 RestaurantDetailsController: Photos found, starting animation with ${vendorModel.value.photos!.length} photos");
      Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (currentPage < vendorModel.value.photos!.length - 1) {
          currentPage++;
        } else {
          currentPage.value = 0;
        }

        if (pageController.value.hasClients) {
          pageController.value.animateToPage(
            currentPage.value,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    } else {
      print("❌ RestaurantDetailsController: No photos found for restaurant");
    }
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

  final CartProvider cartProvider = CartProvider();

  getArgument() async {
    print("🔍 RestaurantDetailsController: getArgument() called");
    cartProvider.cartStream.listen(
      (event) async {
        cartItem.clear();
        cartItem.addAll(event);
      },
    );
    dynamic argumentData = Get.arguments;
    print("🔍 RestaurantDetailsController: argumentData = $argumentData");
    
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
      print("🔍 RestaurantDetailsController: vendorModel loaded = ${vendorModel.value.toJson()}");
      print("🔍 RestaurantDetailsController: vendorModel photos = ${vendorModel.value.photos}");
      print("🔍 RestaurantDetailsController: vendorModel photo = ${vendorModel.value.photo}");
    } else {
      print("❌ RestaurantDetailsController: argumentData is null!");
    }
    
    animateSlider();
    statusCheck();

    await getProduct();

    isLoading.value = false;
    await getFavouriteList();

    update();
  }

  getProduct() async {
    print("🔍 RestaurantDetailsController: getProduct() called for vendorId: ${vendorModel.value.id}");
    
    // تجاهل منتجات Firestore وإضافة المنتجات الخاصة فقط
    print("🔍 RestaurantDetailsController: Skipping Firestore products, adding special products only");
    
    // فلترة المنتجات لإظهار المنتجات الخاصة فقط
    _filterToSpecialProductsOnly();

    // إضافة فئة خاصة للمنتجات الخاصة أولاً
    bool hasSpecialCategory = false;
    for (var element in productList) {
      if (element.categoryID == "special_products_category" || 
          element.name == "Mystery Box" || 
          element.name == "Gift Bag" ||
          element.name == "Surprise Bag" ||
          element.name == "Surprise bag") {
        if (!hasSpecialCategory) {
          print("🎁 Adding special category for special products");
          VendorCategoryModel specialCategory = VendorCategoryModel(
            id: "special_products_category",
            title: "Special Offers",
            photo: "https://firebasestorage.googleapis.com/v0/b/foodies-3c1d9.appspot.com/o/special_products%2Fspecial_offers.png?alt=media&token=special_offers_category",
            description: "Special offers and unique items",
          );
          vendorCategoryList.add(specialCategory);
          hasSpecialCategory = true;
        }
        break;
      }
    }
    
    // إضافة باقي الفئات
    for (var element in productList) {
      if (element.categoryID != "special_products_category") {
        await FireStoreUtils.getVendorCategoryById(element.categoryID.toString()).then(
          (value) {
            if (value != null) {
              vendorCategoryList.add(value);
            }
          },
        );
      }
    }
    var seen = <String>{};
    vendorCategoryList.value = vendorCategoryList.where((element) => seen.add(element.id.toString())).toList();
    
    // ترتيب الفئات بحيث تظهر "Special Offers" في البداية
    vendorCategoryList.sort((a, b) {
      if (a.id == "special_products_category") return -1;
      if (b.id == "special_products_category") return 1;
      return a.title!.compareTo(b.title!);
    });
  }

  searchProduct(String name) {
    if (name.isEmpty) {
      productList.clear();
      productList.addAll(allProductList);
    } else {
      isVag.value = false;
      isNonVag.value = false;
      productList.value = allProductList.where((p0) => p0.name!.toLowerCase().contains(name.toLowerCase())).toList();
    }
    update();
  }

  filterRecord() {
    if (isVag.value == true && isNonVag.value == true) {
      productList.value = allProductList.where((p0) => p0.nonveg == true || p0.nonveg == false).toList();
    } else if (isVag.value == true && isNonVag.value == false) {
      productList.value = allProductList.where((p0) => p0.nonveg == false).toList();
    } else if (isVag.value == false && isNonVag.value == true) {
      productList.value = allProductList.where((p0) => p0.nonveg == true).toList();
    } else if (isVag.value == false && isNonVag.value == false) {
      productList.value = allProductList.where((p0) => p0.nonveg == true || p0.nonveg == false).toList();
    }
  }

  Future<List<ProductModel>> getProductByCategory(VendorCategoryModel vendorCategoryModel) async {
    return productList.where((p0) => p0.categoryID == vendorCategoryModel.id).toList();
  }

  getFavouriteList() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );

      await FireStoreUtils.getFavouriteItem().then(
        (value) {
          favouriteItemList.value = value;
        },
      );

      await FireStoreUtils.getOfferByVendorId(vendorModel.value.id.toString()).then(
        (value) {
          couponList.value = value;
        },
      );
    }
    await getAttributeData();
    update();
  }

  RxBool isOpen = false.obs;

  statusCheck() {
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    
    // إذا لم توجد workingHours أو كانت فارغة، افترض أن المطعم مفتوح
    if (vendorModel.value.workingHours == null || vendorModel.value.workingHours!.isEmpty) {
      print("🔍 RestaurantDetailsController: No working hours found, assuming restaurant is open");
      isOpen.value = true;
      return;
    }
    
    for (var element in vendorModel.value.workingHours!) {
      if (day == element.day.toString()) {
        if (element.timeslot != null && element.timeslot!.isNotEmpty) {
          for (var timeSlot in element.timeslot!) {
            try {
              var start = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${timeSlot.from}");
              var end = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${timeSlot.to}");
              if (isCurrentDateInRange(start, end)) {
                isOpen.value = true;
                print("🔍 RestaurantDetailsController: Restaurant is open based on working hours");
                return;
              }
            } catch (e) {
              print("❌ RestaurantDetailsController: Error parsing time: $e");
            }
          }
        }
      }
    }
    
    // إذا لم نجد أي وقت مطابق، افترض أن المطعم مفتوح للتطوير
    if (!isOpen.value) {
      print("🔍 RestaurantDetailsController: No matching working hours found, assuming restaurant is open for development");
      isOpen.value = true;
    }
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    print(startDate);
    print(endDate);
    final currentDate = DateTime.now();
    print(currentDate);
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  RxList<AttributesModel> attributesList = <AttributesModel>[].obs;
  RxList selectedVariants = [].obs;
  RxList selectedIndexVariants = [].obs;
  RxList selectedIndexArray = [].obs;

  RxList selectedAddOns = [].obs;

  RxInt quantity = 1.obs;

  
  /// فلترة المنتجات لإظهار المنتجات الخاصة فقط
  void _filterToSpecialProductsOnly() {
    print("🎁 Filtering to show only special products");
    
    // مسح جميع المنتجات أولاً
    productList.clear();
    allProductList.clear();
    
    // إضافة منتجين فقط: Mystery Box و Surprise Bag
    ProductModel mysteryBox = ProductModel(
      id: "mystery_box_global",
      name: "Mystery Box",
      description: "A surprise box containing random items from our menu. Perfect for trying new flavors!",
      price: "50.00",
      disPrice: "0",
      photo: "https://firebasestorage.googleapis.com/v0/b/foodies-3c1d9.appspot.com/o/special_products%2Fmystery_box.png?alt=media&token=special_mystery_box",
      photos: ["https://firebasestorage.googleapis.com/v0/b/foodies-3c1d9.appspot.com/o/special_products%2Fmystery_box.png?alt=media&token=special_mystery_box"],
      categoryID: "special_products_category",
      vendorID: "", // فارغ لتظهر في جميع المطاعم
      publish: true,
      takeawayOption: false,
      veg: true,
      nonveg: false,
      quantity: 1,
      calories: 0,
      fats: 0,
      proteins: 0,
      grams: 0,
      addOnsPrice: [],
      addOnsTitle: [],
    );
    
    ProductModel surpriseBag = ProductModel(
      id: "surprise_bag_global",
      name: "Surprise Bag",
      description: "A beautifully packaged surprise bag perfect for special occasions and celebrations.",
      price: "75.00",
      disPrice: "0",
      photo: "https://firebasestorage.googleapis.com/v0/b/foodies-3c1d9.appspot.com/o/special_products%2Fgift_bag.png?alt=media&token=special_gift_bag",
      photos: ["https://firebasestorage.googleapis.com/v0/b/foodies-3c1d9.appspot.com/o/special_products%2Fgift_bag.png?alt=media&token=special_gift_bag"],
      categoryID: "special_products_category",
      vendorID: "", // فارغ لتظهر في جميع المطاعم
      publish: true,
      takeawayOption: false,
      veg: true,
      nonveg: false,
      quantity: 1,
      calories: 0,
      fats: 0,
      proteins: 0,
      grams: 0,
      addOnsPrice: [],
      addOnsTitle: [],
    );
    
    // إضافة المنتجين فقط
    productList.add(mysteryBox);
    productList.add(surpriseBag);
    allProductList.add(mysteryBox);
    allProductList.add(surpriseBag);
    
    print("🎁 Filtered to exactly 2 special products: Mystery Box and Surprise Bag");
  }

  calculatePrice(ProductModel productModel) {
    String mainPrice = "0";
    String variantPrice = "0";
    String adOnsPrice = "0";

    if (productModel.itemAttribute != null) {
      if (productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).isNotEmpty) {
        variantPrice = Constant.productCommissionPrice(
            vendorModel.value, productModel.itemAttribute!.variants!.where((element) => element.variantSku == selectedVariants.join('-')).first.variantPrice ?? '0');
      }
    } else {
      String price = Constant.productCommissionPrice(vendorModel.value, productModel.price.toString());
      String disPrice = double.parse(productModel.disPrice.toString()) <= 0 ? "0" : Constant.productCommissionPrice(vendorModel.value, productModel.disPrice.toString());
      if (double.parse(disPrice) <= 0) {
        variantPrice = price;
      } else {
        variantPrice = disPrice;
      }
    }

    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true) {
        adOnsPrice = (double.parse(adOnsPrice.toString()) + double.parse(Constant.productCommissionPrice(vendorModel.value, productModel.addOnsPrice![i].toString()))).toString();
      }
    }
    adOnsPrice = (quantity.value * double.parse(adOnsPrice)).toString();
    mainPrice = ((double.parse(variantPrice.toString()) * double.parse(quantity.value.toString())) + double.parse(adOnsPrice.toString())).toString();
    return mainPrice;
  }

  getAttributeData() async {
    await FireStoreUtils.getAttributes().then((value) {
      if (value != null) {
        attributesList.value = value;
      }
    });
  }

  addToCart({
    required ProductModel productModel,
    required String price,
    required String discountPrice,
    required bool isIncrement,
    required int quantity,
    VariantInfo? variantInfo,
  }) async {
    CartProductModel cartProductModel = CartProductModel();

    String adOnsPrice = "0";
    for (int i = 0; i < productModel.addOnsPrice!.length; i++) {
      if (selectedAddOns.contains(productModel.addOnsTitle![i]) == true && productModel.addOnsPrice![i] != '0') {
        adOnsPrice = (double.parse(adOnsPrice.toString()) + double.parse(Constant.productCommissionPrice(vendorModel.value, productModel.addOnsPrice![i].toString()))).toString();
      }
    }

    if (variantInfo != null) {
      cartProductModel.id = "${productModel.id!}~${variantInfo.variantId.toString()}";
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = variantInfo;
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
    } else {
      cartProductModel.id = productModel.id!;
      cartProductModel.name = productModel.name!;
      cartProductModel.photo = productModel.photo!;
      cartProductModel.categoryId = productModel.categoryID!;
      cartProductModel.price = price;
      cartProductModel.discountPrice = discountPrice;
      cartProductModel.vendorID = vendorModel.value.id;
      cartProductModel.quantity = quantity;
      cartProductModel.variantInfo = VariantInfo();
      cartProductModel.extrasPrice = adOnsPrice;
      cartProductModel.extras = selectedAddOns.isEmpty ? [] : selectedAddOns;
    }

    if (isIncrement) {
      await cartProvider.addToCart(Get.context!, cartProductModel, quantity);
    } else {
      await cartProvider.removeFromCart(cartProductModel, quantity);
    }
    log("===> new ${cartItem.length}");
    update();
  }
}
