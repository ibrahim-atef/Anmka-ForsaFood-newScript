import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/dine_in_booking/dine_in_booking_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/dine_in_booking_model.dart';
import 'package:customer/models/dine_in_settings_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DineInRestaurantDetailsController extends GetxController {
  Rx<TextEditingController> searchEditingController = TextEditingController().obs;

  Rx<TextEditingController> additionRequestController = TextEditingController().obs;

  RxBool isLoading = true.obs;
  RxBool firstVisit = false.obs;
  Rx<PageController> pageController = PageController().obs;
  RxInt currentPage = 0.obs;
  RxInt noOfQuantity = 1.obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList tags = [].obs;

  List occasionList = ["Birthday", "Anniversary"];
  RxString selectedOccasion = "".obs;

  RxList<DateModel> dateList = <DateModel>[].obs;
  RxList<TimeModel> timeSlotList = <TimeModel>[].obs;

  Rx<Timestamp> selectedDate = Timestamp.now().obs;
  RxString selectedTimeSlot = '6:00 PM'.obs;

  RxString selectedTimeDiscount = '0'.obs;
  RxString selectedTimeDiscountType = ''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    getRecord();
    super.onInit();
  }

  orderBook() async {
    ShowToastDialog.showLoader("Please wait".tr);

    DateTime dt = selectedDate.value.toDate();
    String hour = DateFormat("kk:mm").format(DateFormat('hh:mm a').parse((Intl.getCurrentLocale() == "en_US") ? selectedTimeSlot.value : selectedTimeSlot.value.toLowerCase()));
    dt = DateTime(dt.year, dt.month, dt.day, int.parse(hour.split(":")[0]), int.parse(hour.split(":")[1]), dt.second, dt.millisecond, dt.microsecond);
    selectedDate.value = Timestamp.fromDate(dt);
    DineInBookingModel dineInBookingModel = DineInBookingModel(
        id: Constant.getUuid(),
        author: Constant.userModel,
        authorID: FireStoreUtils.getCurrentUid(),
        createdAt: Timestamp.now(),
        date: selectedDate.value,
        status: Constant.orderPlaced,
        vendor: vendorModel.value,
        specialRequest: additionRequestController.value.text.isEmpty ? "" : additionRequestController.value.text,
        vendorID: vendorModel.value.id,
        guestEmail: Constant.userModel!.email,
        guestFirstName: Constant.userModel!.firstName,
        guestLastName: Constant.userModel!.lastName,
        guestPhone: Constant.userModel!.phoneNumber,
        occasion: selectedOccasion.value,
        discount: selectedTimeDiscount.value,
        discountType: selectedTimeDiscountType.value,
        totalGuest: noOfQuantity.value.toString(),
        firstVisit: firstVisit.value);
    await FireStoreUtils.setBookedOrder(dineInBookingModel);
    await SendNotification.sendFcmMessage(Constant.dineInPlaced, vendorModel.value.fcmToken.toString(), {});
    ShowToastDialog.closeLoader();
    Get.back();
    Get.to(const DineInBookingScreen());
    ShowToastDialog.showToast('Dine-In Request submitted successfully.'.tr);
  }

  getRecord() {
    for (int i = 0; i < 7; i++) {
      final now = DateTime.now().add(Duration(days: i));
      var day = DateFormat('EEEE').format(now);
      
      // Check if new dineInSettings exists and is enabled
      if (vendorModel.value.dineInSettings != null && 
          vendorModel.value.dineInSettings!.isEnabled == true &&
          vendorModel.value.dineInSettings!.daysSettings != null) {
        // Find day in dineInSettings
        var daySetting = vendorModel.value.dineInSettings!.daysSettings!.firstWhere(
          (d) => d.day == day,
          orElse: () => DineInDaySettings(day: day, isEnabled: false, timeSlots: []),
        );
        
        if (daySetting.isEnabled == true && daySetting.timeSlots != null && daySetting.timeSlots!.isNotEmpty) {
          // Find max discount in time slots for this day
          var maxDiscountSlot = daySetting.timeSlots!.reduce((item1, item2) {
            double disc1 = double.tryParse(item1.discount ?? "0") ?? 0;
            double disc2 = double.tryParse(item2.discount ?? "0") ?? 0;
            return disc1 > disc2 ? item1 : item2;
          });
          DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: maxDiscountSlot.discount ?? "0");
          dateList.add(model);
        } else {
          DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: vendorModel.value.dineInSettings!.defaultDiscount ?? "0");
          dateList.add(model);
        }
      } else if (vendorModel.value.specialDiscount?.isNotEmpty == true && vendorModel.value.specialDiscountEnable == true) {
        // Fallback to old specialDiscount system
        for (var element in vendorModel.value.specialDiscount!) {
          if (day == element.day.toString()) {
            if (element.timeslot!.isNotEmpty) {
              SpecialDiscountTimeslot employeeWithMaxSalary =
                  element.timeslot!.reduce((item1, item2) => double.parse(item1.discount.toString()) > double.parse(item2.discount.toString()) ? item1 : item2);
              if (employeeWithMaxSalary.discountType == "dinein") {
                DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: employeeWithMaxSalary.discount.toString());
                dateList.add(model);
              } else {
                DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: "0");
                dateList.add(model);
              }
            } else {
              DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: "0");
              dateList.add(model);
            }
          }
        }
      } else {
        DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: "0");
        dateList.add(model);
      }
    }
    selectedDate.value = dateList.first.date;

    timeSet(selectedDate.value);
    if (timeSlotList.isNotEmpty) {
      selectedTimeSlot.value = DateFormat('hh:mm a').format(timeSlotList[0].time!);
    }
  }

  timeSet(Timestamp selectedDate) {
    timeSlotList.clear();

    final now = DateTime.parse(selectedDate.toDate().toString());
    var day = DateFormat('EEEE').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);

    // Check if new dineInSettings exists and is enabled
    if (vendorModel.value.dineInSettings != null && 
        vendorModel.value.dineInSettings!.isEnabled == true &&
        vendorModel.value.dineInSettings!.daysSettings != null) {
      // Find day in dineInSettings
      var daySetting = vendorModel.value.dineInSettings!.daysSettings!.firstWhere(
        (d) => d.day == day,
        orElse: () => DineInDaySettings(day: day, isEnabled: false, timeSlots: []),
      );
      
      if (daySetting.isEnabled == true && daySetting.timeSlots != null && daySetting.timeSlots!.isNotEmpty) {
        // Use time slots from dineInSettings
        for (var timeSlot in daySetting.timeSlots!) {
          try {
            var start = DateFormat("dd-MM-yyyy hh:mm a").parse("$date ${timeSlot.from}");
            var end = DateFormat("dd-MM-yyyy hh:mm a").parse("$date ${timeSlot.to}");
            
            // Generate time slots every 30 minutes within the range
            for (DateTime time = start; time.isBefore(end) || time.isAtSameMomentAs(end); time = time.add(const Duration(minutes: 30))) {
              TimeModel model = TimeModel(
                time: time,
                discountPer: timeSlot.discount ?? vendorModel.value.dineInSettings!.defaultDiscount ?? "0",
                discountType: timeSlot.discountType ?? "percentage",
              );
              timeSlotList.add(model);
            }
          } catch (e) {
            print("Error parsing time slot: $e");
          }
        }
      } else {
        // Day not enabled, use default time range if available
        if (vendorModel.value.openDineTime != null && 
            vendorModel.value.closeDineTime != null &&
            vendorModel.value.openDineTime!.isNotEmpty &&
            vendorModel.value.closeDineTime!.isNotEmpty) {
          try {
            for (DateTime time = Constant.stringToDate(vendorModel.value.openDineTime.toString());
                time.isBefore(Constant.stringToDate(vendorModel.value.closeDineTime.toString()));
                time = time.add(const Duration(minutes: 30))) {
              TimeModel model = TimeModel(
                time: time,
                discountPer: vendorModel.value.dineInSettings?.defaultDiscount ?? "0",
                discountType: "percentage",
              );
              timeSlotList.add(model);
            }
          } catch (e) {
            print("Error parsing openDineTime/closeDineTime: $e");
            // Use default time slots if parsing fails
            for (int hour = 10; hour < 22; hour++) {
              for (int minute = 0; minute < 60; minute += 30) {
                TimeModel model = TimeModel(
                  time: DateTime(now.year, now.month, now.day, hour, minute),
                  discountPer: vendorModel.value.dineInSettings?.defaultDiscount ?? "0",
                  discountType: "percentage",
                );
                timeSlotList.add(model);
              }
            }
          }
        } else {
          // No time settings, use default time slots
          for (int hour = 10; hour < 22; hour++) {
            for (int minute = 0; minute < 60; minute += 30) {
              TimeModel model = TimeModel(
                time: DateTime(now.year, now.month, now.day, hour, minute),
                discountPer: vendorModel.value.dineInSettings?.defaultDiscount ?? "0",
                discountType: "percentage",
              );
              timeSlotList.add(model);
            }
          }
        }
      }
    } else if (vendorModel.value.openDineTime != null && 
               vendorModel.value.closeDineTime != null &&
               vendorModel.value.openDineTime!.isNotEmpty &&
               vendorModel.value.closeDineTime!.isNotEmpty) {
      // Fallback to old system with specialDiscount
      try {
        for (DateTime time = Constant.stringToDate(vendorModel.value.openDineTime.toString());
            time.isBefore(Constant.stringToDate(vendorModel.value.closeDineTime.toString()));
            time = time.add(const Duration(minutes: 30))) {
        if (vendorModel.value.specialDiscount?.isNotEmpty == true && vendorModel.value.specialDiscountEnable == true) {
          for (var element in vendorModel.value.specialDiscount!) {
            if (day == element.day.toString()) {
              if (element.timeslot!.isNotEmpty) {
                for (var element in element.timeslot!) {
                  if (element.discountType == "dinein") {
                    var start = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
                    var end = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
                    var selected = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${DateFormat.Hm().format(time)}");

                    if (isCurrentDateInRangeDineIn(start, end, selected)) {
                      var contains = timeSlotList.where((element) => element.time == time);
                      if (contains.isNotEmpty) {
                        var index = timeSlotList.indexWhere((element) => element.time == time);
                        if (timeSlotList[index].discountPer == "0") {
                          timeSlotList.removeAt(index);
                          TimeModel model = TimeModel(time: time, discountPer: element.discount, discountType: element.type);
                          timeSlotList.insert(index == 0 ? 0 : index, model);
                        }
                      } else {
                        TimeModel model = TimeModel(time: time, discountPer: element.discount, discountType: element.type);
                        timeSlotList.add(model);
                      }
                    } else {
                      var contains = timeSlotList.where((element) => element.time == time);
                      if (contains.isEmpty) {
                        TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
                        timeSlotList.add(model);
                      }
                    }
                  } else {
                    TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
                    timeSlotList.add(model);
                  }
                }
              } else {
                TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
                timeSlotList.add(model);
              }
            }
          }
        } else {
          TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
          timeSlotList.add(model);
        }
      }
      } catch (e) {
        print("Error parsing openDineTime/closeDineTime in fallback: $e");
        // Use default time slots if parsing fails
        final now = DateTime.parse(selectedDate.toDate().toString());
        for (int hour = 10; hour < 22; hour++) {
          for (int minute = 0; minute < 60; minute += 30) {
            TimeModel model = TimeModel(
              time: DateTime(now.year, now.month, now.day, hour, minute),
              discountPer: "0",
              discountType: "amount",
            );
            timeSlotList.add(model);
          }
        }
      }
    } else {
      // No time settings at all, use default time slots
      final now = DateTime.parse(selectedDate.toDate().toString());
      for (int hour = 10; hour < 22; hour++) {
        for (int minute = 0; minute < 60; minute += 30) {
          TimeModel model = TimeModel(
            time: DateTime(now.year, now.month, now.day, hour, minute),
            discountPer: "0",
            discountType: "amount",
          );
          timeSlotList.add(model);
        }
      }
    }
  }

  void animateSlider() {
    if (vendorModel.value.photos != null && vendorModel.value.photos!.isNotEmpty) {
      Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (currentPage < vendorModel.value.photos!.length) {
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
    }
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
    }
    animateSlider();
    statusCheck();
    isLoading.value = false;
    await getFavouriteList();

    update();
  }

  getFavouriteList() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }

    await FireStoreUtils.getVendorCuisines(vendorModel.value.id.toString()).then(
      (value) {
        tags.value = value;
      },
    );
    update();
  }

  RxBool isOpen = false.obs;

  statusCheck() {
    final now = DateTime.now();
    var day = DateFormat('EEEE', 'en_US').format(now);
    var date = DateFormat('dd-MM-yyyy').format(now);
    for (var element in vendorModel.value.workingHours!) {
      if (day == element.day.toString()) {
        if (element.timeslot!.isNotEmpty) {
          for (var element in element.timeslot!) {
            var start = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
            var end = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
            if (isCurrentDateInRange(start, end)) {
              isOpen.value = true;
            }
          }
        }
      }
    }
  }

  bool isCurrentDateInRangeDineIn(DateTime startDate, DateTime endDate, DateTime selected) {
    return selected.isAtSameMomentAs(startDate) || selected.isAtSameMomentAs(endDate) || selected.isAfter(startDate) && selected.isBefore(endDate);
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }
}

class DateModel {
  late Timestamp date;
  late String discountPer;

  DateModel({required this.date, required this.discountPer});
}

class TimeModel {
  DateTime? time;
  String? discountPer;
  String? discountType;

  TimeModel({required this.time, required this.discountPer, required this.discountType});
}
