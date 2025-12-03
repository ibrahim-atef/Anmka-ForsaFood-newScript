class DineInSettingsModel {
  bool? isEnabled;
  List<DineInDaySettings>? daysSettings;
  int? minGuests;
  int? maxGuests;
  String? defaultDiscount;

  DineInSettingsModel({
    this.isEnabled,
    this.daysSettings,
    this.minGuests,
    this.maxGuests,
    this.defaultDiscount,
  });

  DineInSettingsModel.fromJson(Map<String, dynamic> json) {
    isEnabled = json['isEnabled'] ?? false;
    minGuests = json['minGuests'] ?? 1;
    maxGuests = json['maxGuests'] ?? 20;
    defaultDiscount = json['defaultDiscount'] ?? "0";
    
    if (json['daysSettings'] != null) {
      daysSettings = <DineInDaySettings>[];
      json['daysSettings'].forEach((v) {
        daysSettings!.add(DineInDaySettings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isEnabled'] = isEnabled;
    data['minGuests'] = minGuests;
    data['maxGuests'] = maxGuests;
    data['defaultDiscount'] = defaultDiscount;
    if (daysSettings != null) {
      data['daysSettings'] = daysSettings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DineInDaySettings {
  String? day; // Monday, Tuesday, etc.
  bool? isEnabled;
  List<DineInTimeSlot>? timeSlots;

  DineInDaySettings({
    this.day,
    this.isEnabled,
    this.timeSlots,
  });

  DineInDaySettings.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    isEnabled = json['isEnabled'] ?? false;
    if (json['timeSlots'] != null) {
      timeSlots = <DineInTimeSlot>[];
      json['timeSlots'].forEach((v) {
        timeSlots!.add(DineInTimeSlot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['isEnabled'] = isEnabled;
    if (timeSlots != null) {
      data['timeSlots'] = timeSlots!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DineInTimeSlot {
  String? from; // e.g., "10:00 AM"
  String? to; // e.g., "11:00 PM"
  String? discount; // e.g., "10" for 10%
  String? discountType; // "percentage" or "amount"
  int? minGuests; // Minimum guests for this slot
  int? maxGuests; // Maximum guests for this slot

  DineInTimeSlot({
    this.from,
    this.to,
    this.discount,
    this.discountType,
    this.minGuests,
    this.maxGuests,
  });

  DineInTimeSlot.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    discount = json['discount'] ?? "0";
    discountType = json['discountType'] ?? "percentage";
    minGuests = json['minGuests'];
    maxGuests = json['maxGuests'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = from;
    data['to'] = to;
    data['discount'] = discount;
    data['discountType'] = discountType;
    data['minGuests'] = minGuests;
    data['maxGuests'] = maxGuests;
    return data;
  }
}


