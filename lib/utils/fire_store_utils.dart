import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/chat_screens/ChatVideoContainer.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/gift_cards_model.dart';
import 'package:customer/models/AttributesModel.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/conversation_model.dart';
import 'package:customer/models/dine_in_booking_model.dart';
import 'package:customer/models/email_template_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/admin_commission.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/gift_cards_order_model.dart';
import 'package:customer/models/inbox_model.dart';
import 'package:customer/models/mail_setting.dart';
import 'package:customer/models/menu_model.dart';
import 'package:customer/models/notification_model.dart';
import 'package:customer/models/on_boarding_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/payment_model/cod_setting_model.dart';
import 'package:customer/models/payment_model/flutter_wave_model.dart';
import 'package:customer/models/payment_model/mercado_pago_model.dart';
import 'package:customer/models/payment_model/mid_trans.dart';
import 'package:customer/models/payment_model/orange_money.dart';
import 'package:customer/models/payment_model/pay_fast_model.dart';
import 'package:customer/models/payment_model/pay_stack_model.dart';
import 'package:customer/models/payment_model/paypal_model.dart';
import 'package:customer/models/payment_model/paytm_model.dart';
import 'package:customer/models/payment_model/razorpay_model.dart';
import 'package:customer/models/payment_model/stripe_model.dart';
import 'package:customer/models/payment_model/wallet_setting_model.dart';
import 'package:customer/models/payment_model/xendit.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/branch_model.dart';
import 'package:customer/models/rating_model.dart';
import 'package:customer/models/referral_model.dart';
import 'package:customer/models/review_attribute_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/wallet_transaction_model.dart';
import 'package:customer/models/zone_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/widget/geoflutterfire/src/geoflutterfire.dart';
import 'package:customer/widget/geoflutterfire/src/models/point.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:customer/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    }).catchError((error) {
      log("Failed to update user: $error");
      userModel = null;
    });
    return userModel;
  }

  static Future<bool?> updateUserWallet(
      {required String amount, required String userId}) async {
    bool isAdded = false;
    await getUserProfile(userId).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount =
            (double.parse(userModel.walletAmount.toString()) +
                double.parse(amount));
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.users)
        .doc(userModel.id)
        .set(userModel.toJson())
        .whenComplete(() {
      Constant.userModel = userModel;
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore
        .collection(CollectionName.onBoarding)
        .where("type", isEqualTo: "customerApp")
        .get()
        .then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel =
            OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<List<VendorModel>> getVendors() async {
    List<VendorModel> giftCardModelList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await fireStore
        .collection(CollectionName.vendors)
        .where("zoneId", isEqualTo: Constant.selectedZone!.id.toString())
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        log(document.data().toString());
        giftCardModelList.add(VendorModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.get Currency Parse error $e');
      }
    });
    return giftCardModelList;
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.wallet)
        .doc(walletTransactionModel.id)
        .set(walletTransactionModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  getSettings() async {
    try {
      FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc('restaurant')
          .get()
          .then((value) {
        Constant.isSubscriptionModelApplied =
            value.data()!['subscription_model'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("RestaurantNearBy")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.radius = event.data()!["radios"];
          Constant.driverRadios = event.data()!["driverRadios"];
          // Constant.distanceType = event.data()!["distanceType"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("googleMapKey")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.mapAPIKey = event.data()!["key"];
          Constant.placeHolderImage = event.data()!["placeHolderImage"];
        }
      });

      // fireStore.collection(CollectionName.settings).doc("home_page_theme").snapshots().listen((event) {
      //   if (event.exists) {
      //     Constant.theme = event.data()!["theme"];
      //   }
      // });

      fireStore
          .collection(CollectionName.settings)
          .doc("DriverNearBy")
          .get()
          .then((event) {
        if (event.exists) {
          Constant.selectedMapType = event.data()!["selectedMapType"];
          Constant.mapType = event.data()!["mapType"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("privacyPolicy")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.privacyPolicy = event.data()!["privacy_policy"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("termsAndConditions")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.termsAndConditions = event.data()!["termsAndConditions"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("walletSettings")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.walletSetting = event.data()!["isEnabled"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("Version")
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Constant.googlePlayLink = event.data()!["googlePlayLink"] ?? '';
          Constant.appStoreLink = event.data()!["appStoreLink"] ?? '';
          Constant.appVersion = event.data()!["app_version"] ?? '';
          Constant.websiteUrl = event.data()!["websiteUrl"] ?? '';
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('story')
          .get()
          .then((value) {
        Constant.storyEnable = value.data()!['isEnabled'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('referral_amount')
          .get()
          .then((value) {
        Constant.referralAmount = value.data()!['referralAmount'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc('placeHolderImage')
          .get()
          .then((value) {
        Constant.placeholderImage = value.data()!['image'];
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("emailSetting")
          .get()
          .then((value) {
        if (value.exists) {
          Constant.mailSettings = MailSettings.fromJson(value.data()!);
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("specialDiscountOffer")
          .get()
          .then((dineinresult) {
        if (dineinresult.exists) {
          Constant.specialDiscountOffer = dineinresult.data()!["isEnable"];
        }
      });

      fireStore
          .collection(CollectionName.settings)
          .doc("notification_setting")
          .get()
          .then((event) {
        if (event.exists) {
          Constant.senderId = event.data()!["senderId"];
          Constant.jsonNotificationFileURL = event.data()!["serviceJson"];
        }
      });

      // await FirebaseFirestore.instance.collection(CollectionName.settings).doc("globalSettings").get().then((value) {
      //   AppThemeData.primary300 = Color(int.parse(value.data()!['app_customer_color'].replaceFirst("#", "0xff")));
      // });

      await FirebaseFirestore.instance
          .collection(CollectionName.settings)
          .doc("DineinForRestaurant")
          .get()
          .then((value) {
        Constant.isEnabledForCustomer = value['isEnabledForCustomer'] ?? false;
      });

      await fireStore
          .collection(CollectionName.settings)
          .doc("AdminCommission")
          .get()
          .then((value) {
        if (value.data() != null) {
          Constant.adminCommission = AdminCommission.fromJson(value.data()!);
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static Future<ReferralModel?> getReferralUserByCode(
      String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .where("referralCode", isEqualTo: referralCode)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          referralModel = ReferralModel.fromJson(value.docs.first.data());
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await fireStore
          .collection(CollectionName.referral)
          .doc(ratingModel.id)
          .set(ratingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<ZoneModel>?> getZone() async {
    print("🔍 FireStoreUtils: getZone() called");
    List<ZoneModel> airPortList = [];
    await fireStore
        .collection(CollectionName.zone)
        .where('publish', isEqualTo: true)
        .get()
        .then((value) {
      print("🔍 FireStoreUtils: getZone() found ${value.docs.length} zones");
      for (var element in value.docs) {
        ZoneModel ariPortModel = ZoneModel.fromJson(element.data());
        airPortList.add(ariPortModel);
        print("🔍 FireStoreUtils: Added zone: ${ariPortModel.name} (ID: ${ariPortModel.id})");
      }
    }).catchError((error) {
      print("❌ FireStoreUtils: getZone() error: $error");
      log(error.toString());
    });
    print("🔍 FireStoreUtils: getZone() returning ${airPortList.length} zones");
    return airPortList;
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionList = [];
    await fireStore
        .collection(CollectionName.wallet)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('date', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future getPaymentSettingsData() async {
    await fireStore
        .collection(CollectionName.settings)
        .doc("payFastSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PayFastModel payFastModel = PayFastModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.payFastSettings, jsonEncode(payFastModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("MercadoPago")
        .get()
        .then((value) async {
      if (value.exists) {
        MercadoPagoModel mercadoPagoModel =
            MercadoPagoModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.mercadoPago, jsonEncode(mercadoPagoModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("paypalSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PayPalModel payPalModel = PayPalModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.paypalSettings, jsonEncode(payPalModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("stripeSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        StripeModel stripeModel = StripeModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.stripeSettings, jsonEncode(stripeModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("flutterWave")
        .get()
        .then((value) async {
      if (value.exists) {
        FlutterWaveModel flutterWaveModel =
            FlutterWaveModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.flutterWave, jsonEncode(flutterWaveModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("payStack")
        .get()
        .then((value) async {
      if (value.exists) {
        PayStackModel payStackModel = PayStackModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.payStack, jsonEncode(payStackModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("PaytmSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        PaytmModel paytmModel = PaytmModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.paytmSettings, jsonEncode(paytmModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("walletSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        WalletSettingModel walletSettingModel =
            WalletSettingModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.walletSettings,
            jsonEncode(walletSettingModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("razorpaySettings")
        .get()
        .then((value) async {
      if (value.exists) {
        RazorPayModel razorPayModel = RazorPayModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.razorpaySettings, jsonEncode(razorPayModel.toJson()));
      }
    });
    await fireStore
        .collection(CollectionName.settings)
        .doc("CODSettings")
        .get()
        .then((value) async {
      if (value.exists) {
        CodSettingModel codSettingModel =
            CodSettingModel.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.codSettings, jsonEncode(codSettingModel.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("midtrans_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        MidTrans midTrans = MidTrans.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.midTransSettings, jsonEncode(midTrans.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("orange_money_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        OrangeMoney orangeMoney = OrangeMoney.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.orangeMoneySettings, jsonEncode(orangeMoney.toJson()));
      }
    });

    await fireStore
        .collection(CollectionName.settings)
        .doc("xendit_settings")
        .get()
        .then((value) async {
      if (value.exists) {
        Xendit xendit = Xendit.fromJson(value.data()!);
        await Preferences.setString(
            Preferences.xenditSettings, jsonEncode(xendit.toJson()));
      }
    });
  }

  static Future<VendorModel?> getVendorById(String vendorId) async {
    VendorModel? vendorModel;
    try {
      await fireStore
          .collection(CollectionName.vendors)
          .doc(vendorId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorModel = VendorModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorModel;
  }

  static Future<List<BranchModel>> getBranchesForVendor(String vendorId) async {
    List<BranchModel> branches = [];
    try {
      final snapshot = await fireStore
          .collection(CollectionName.vendors)
          .doc(vendorId)
          .collection('branches')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        branches.add(BranchModel.fromJson(data, documentId: doc.id));
      }
    } catch (e) {
      log('FireStoreUtils.getBranchesForVendor error: $e');
    }
    return branches;
  }

  static StreamController<List<VendorModel>>? getNearestVendorController;

  static Stream<List<VendorModel>> getAllNearestRestaurant(
      {bool? isDining}) async* {
    print("🍕 ========== getAllNearestRestaurant STARTED ==========");
    print("🍕 getAllNearestRestaurant: isDining = $isDining");
    
    try {
      // Check selectedZone
      if (Constant.selectedZone == null) {
        print("❌ getAllNearestRestaurant: Constant.selectedZone is NULL!");
        print("❌ getAllNearestRestaurant: Cannot fetch restaurants without zone");
        getNearestVendorController = StreamController<List<VendorModel>>.broadcast();
        getNearestVendorController!.sink.add([]);
        yield* getNearestVendorController!.stream;
        return;
      }
      
      print("✅ getAllNearestRestaurant: Constant.selectedZone.id = ${Constant.selectedZone!.id}");
      print("✅ getAllNearestRestaurant: Constant.selectedZone.name = ${Constant.selectedZone!.name}");
      
      // Check selectedLocation
      if (Constant.selectedLocation.location == null) {
        print("❌ getAllNearestRestaurant: Constant.selectedLocation.location is NULL!");
        print("❌ getAllNearestRestaurant: Cannot calculate distance without location");
        getNearestVendorController = StreamController<List<VendorModel>>.broadcast();
        getNearestVendorController!.sink.add([]);
        yield* getNearestVendorController!.stream;
        return;
      }
      
      print("✅ getAllNearestRestaurant: selectedLocation.latitude = ${Constant.selectedLocation.location!.latitude}");
      print("✅ getAllNearestRestaurant: selectedLocation.longitude = ${Constant.selectedLocation.location!.longitude}");
      
      // Check radius
      print("🍕 getAllNearestRestaurant: Constant.radius = ${Constant.radius}");
      
      // Check subscription settings
      print("🍕 getAllNearestRestaurant: Constant.isSubscriptionModelApplied = ${Constant.isSubscriptionModelApplied}");
      print("🍕 getAllNearestRestaurant: Constant.adminCommission?.isEnabled = ${Constant.adminCommission?.isEnabled}");
      
      getNearestVendorController =
          StreamController<List<VendorModel>>.broadcast();
      List<VendorModel> vendorList = [];
      
      // Build query
      Query<Map<String, dynamic>> query = isDining == true
          ? fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString())
              .where("enabledDiveInFuture", isEqualTo: true)
          : fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString());

      print("🍕 getAllNearestRestaurant: Query built - isDining: $isDining, zoneId: ${Constant.selectedZone!.id}");

      GeoFirePoint center = Geoflutterfire().point(
          latitude: Constant.selectedLocation.location!.latitude ?? 0.0,
          longitude: Constant.selectedLocation.location!.longitude ?? 0.0);
      String field = 'g';

      print("🍕 getAllNearestRestaurant: GeoFirePoint center created at (${center.latitude}, ${center.longitude})");
      print("🍕 getAllNearestRestaurant: Searching within radius: ${Constant.radius}km");
      print("🍕 getAllNearestRestaurant: Field = $field, strictMode = true");

      Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
          .collection(collectionRef: query)
          .within(
              center: center,
              radius: double.parse(Constant.radius),
              field: field,
              strictMode: true);

      print("🍕 getAllNearestRestaurant: Stream created, listening for documents...");

      stream.listen(
        (List<DocumentSnapshot> documentList) async {
          print("🍕 ========== Stream received ${documentList.length} documents ==========");
        vendorList.clear();
          
          int addedCount = 0;
          int skippedSubscriptionCount = 0;
          int skippedLocationCount = 0;
          int skippedOtherCount = 0;
          int errorCount = 0;
          
          if (documentList.isEmpty) {
            print("⚠️ getAllNearestRestaurant: documentList is EMPTY!");
            print("⚠️ This could mean:");
            print("   1. No restaurants in zoneId: ${Constant.selectedZone!.id}");
            print("   2. No restaurants within radius: ${Constant.radius}km");
            print("   3. All restaurants are outside the search radius");
            if (isDining == true) {
              print("   4. All restaurants don't have enabledDiveInFuture = true");
            }
          }
          
        for (var document in documentList) {
            try {
          final data = document.data() as Map<String, dynamic>;
              
              print("🍕 getAllNearestRestaurant: Processing document ID: ${document.id}");
              
              // Check if document has required fields
              if (!data.containsKey('g') || data['g'] == null) {
                print("⚠️ getAllNearestRestaurant: Document ${document.id} has no 'g' field (geo location)");
                skippedLocationCount++;
                continue;
              }
              
          VendorModel vendorModel = VendorModel.fromJson(data);
              
              print("🍕 getAllNearestRestaurant: Restaurant parsed - id=${vendorModel.id}, title=${vendorModel.title}, zoneId=${vendorModel.zoneId}");
              
              // Check zone match
              if (vendorModel.zoneId != Constant.selectedZone!.id.toString()) {
                print("⚠️ getAllNearestRestaurant: Restaurant ${vendorModel.id} zoneId (${vendorModel.zoneId}) doesn't match selectedZone (${Constant.selectedZone!.id})");
                skippedOtherCount++;
                continue;
              }
              
              // Check subscription model
              bool subscriptionCheckPassed = false;
              
          if ((Constant.isSubscriptionModelApplied == true ||
                  Constant.adminCommission?.isEnabled == true) &&
              vendorModel.subscriptionPlan != null) {
                print("🍕 getAllNearestRestaurant: Restaurant ${vendorModel.id} has subscription plan");
                print("   - subscriptionTotalOrders: ${vendorModel.subscriptionTotalOrders}");
                print("   - subscriptionExpiryDate: ${vendorModel.subscriptionExpiryDate?.toDate()}");
                print("   - subscriptionPlan.expiryDay: ${vendorModel.subscriptionPlan?.expiryDay}");
                
            if (vendorModel.subscriptionTotalOrders == "-1") {
                  print("✅ getAllNearestRestaurant: Restaurant ${vendorModel.id} has unlimited orders");
                  subscriptionCheckPassed = true;
            } else {
                  bool isExpired = false;
                  if (vendorModel.subscriptionExpiryDate != null) {
                    isExpired = vendorModel.subscriptionExpiryDate!.toDate().isBefore(DateTime.now());
                    print("   - Subscription expiry check: ${isExpired ? 'EXPIRED' : 'VALID'} (${vendorModel.subscriptionExpiryDate!.toDate()})");
                  } else if (vendorModel.subscriptionPlan?.expiryDay != "-1") {
                    isExpired = true;
                    print("   - No expiry date but expiryDay != -1, treating as expired");
                  }
                  
                  bool isUnlimitedExpiry = vendorModel.subscriptionPlan?.expiryDay == "-1";
                  print("   - Is unlimited expiry: $isUnlimitedExpiry");
                  
                  if (!isExpired || isUnlimitedExpiry) {
                if (vendorModel.subscriptionTotalOrders != '0') {
                      print("✅ getAllNearestRestaurant: Restaurant ${vendorModel.id} subscription is valid");
                      subscriptionCheckPassed = true;
                    } else {
                      print("⚠️ getAllNearestRestaurant: Restaurant ${vendorModel.id} subscription orders = 0, skipping");
                      skippedSubscriptionCount++;
                    }
                  } else {
                    print("⚠️ getAllNearestRestaurant: Restaurant ${vendorModel.id} subscription expired, skipping");
                    skippedSubscriptionCount++;
              }
            }
          } else {
                print("✅ getAllNearestRestaurant: Restaurant ${vendorModel.id} has no subscription requirement");
                subscriptionCheckPassed = true;
              }
              
              if (subscriptionCheckPassed) {
            vendorList.add(vendorModel);
                addedCount++;
                print("✅ getAllNearestRestaurant: Restaurant ${vendorModel.id} ADDED to list (Total: ${vendorList.length})");
              }
            } catch (e, stackTrace) {
              errorCount++;
              print("❌ getAllNearestRestaurant: Error parsing document ${document.id}: $e");
              print("❌ Stack trace: $stackTrace");
            }
          }
          
          print("🍕 ========== Processing complete ==========");
          print("   ✅ Added: $addedCount restaurants");
          print("   ⚠️ Skipped (subscription): $skippedSubscriptionCount");
          print("   ⚠️ Skipped (location): $skippedLocationCount");
          print("   ⚠️ Skipped (other): $skippedOtherCount");
          print("   ❌ Errors: $errorCount");
          print("   📊 Total in vendorList: ${vendorList.length}");
          print("   📊 Total documents received: ${documentList.length}");
          
          if (vendorList.isEmpty && documentList.isNotEmpty) {
            print("⚠️ getAllNearestRestaurant: vendorList is EMPTY but received ${documentList.length} documents!");
            print("⚠️ This means all restaurants were filtered out by:");
            if (skippedSubscriptionCount > 0) {
              print("   - Subscription checks: $skippedSubscriptionCount");
            }
            if (skippedLocationCount > 0) {
              print("   - Location checks: $skippedLocationCount");
            }
            if (skippedOtherCount > 0) {
              print("   - Other filters: $skippedOtherCount");
            }
          }
          
          print("🍕 getAllNearestRestaurant: Sending ${vendorList.length} restaurants to stream...");
        getNearestVendorController!.sink.add(vendorList);
          print("🍕 getAllNearestRestaurant: Stream updated with ${vendorList.length} restaurants");
        },
        onError: (error) {
          print("❌ getAllNearestRestaurant: Stream ERROR: $error");
          print("❌ getAllNearestRestaurant: Error type: ${error.runtimeType}");
          if (error is Error) {
            print("❌ getAllNearestRestaurant: Stack trace: ${error.stackTrace}");
          }
          getNearestVendorController!.sink.addError(error);
        },
        cancelOnError: false,
      );

      yield* getNearestVendorController!.stream;
    } catch (e, stackTrace) {
      print("❌ getAllNearestRestaurant: EXCEPTION caught: $e");
      print("❌ getAllNearestRestaurant: Exception type: ${e.runtimeType}");
      print("❌ getAllNearestRestaurant: Stack trace: $stackTrace");
      
      // Return empty stream on error
      getNearestVendorController = StreamController<List<VendorModel>>.broadcast();
      getNearestVendorController!.sink.add([]);
      yield* getNearestVendorController!.stream;
    }
  }

  static StreamController<List<VendorModel>>?
      getNearestVendorByCategoryController;

  static Stream<List<VendorModel>> getAllNearestRestaurantByCategoryId(
      {bool? isDining, required String categoryId}) async* {
    print("🔍 FireStoreUtils: getAllNearestRestaurantByCategoryId called");
    print("🔍 FireStoreUtils: categoryId = $categoryId");
    print("🔍 FireStoreUtils: isDining = $isDining");
    print("🔍 FireStoreUtils: Constant.selectedZone = ${Constant.selectedZone?.toJson()}");
    print("🔍 FireStoreUtils: Constant.isZoneAvailable = ${Constant.isZoneAvailable}");
    print("🔍 FireStoreUtils: Constant.selectedLocation = ${Constant.selectedLocation.toJson()}");
    
    try {
      if (Constant.selectedZone == null) {
        print("❌ FireStoreUtils: selectedZone is null, cannot fetch restaurants");
        getNearestVendorByCategoryController =
            StreamController<List<VendorModel>>.broadcast();
        getNearestVendorByCategoryController!.sink.add([]);
        yield* getNearestVendorByCategoryController!.stream;
        return;
      }
      
      getNearestVendorByCategoryController =
          StreamController<List<VendorModel>>.broadcast();
      List<VendorModel> vendorList = [];
      
      print("🔍 FireStoreUtils: Building query for zoneId: ${Constant.selectedZone!.id}");
      Query<Map<String, dynamic>> query = isDining == true
          ? fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString())
              .where('categoryID', isEqualTo: categoryId)
              .where("enabledDiveInFuture", isEqualTo: true)
          : fireStore
              .collection(CollectionName.vendors)
              .where('zoneId', isEqualTo: Constant.selectedZone!.id.toString())
              .where('categoryID', isEqualTo: categoryId);

      // التحقق من وجود الموقع المحدد
      if (Constant.selectedLocation.location == null) {
        print("❌ FireStoreUtils: selectedLocation.location is null, using default location");
        getNearestVendorByCategoryController!.sink.add([]);
        yield* getNearestVendorByCategoryController!.stream;
        return;
      }
      
      GeoFirePoint center = Geoflutterfire().point(
          latitude: Constant.selectedLocation.location!.latitude ?? 0.0,
          longitude: Constant.selectedLocation.location!.longitude ?? 0.0);
      String field = 'g';

      Stream<List<DocumentSnapshot>> stream = Geoflutterfire()
          .collection(collectionRef: query)
          .within(
              center: center,
              radius: double.parse(Constant.radius),
              field: field,
              strictMode: true);

      stream.listen((List<DocumentSnapshot> documentList) async {
        print("🔍 FireStoreUtils: Received ${documentList.length} documents from stream");
        vendorList.clear();
        for (var document in documentList) {
          print("🔍 FireStoreUtils: Processing document: ${document.id}");
          final data = document.data() as Map<String, dynamic>;
          print("🔍 FireStoreUtils: Document data: $data");
          VendorModel vendorModel = VendorModel.fromJson(data);
          print("🔍 FireStoreUtils: Parsed vendor: ${vendorModel.title}");
          if ((Constant.isSubscriptionModelApplied == true ||
                  Constant.adminCommission?.isEnabled == true) &&
              vendorModel.subscriptionPlan != null) {
            if (vendorModel.subscriptionTotalOrders == "-1") {
              vendorList.add(vendorModel);
            } else {
              if ((vendorModel.subscriptionExpiryDate != null &&
                      vendorModel.subscriptionExpiryDate!
                              .toDate()
                              .isBefore(DateTime.now()) ==
                          false) ||
                  vendorModel.subscriptionPlan?.expiryDay == '-1') {
                if (vendorModel.subscriptionTotalOrders != '0') {
                  vendorList.add(vendorModel);
                }
              }
            }
          } else {
            vendorList.add(vendorModel);
          }
        }
        print("🔍 FireStoreUtils: Final vendor list size: ${vendorList.length}");
        getNearestVendorByCategoryController!.sink.add(vendorList);
      }).onError((error) {
        print("❌ FireStoreUtils: Stream error: $error");
        getNearestVendorByCategoryController!.sink.add([]);
      });

      yield* getNearestVendorByCategoryController!.stream;
    } catch (e) {
      print("❌ FireStoreUtils: getAllNearestRestaurantByCategoryId error: $e");
      getNearestVendorByCategoryController =
          StreamController<List<VendorModel>>.broadcast();
      getNearestVendorByCategoryController!.sink.add([]);
      yield* getNearestVendorByCategoryController!.stream;
    }
  }

  static Future<List<StoryModel>> getStory() async {
    List<StoryModel> storyList = [];
    DateTime now = DateTime.now();
    DateTime twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    
    await fireStore
        .collection(CollectionName.story)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(twentyFourHoursAgo))
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) {
      print("📱 FireStoreUtils: Found ${value.docs.length} stories within 24 hours");
      for (var element in value.docs) {
        StoryModel storyModel = StoryModel.fromJson(element.data());
        storyList.add(storyModel);
        print("📱 Story: ${storyModel.vendorID} - ${storyModel.createdAt?.toDate()}");
      }
    }).catchError((error) {
      print("❌ FireStoreUtils: Error getting stories: $error");
      log(error.toString());
    });
    return storyList;
  }

  static Future<List<CouponModel>> getHomeCoupon() async {
    List<CouponModel> list = [];
    await fireStore
        .collection(CollectionName.coupons)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel walletTransactionModel =
            CouponModel.fromJson(element.data());
        list.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<VendorCategoryModel>> getHomeVendorCategory() async {
    List<VendorCategoryModel> list = [];
    await fireStore
        .collection(CollectionName.vendorCategories)
        .where("show_in_homepage", isEqualTo: true)
        .where('publish', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VendorCategoryModel walletTransactionModel =
            VendorCategoryModel.fromJson(element.data());
        list.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<VendorCategoryModel>> getVendorCategory() async {
    List<VendorCategoryModel> list = [];
    await fireStore
        .collection(CollectionName.vendorCategories)
        .where('publish', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        VendorCategoryModel walletTransactionModel =
            VendorCategoryModel.fromJson(element.data());
        list.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<BannerModel>> getHomeTopBanner() async {
    List<BannerModel> bannerList = [];
    await fireStore
        .collection(CollectionName.menuItems)
        .where("is_publish", isEqualTo: true)
        .where("position", isEqualTo: "top")
        .orderBy("set_order", descending: false)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          BannerModel bannerHome = BannerModel.fromJson(element.data());
          bannerList.add(bannerHome);
        }
      },
    );
    return bannerList;
  }

  static Future<List<BannerModel>> getHomeBottomBanner() async {
    List<BannerModel> bannerList = [];
    await fireStore
        .collection(CollectionName.menuItems)
        .where("is_publish", isEqualTo: true)
        .where("position", isEqualTo: "middle")
        .orderBy("set_order", descending: false)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          BannerModel bannerHome = BannerModel.fromJson(element.data());
          bannerList.add(bannerHome);
        }
      },
    );
    return bannerList;
  }

  static Future<List<FavouriteModel>> getFavouriteRestaurant() async {
    List<FavouriteModel> favouriteList = [];
    await fireStore
        .collection(CollectionName.favoriteRestaurant)
        .where('user_id', isEqualTo: getCurrentUid())
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          FavouriteModel favouriteModel =
              FavouriteModel.fromJson(element.data());
          favouriteList.add(favouriteModel);
        }
      },
    );
    return favouriteList;
  }

  static Future<List<FavouriteItemModel>> getFavouriteItem() async {
    List<FavouriteItemModel> favouriteList = [];
    await fireStore
        .collection(CollectionName.favoriteItem)
        .where('user_id', isEqualTo: getCurrentUid())
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          FavouriteItemModel favouriteModel =
              FavouriteItemModel.fromJson(element.data());
          favouriteList.add(favouriteModel);
        }
      },
    );
    return favouriteList;
  }

  static Future removeFavouriteRestaurant(FavouriteModel favouriteModel) async {
    await fireStore
        .collection(CollectionName.favoriteRestaurant)
        .where("restaurant_id", isEqualTo: favouriteModel.restaurantId)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await fireStore
            .collection(CollectionName.favoriteRestaurant)
            .doc(element.id)
            .delete();
      });
    });
  }

  static Future<void> setFavouriteRestaurant(
      FavouriteModel favouriteModel) async {
    await fireStore
        .collection(CollectionName.favoriteRestaurant)
        .add(favouriteModel.toJson());
  }

  static Future<void> removeFavouriteItem(
      FavouriteItemModel favouriteModel) async {
    try {
      final favoriteCollection =
          fireStore.collection(CollectionName.favoriteItem);
      final querySnapshot = await favoriteCollection
          .where("product_id", isEqualTo: favouriteModel.productId)
          .get();
      for (final doc in querySnapshot.docs) {
        await favoriteCollection.doc(doc.id).delete();
      }
    } catch (e) {
      print("Error removing favourite item: $e");
    }
  }

  static Future<void> setFavouriteItem(
      FavouriteItemModel favouriteModel) async {
    await fireStore
        .collection(CollectionName.favoriteItem)
        .add(favouriteModel.toJson());
  }

  static Future<List<ProductModel>> getProductByVendorId(
      String vendorId) async {
    print("🔍 FireStoreUtils: getProductByVendorId called for vendorId: $vendorId");
    String selectedFoodType = Preferences.getString(
        Preferences.foodDeliveryType,
        defaultValue: "TakeAway".tr);
    print("🔍 FireStoreUtils: selectedFoodType = $selectedFoodType");
    List<ProductModel> list = [];
    
    // جلب جميع المنتجات (منشورة وغير منشورة للتطوير)
    print("🔍 FireStoreUtils: Querying for all products (including unpublished for development)");
    await fireStore
        .collection(CollectionName.vendorProducts)
        .where("vendorID", isEqualTo: vendorId)
        .orderBy("createdAt", descending: false)
        .get()
        .then((value) {
      print("🔍 FireStoreUtils: Found ${value.docs.length} total products");
      for (var element in value.docs) {
        print("🔍 FireStoreUtils: Product data: ${element.data()}");
        ProductModel productModel = ProductModel.fromJson(element.data());
        
        // فلترة المنتجات حسب نوع الطعام المحدد
        if (selectedFoodType == "TakeAway") {
          // للمطاعم TakeAway، نأخذ جميع المنتجات
          list.add(productModel);
          print("🔍 FireStoreUtils: Added TakeAway product: ${productModel.name}, Photo: ${productModel.photo}");
        } else {
          // للمطاعم DineIn، نأخذ المنتجات التي تدعم DineIn أو المنتجات الخاصة
          if (productModel.takeawayOption == false || 
              productModel.takeawayOption == null ||
              productModel.name == "Mystery Box" || 
              productModel.name == "Gift Bag" ||
              productModel.name == "Surprise Bag" ||
              productModel.name == "Surprise bag") {
            list.add(productModel);
            print("🔍 FireStoreUtils: Added DineIn product: ${productModel.name}, Photo: ${productModel.photo}");
          } else {
            print("🔍 FireStoreUtils: Skipped TakeAway-only product: ${productModel.name}");
          }
        }
      }
    }).catchError((error) {
      print("❌ FireStoreUtils: Error getting products: $error");
      log(error.toString());
    });

    print("🔍 FireStoreUtils: Returning ${list.length} products for $selectedFoodType");
    return list;
  }

  /// جلب المنتجات الخاصة من Firestore حسب vendorID
  static Future<List<ProductModel>> getSpecialProductsByVendorId(String vendorId) async {
    print("🎁 FireStoreUtils: getSpecialProductsByVendorId called for: $vendorId");
    List<ProductModel> list = [];
    
    try {
      await fireStore
          .collection(CollectionName.vendorProducts)
          .where("vendorID", isEqualTo: vendorId)
          .get()
          .then((value) {
        print("🎁 FireStoreUtils: Found ${value.docs.length} products for vendor $vendorId");
        for (var element in value.docs) {
          ProductModel productModel = ProductModel.fromJson(element.data());
          
          // فلترة محلية للمنتجات الخاصة فقط (التي تحتوي على special_type)
          if (productModel.specialType != null && 
              productModel.specialType!.isNotEmpty &&
              (productModel.specialType == "surprise_bag" || 
               productModel.specialType == "mystery_box")) {
            list.add(productModel);
            print("🎁 FireStoreUtils: Added special product: ${productModel.name}, Type: ${productModel.specialType}, Price: ${productModel.price}");
          } else {
            print("🔍 FireStoreUtils: Skipped regular product: ${productModel.name}");
          }
        }
      }).catchError((error) {
        print("❌ FireStoreUtils: Error getting special products: $error");
        log(error.toString());
      });
    } catch (e) {
      print("❌ FireStoreUtils: Exception getting special products: $e");
    }

    print("🎁 FireStoreUtils: Returning ${list.length} special products for vendor $vendorId");
    return list;
  }

  /// جلب المنتجات الخاصة من Firestore (للاستخدام العام)
  static Future<List<ProductModel>> getSpecialProducts() async {
    print("🎁 FireStoreUtils: getSpecialProducts called");
    List<ProductModel> list = [];
    
    try {
      // تبسيط الاستعلام لتجنب الحاجة لفهرس معقد
      await fireStore
          .collection(CollectionName.vendorProducts)
          .where("isSpecialProduct", isEqualTo: true)
          .get()
          .then((value) {
        print("🎁 FireStoreUtils: Found ${value.docs.length} special products");
        for (var element in value.docs) {
          print("🎁 FireStoreUtils: Special product data: ${element.data()}");
          ProductModel productModel = ProductModel.fromJson(element.data());
          
          // فلترة محلية للمنتجات المطلوبة
          if (productModel.categoryID == "special_products_category" && 
              productModel.publish == true &&
              (productModel.name == "Mystery Box" || 
               productModel.name == "Gift Bag" || 
               productModel.name == "Surprise Bag")) {
            list.add(productModel);
            print("🎁 FireStoreUtils: Added special product: ${productModel.name}, Price: ${productModel.price}, ID: ${productModel.id}");
          } else {
            print("🎁 FireStoreUtils: Skipped product: ${productModel.name} (doesn't match criteria)");
          }
        }
      }).catchError((error) {
        print("❌ FireStoreUtils: Error getting special products: $error");
        log(error.toString());
      });
    } catch (e) {
      print("❌ FireStoreUtils: Exception getting special products: $e");
    }

    print("🎁 FireStoreUtils: Returning ${list.length} special products");
    return list;
  }

  static Future<List<MenuModel>> getMenuItems(String vendorId) async {
    try {
      QuerySnapshot snapshot = await fireStore
          .collection(CollectionName.menu)
          .where('menu_id', isEqualTo: vendorId)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['document_id'] = doc.id; // Optional: store the document ID
        return MenuModel.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error fetching menu items: $e");
      return [];
    }
  }

  static Future<VendorCategoryModel?> getVendorCategoryById(
      String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorCategories)
          .doc(categoryId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = VendorCategoryModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ProductModel?> getProductById(String productId) async {
    ProductModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorProducts)
          .doc(productId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = ProductModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<List<CouponModel>> getOfferByVendorId(String vendorId) async {
    List<CouponModel> couponList = [];
    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          CouponModel favouriteModel = CouponModel.fromJson(element.data());
          couponList.add(favouriteModel);
        }
      },
    );
    return couponList;
  }

  static Future<List<AttributesModel>?> getAttributes() async {
    List<AttributesModel> attributeList = [];
    await fireStore.collection(CollectionName.vendorAttributes).get().then(
      (value) {
        for (var element in value.docs) {
          AttributesModel favouriteModel =
              AttributesModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
    return attributeList;
  }

  static Future<DeliveryCharge?> getDeliveryCharge() async {
    DeliveryCharge? deliveryCharge;
    try {
      await fireStore
          .collection(CollectionName.settings)
          .doc("DeliveryCharge")
          .get()
          .then((value) {
        if (value.exists) {
          deliveryCharge = DeliveryCharge.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return deliveryCharge;
  }

  static Future<List<TaxModel>?> getTaxList() async {
    List<TaxModel> taxList = [];
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(30.044727, 31.238251);
    await fireStore
        .collection(CollectionName.tax)
        .where('country', isEqualTo: placeMarks.first.country)
        .where('enable', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });

    return taxList;
  }

  static Future<List<CouponModel>> getAllVendorPublicCoupons(
      String vendorId) async {
    List<CouponModel> coupon = [];

    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        coupon.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return coupon;
  }

  static Future<List<CouponModel>> getAllVendorCoupons(String vendorId) async {
    List<CouponModel> coupon = [];

    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        coupon.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return coupon;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.restaurantOrders)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setProduct(ProductModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.vendorProducts)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setBookedOrder(DineInBookingModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bookedTable)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<OrderModel>> getAllOrder() async {
    List<OrderModel> list = [];

    await fireStore
        .collection(CollectionName.restaurantOrders)
        .where("authorID", isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy("createdAt", descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        OrderModel taxModel = OrderModel.fromJson(element.data());
        list.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<OrderModel?> getOrderByOrderId(String orderId) async {
    OrderModel? orderModel;
    try {
      await fireStore
          .collection(CollectionName.restaurantOrders)
          .doc(orderId)
          .get()
          .then((value) {
        if (value.data() != null) {
          orderModel = OrderModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return orderModel;
  }

  static Future<List<DineInBookingModel>> getDineInBooking(
      bool isUpcoming) async {
    List<DineInBookingModel> list = [];

    if (isUpcoming) {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('author.id', isEqualTo: getCurrentUid())
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('author.id', isEqualTo: getCurrentUid())
          .where('date', isLessThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    }

    return list;
  }

  static Future<ReferralModel?> getReferralUserBy() async {
    ReferralModel? referralModel;
    try {
      await fireStore
          .collection(CollectionName.referral)
          .doc(getCurrentUid())
          .get()
          .then((value) {
        referralModel = ReferralModel.fromJson(value.data()!);
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<List<GiftCardsModel>> getGiftCard() async {
    List<GiftCardsModel> giftCardModelList = [];
    QuerySnapshot<Map<String, dynamic>> currencyQuery = await fireStore
        .collection(CollectionName.giftCards)
        .where("isEnable", isEqualTo: true)
        .get();
    await Future.forEach(currencyQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      try {
        log(document.data().toString());
        giftCardModelList.add(GiftCardsModel.fromJson(document.data()));
      } catch (e) {
        debugPrint('FireStoreUtils.get Currency Parse error $e');
      }
    });
    return giftCardModelList;
  }

  static Future<GiftCardsOrderModel> placeGiftCardOrder(
      GiftCardsOrderModel giftCardsOrderModel) async {
    print("=====>");
    print(giftCardsOrderModel.toJson());
    await fireStore
        .collection(CollectionName.giftPurchases)
        .doc(giftCardsOrderModel.id)
        .set(giftCardsOrderModel.toJson());
    return giftCardsOrderModel;
  }

  static Future<GiftCardsOrderModel?> checkRedeemCode(String giftCode) async {
    GiftCardsOrderModel? giftCardsOrderModel;
    await fireStore
        .collection(CollectionName.giftPurchases)
        .where("giftCode", isEqualTo: giftCode)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        giftCardsOrderModel =
            GiftCardsOrderModel.fromJson(value.docs.first.data());
      }
    });
    return giftCardsOrderModel;
  }

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    EmailTemplateModel? emailTemplateModel;
    await fireStore
        .collection(CollectionName.emailTemplates)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());
        emailTemplateModel =
            EmailTemplateModel.fromJson(value.docs.first.data());
      }
    });
    return emailTemplateModel;
  }

  static Future<List<GiftCardsOrderModel>> getGiftHistory() async {
    List<GiftCardsOrderModel> giftCardsOrderList = [];
    await fireStore
        .collection(CollectionName.giftPurchases)
        .where("userid", isEqualTo: FireStoreUtils.getCurrentUid())
        .get()
        .then((value) {
      for (var element in value.docs) {
        GiftCardsOrderModel giftCardsOrderModel =
            GiftCardsOrderModel.fromJson(element.data());
        giftCardsOrderList.add(giftCardsOrderModel);
      }
    });
    return giftCardsOrderList;
  }

  static sendTopUpMail(
      {required String amount,
      required String paymentMethod,
      required String tractionId}) async {
    EmailTemplateModel? emailTemplateModel =
        await FireStoreUtils.getEmailTemplates(Constant.walletTopup);

    String newString = emailTemplateModel!.message.toString();
    newString = newString.replaceAll(
        "{username}",
        Constant.userModel!.firstName.toString() +
            Constant.userModel!.lastName.toString());
    newString = newString.replaceAll(
        "{date}", DateFormat('yyyy-MM-dd').format(Timestamp.now().toDate()));
    newString =
        newString.replaceAll("{amount}", Constant.amountShow(amount: amount));
    newString =
        newString.replaceAll("{paymentmethod}", paymentMethod.toString());
    newString = newString.replaceAll("{transactionid}", tractionId.toString());
    newString = newString.replaceAll(
        "{newwalletbalance}.",
        Constant.amountShow(
            amount: Constant.userModel!.walletAmount.toString()));
    await Constant.sendMail(
        subject: emailTemplateModel.subject,
        isAdmin: emailTemplateModel.isSendToAdmin,
        body: newString,
        recipients: [Constant.userModel!.email]);
  }

  static Future<List> getVendorCuisines(String id) async {
    List tagList = [];
    List prodTagList = [];
    QuerySnapshot<Map<String, dynamic>> productsQuery = await fireStore
        .collection(CollectionName.vendorProducts)
        .where('vendorID', isEqualTo: id)
        .get();
    await Future.forEach(productsQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      if (document.data().containsKey("categoryID") &&
          document.data()['categoryID'].toString().isNotEmpty) {
        prodTagList.add(document.data()['categoryID']);
      }
    });
    QuerySnapshot<Map<String, dynamic>> catQuery = await fireStore
        .collection(CollectionName.vendorCategories)
        .where('publish', isEqualTo: true)
        .get();
    await Future.forEach(catQuery.docs,
        (QueryDocumentSnapshot<Map<String, dynamic>> document) {
      Map<String, dynamic> catDoc = document.data();
      if (catDoc.containsKey("id") &&
          catDoc['id'].toString().isNotEmpty &&
          catDoc.containsKey("title") &&
          catDoc['title'].toString().isNotEmpty &&
          prodTagList.contains(catDoc['id'])) {
        tagList.add(catDoc['title']);
      }
    });
    return tagList;
  }

  static Future<NotificationModel?> getNotificationContent(String type) async {
    NotificationModel? notificationModel;
    await fireStore
        .collection(CollectionName.dynamicNotification)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());

        notificationModel = NotificationModel.fromJson(value.docs.first.data());
      } else {
        notificationModel = NotificationModel(
            id: "",
            message: "Notification setup is pending",
            subject: "setup notification",
            type: "");
      }
    });
    return notificationModel;
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      // Get user ID - prefer Firebase Auth UID, fallback to Constant.userModel.id
      String userId;
      try {
        if (FirebaseAuth.instance.currentUser != null) {
          userId = FireStoreUtils.getCurrentUid();
        } else if (Constant.userModel?.id != null && Constant.userModel!.id!.isNotEmpty) {
          userId = Constant.userModel!.id!;
        } else {
          log('FireStoreUtils.deleteUser: No user ID found');
          return false;
        }
      } catch (e) {
        if (Constant.userModel?.id != null && Constant.userModel!.id!.isNotEmpty) {
          userId = Constant.userModel!.id!;
        } else {
          log('FireStoreUtils.deleteUser: Failed to get user ID: $e');
          return false;
        }
      }

      // Delete user from Firestore first
      await fireStore
          .collection(CollectionName.users)
          .doc(userId)
          .delete();
      log('FireStoreUtils.deleteUser: User deleted from Firestore');

      // Try to delete user from Firebase Auth if exists
      // Note: This may fail if re-authentication is required
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // Try to delete from Firebase Auth
          await currentUser.delete();
          log('FireStoreUtils.deleteUser: User deleted from Firebase Auth');
        } on FirebaseAuthException catch (e) {
          // Handle specific Firebase Auth errors
          if (e.code == 'requires-recent-login') {
            log('FireStoreUtils.deleteUser: Re-authentication required for Firebase Auth deletion. User data deleted from Firestore.');
            // User data is already deleted from Firestore, so we continue
            // We'll just sign out the user
          } else {
            log('FireStoreUtils.deleteUser: Firebase Auth deletion error: ${e.code} - ${e.message}');
            // Continue anyway since Firestore deletion succeeded
          }
        } catch (e) {
          log('FireStoreUtils.deleteUser: Unexpected error deleting from Firebase Auth: $e');
          // Continue anyway since Firestore deletion succeeded
        }
      } else {
        log('FireStoreUtils.deleteUser: No Firebase Auth user to delete');
      }

      // Sign out to clear any remaining auth state
      try {
        await FirebaseAuth.instance.signOut();
        log('FireStoreUtils.deleteUser: User signed out successfully');
      } catch (e) {
        log('FireStoreUtils.deleteUser: Error signing out: $e');
      }

      // Consider deletion successful if Firestore deletion succeeded
        isDelete = true;
    } catch (e, s) {
      log('FireStoreUtils.deleteUser error: $e $s');
      return false;
    }
    return isDelete;
  }

  static Future addDriverInbox(InboxModel inboxModel) async {
    return await fireStore
        .collection("chat_driver")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addDriverChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection("chat_driver")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    ShowToastDialog.showLoader("Please wait".tr);
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(image);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(
      BuildContext context, File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef =
          FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: video.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        maxWidth: 200,
        quality: 75,
      );

      if (thumbnailBytes == null || thumbnailBytes.isEmpty) {
        throw Exception("Failed to generate thumbnail.");
      }

      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef =
          FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnailBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(
          videoUrl: Url(
              url: videoUrl.toString(),
              mime: metaData.contentType ?? 'video',
              videoThumbnail: thumbnailUrl),
          thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<List<RatingModel>> getVendorReviews(String vendorId) async {
    List<RatingModel> ratingList = [];
    await fireStore
        .collection(CollectionName.foodsReview)
        .where('VendorId', isEqualTo: vendorId)
        .get()
        .then((value) {
      for (var element in value.docs) {
        RatingModel giftCardsOrderModel = RatingModel.fromJson(element.data());
        ratingList.add(giftCardsOrderModel);
      }
    });
    return ratingList;
  }

  static Future<RatingModel?> getOrderReviewsByID(
      String orderId, String productID) async {
    RatingModel? ratingModel;

    await fireStore
        .collection(CollectionName.foodsReview)
        .where('orderid', isEqualTo: orderId)
        .where('productId', isEqualTo: productID)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ratingModel = RatingModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log(error.toString());
    });
    return ratingModel;
  }

  static Future<VendorCategoryModel?> getVendorCategoryByCategoryId(
      String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorCategories)
          .doc(categoryId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = VendorCategoryModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ReviewAttributeModel?> getVendorReviewAttribute(
      String attributeId) async {
    ReviewAttributeModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.reviewAttributes)
          .doc(attributeId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = ReviewAttributeModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<bool?> setRatingModel(RatingModel ratingModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.foodsReview)
        .doc(ratingModel.id)
        .set(ratingModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await fireStore
        .collection(CollectionName.vendors)
        .doc(vendor.id)
        .set(vendor.toJson())
        .then((document) {
      return vendor;
    });
  }
}
