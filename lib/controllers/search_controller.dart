import 'package:customer/constant/constant.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class SearchScreenController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<VendorModel> vendorList = <VendorModel>[].obs;
  RxList<VendorModel> vendorSearchList = <VendorModel>[].obs;

  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxList<ProductModel> productSearchList = <ProductModel>[].obs;

getArgument() async {
  dynamic argumentData = Get.arguments;
  if (argumentData != null) {
    vendorList.value = argumentData['vendorList'];
  }

  List<ProductModel> allProducts = [];

  for (var element in vendorList) {
    final products = await FireStoreUtils.getProductByVendorId(element.id.toString());

    List<ProductModel> limitedProducts = [];

    if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) &&
        element.subscriptionPlan != null) {
      if (element.subscriptionPlan?.itemLimit == '-1') {
        limitedProducts = products;
      } else {
        int limit = int.tryParse(element.subscriptionPlan?.itemLimit ?? '0') ?? 0;
        limitedProducts = products.take(limit).toList();
      }
    } else {
      limitedProducts = products;
    }

    allProducts.addAll(limitedProducts);
  }

  productList.value = allProducts;

  isLoading.value = false;
}

  onSearchTextChanged(String text) {
    if (text.isEmpty) {
      return;
    }
    vendorSearchList.clear();
    productSearchList.clear();
    for (var element in vendorList) {
      if (element.title!.toLowerCase().contains(text.toLowerCase())) {
        vendorSearchList.add(element);
      }
    }

    for (var element in productList) {
      if (element.name!.toLowerCase().contains(text.toLowerCase())) {
        productSearchList.add(element);
      }
    }
  }

  @override
  void dispose() {
    vendorSearchList.clear();
    productSearchList.clear();
    super.dispose();
  }
}
