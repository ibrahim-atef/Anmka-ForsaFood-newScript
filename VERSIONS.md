# إصدارات المشروع - Project Versions

## 📱 Anmka-ForsaFood-newScript (تطبيق العميل)

### Flutter & Dart
- **Flutter Version:** `3.24.3` (من .fvmrc)
- **Dart Version:** `3.5.3` (مقدر)

### Java
- **Java Version:** `17` (JavaVersion.VERSION_17)
- **Source Compatibility:** `JavaVersion.VERSION_17`
- **Target Compatibility:** `JavaVersion.VERSION_17`

### Kotlin
- **Kotlin Version:** `1.9.10`
- **Kotlin Gradle Plugin:** `1.9.10`
- **Kotlin JVM Target:** `17`

### Android Gradle Plugin (AGP)
- **AGP Version:** `8.1.1` (في buildscript)
- **AGP Version:** `8.2.1` (في settings.gradle)

### Gradle
- **Gradle Version:** `8.2.1` (من gradle-wrapper.properties)

### Android SDK
- **compileSdk:** `35`
- **targetSdk:** `35`
- **minSdk:** `23`
- **NDK Version:** `25.1.8937393`

### Google Services
- **Google Services Plugin:** `4.4.2`
- **Firebase BOM:** `33.13.0`

### Other Dependencies
- **Desugar JDK Libs:** `2.0.3`
- **MultiDex:** `2.0.1`

---

## 📋 ملخص الإصدارات - Versions Summary

### متطلبات مشتركة - Common Requirements:
- ✅ **Flutter:** `3.24.3`
- ✅ **Dart:** `3.5.3`
- ✅ **Java:** `17` (JDK 17)
- ✅ **Kotlin:** `1.9.10`
- ✅ **Android Gradle Plugin:** `8.2.1`
- ✅ **Gradle:** `8.2.1`
- ✅ **compileSdk:** `35`
- ✅ **Google Services:** `4.4.2`

---

## 🛠️ خطوات الإعداد - Setup Instructions

### 1. تثبيت Flutter
```bash
# استخدام FVM لتثبيت Flutter 3.24.3
fvm install 3.24.3
fvm use 3.24.3
```

### 2. تثبيت Java JDK 17
- تحميل وتثبيت JDK 17 من Oracle أو OpenJDK
- تعيين `JAVA_HOME` إلى مسار JDK 17

### 3. تثبيت Android Studio
- Android Studio Hedgehog أو أحدث
- Android SDK Platform 35
- Android SDK Build-Tools 35.x.x
- NDK 25.1.8937393

### 4. التحقق من الإصدارات
```bash
# التحقق من Flutter
flutter --version

# التحقق من Java
java -version

# التحقق من Gradle
cd android
./gradlew --version
```

---

## ⚠️ ملاحظات مهمة - Important Notes

1. **Java 17 مطلوب** - لا تستخدم Java 8 أو Java 11
2. **Kotlin 1.9.10** - يجب أن يكون هذا الإصدار بالضبط لتجنب مشاكل التوافق
3. **Gradle 8.2.1** - للمشروع Client
4. **compileSdk 35** - مطلوب
5. **NDK Version 25.1.8937393** - تأكد من تثبيت هذا الإصدار

---

## 📝 ملفات الإعداد - Configuration Files

- `android/build.gradle` - Kotlin 1.9.10, AGP 8.1.1
- `android/settings.gradle` - AGP 8.2.1, Kotlin 1.9.10
- `android/gradle/wrapper/gradle-wrapper.properties` - Gradle 8.2.1
- `android/app/build.gradle` - Java 17, compileSdk 35
- `.fvmrc` - Flutter 3.24.3

---

**تاريخ الإنشاء:** 2025-01-27
**آخر تحديث:** 2025-01-27

