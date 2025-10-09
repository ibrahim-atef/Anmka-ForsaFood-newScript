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

import '../constant/show_toast_dialog.dart';
import '../models/order_model.dart';

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
    
    // جلب المنتجات الخاصة من Firestore
    print("🔍 RestaurantDetailsController: Fetching special products from Firestore");
    await _fetchSpecialProductsFromFirestore();

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

  
  /// جلب المنتجات الخاصة من Firestore حسب vendorID
  Future<void> _fetchSpecialProductsFromFirestore() async {
    print("🎁 Fetching special products from Firestore for vendor: ${vendorModel.value.id}");
    
    // مسح جميع المنتجات أولاً
    productList.clear();
    allProductList.clear();
    
    try {
      // جلب المنتجات الخاصة من Firestore لهذا المطعم فقط
      List<ProductModel> specialProducts = await FireStoreUtils.getSpecialProductsByVendorId(vendorModel.value.id!);
      
      if (specialProducts.isNotEmpty) {
        print("🎁 Found ${specialProducts.length} special products from Firestore for this vendor");
        
        // فلترة المنتجات الخاصة فقط (التي تحتوي على special_type)
        List<ProductModel> filteredProducts = specialProducts.where((product) {
          bool isSpecial = product.specialType != null && 
                          product.specialType!.isNotEmpty &&
                          (product.specialType == "surprise_bag" || 
                           product.specialType == "mystery_box");
          
          if (isSpecial) {
            print("🎁 Found special product: ${product.name}, Type: ${product.specialType}, VendorID: ${product.vendorID}");
          }
          
          return isSpecial;
        }).toList();
        
        // إضافة المنتجات المفلترة
        productList.addAll(filteredProducts);
        allProductList.addAll(filteredProducts);
        
        print("🎁 Added ${filteredProducts.length} filtered special products for vendor ${vendorModel.value.id}");
        for (var product in filteredProducts) {
          print("🎁 Product: ${product.name}, Type: ${product.specialType}, Price: ${product.price}, ID: ${product.id}");
        }
      } else {
        print("⚠️ No special products found in Firestore for vendor ${vendorModel.value.id}");
      }
    } catch (e) {
      print("❌ Error fetching special products from Firestore: $e");
    }
  }


  /// التحقق من إمكانية شراء المنتج الخاص (منع الطلب مرة أخرى لمدة 48 ساعة)
  Future<bool> _canPurchaseSpecialProduct(ProductModel productModel) async {
    if (Constant.userModel == null) return true;
    
    try {
      // البحث عن آخر طلب للمنتج الخاص من هذا المستخدم
      List<OrderModel> userOrders = await FireStoreUtils.getAllOrder();
      
      // فلترة الطلبات التي تحتوي على هذا المنتج الخاص
      List<OrderModel> specialProductOrders = userOrders.where((order) {
        if (order.products == null) return false;
        
        return order.products!.any((product) => 
          product.id == productModel.id && 
          product.name == productModel.name
        );
      }).toList();
      
      if (specialProductOrders.isEmpty) {
        print("🎁 No previous orders found for special product: ${productModel.name}");
        return true;
      }
      
      // ترتيب الطلبات حسب التاريخ (الأحدث أولاً)
      specialProductOrders.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      
      OrderModel lastOrder = specialProductOrders.first;
      DateTime lastOrderTime = lastOrder.createdAt!.toDate();
      DateTime now = DateTime.now();
      
      // حساب الفرق بالدقائق
      int differenceInMinutes = now.difference(lastOrderTime).inMinutes;
      int hoursLimit = productModel.availabilityDuration ?? 48; // 48 ساعة افتراضياً
      int minutesLimit = hoursLimit * 60;
      
      print("🎁 Last order for ${productModel.name}: ${lastOrderTime}");
      print("🎁 Current time: $now");
      print("🎁 Difference: $differenceInMinutes minutes");
      print("🎁 Limit: $minutesLimit minutes");
      
      if (differenceInMinutes >= minutesLimit) {
        print("🎁 Can purchase special product: ${productModel.name}");
        return true;
      } else {
        int remainingMinutes = minutesLimit - differenceInMinutes;
        int remainingHours = remainingMinutes ~/ 60;
        int remainingMins = remainingMinutes % 60;
        print("🎁 Cannot purchase special product: ${productModel.name}. Remaining time: ${remainingHours}h ${remainingMins}m");
        return false;
      }
    } catch (e) {
      print("❌ Error checking special product purchase limit: $e");
      return true; // في حالة الخطأ، اسمح بالشراء
    }
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
    // التحقق من المنتجات الخاصة ومنع الطلب مرة أخرى لمدة 48 ساعة
    if (productModel.isSpecialProduct == true) {
      bool canPurchase = await _canPurchaseSpecialProduct(productModel);
      if (!canPurchase) {
        ShowToastDialog.showToast("You can only order this special product once every 48 hours");
        return;
      }
    }
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
