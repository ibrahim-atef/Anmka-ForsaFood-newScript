# 📦 دليل بناء App Bundle - Forsa Food

## ✅ ما تم إعداده

### 1. **Keystore**
✅ **الموجود:** `android/forsafood-release-key.jks`
- **Alias:** forsafood-key-alias
- **Store Password:** forsafood2025
- **Key Password:** forsafood2025
- **Validity:** حتى 2053

### 2. **Key Properties**
✅ **الموجود:** `android/key.properties`
- تم إعداده بشكل صحيح

### 3. **Build Configuration**
✅ **الموجود:** `android/app/build.gradle`
- تم إعداده بشكل صحيح

---

## 🔧 حل مشكلة Gradle Build

إذا ظهرت رسالة خطأ `Could not connect to Kotlin compile daemon`، جرب الحلول التالية:

### الحل 1: تنظيف Gradle Cache
```powershell
# إيقاف Gradle daemon
cd android
.\gradlew --stop

# تنظيف cache
Remove-Item -Recurse -Force "$env:USERPROFILE\.gradle\caches\transforms-4"

# تنظيف المشروع
cd ..
flutter clean
flutter pub get
```

### الحل 2: إعادة تشغيل الجهاز
أحياناً يحتاج Gradle daemon لإعادة تشغيل الجهاز لحل مشكلة الاتصال.

### الحل 3: استخدام Android Studio
1. افتح المشروع في Android Studio
2. اذهب إلى **Build** → **Generate Signed Bundle / APK**
3. اختر **Android App Bundle**
4. اختر **release** build variant
5. اتبع الخطوات لإتمام البناء

### الحل 4: البناء يدوياً من Android Studio Terminal
```bash
# في Android Studio Terminal
cd android
./gradlew clean
./gradlew bundleRelease
```

---

## 📱 بناء App Bundle

### الطريقة الموصى بها:

#### **الخطوة 1: تنظيف المشروع**
```bash
flutter clean
flutter pub get
```

#### **الخطوة 2: التحقق من Keystore**
```bash
cd android
keytool -list -v -keystore forsafood-release-key.jks -storepass forsafood2025
```

#### **الخطوة 3: بناء App Bundle**
```bash
cd ..
flutter build appbundle --release
```

#### **الخطوة 4: التحقق من الملف**
بعد البناء الناجح، ستجد الملف في:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 📝 معلومات التطبيق

### **إعدادات التطبيق:**
- **Package Name:** com.anmka.forsafeedaap
- **Version:** 1.0.1
- **Version Code:** 2
- **Min SDK:** 23 (Android 6.0)
- **Target SDK:** 35 (Android 14+)
- **Compile SDK:** 35

### **Keystore Info:**
- **File:** `android/forsafood-release-key.jks`
- **Alias:** forsafood-key-alias
- **Passwords:** forsafood2025 (store & key)

---

## 📤 رفع App Bundle إلى Google Play

### **الخطوات:**

1. **اذهب إلى Google Play Console**
   - https://play.google.com/console

2. **اختر التطبيق**
   - أو أنشئ تطبيق جديد

3. **انتقل إلى Production**
   - Release → Production → Create new release

4. **ارفع App Bundle**
   - اضغط على "Upload" 
   - اختر الملف: `build/app/outputs/bundle/release/app-release.aab`

5. **املأ Release Notes**
   - استخدم النص من `GOOGLE_PLAY_STORE_DESCRIPTION.md`

6. **Review & Rollout**
   - راجع كل شيء
   - اضغط "Start rollout to Production"

---

## 📄 ملفات الوصف

تم إنشاء ملف وصف كامل للتطبيق:
- **`GOOGLE_PLAY_STORE_DESCRIPTION.md`** - يحتوي على:
  - Short Description
  - Full Description (English & Arabic)
  - Release Notes
  - Keywords
  - Checklist

---

## ⚠️ ملاحظات مهمة

### **1. Keystore Security**
- ⚠️ **لا تفقد الـ keystore أبداً!**
- احتفظ بنسخ احتياطية في أماكن آمنة
- إذا فقدته، لن تتمكن من تحديث التطبيق على Google Play

### **2. Version Management**
قبل كل تحديث جديد، عدّل `pubspec.yaml`:
```yaml
version: 1.0.2+3  # 1.0.2 = versionName, +3 = versionCode
```

### **3. Testing**
قبل رفع التطبيق:
- ✅ اختبر كل الميزات
- ✅ تأكد من عمل Firebase
- ✅ تأكد من عمل المدفوعات
- ✅ اختبر على أجهزة مختلفة

---

## 🆘 استكشاف الأخطاء

### **Error: "keystore not found"**
```bash
# تحقق من وجود الملف
dir android\forsafood-release-key.jks

# إذا لم يكن موجوداً، أنشئ واحداً جديداً
cd android
keytool -genkey -v -keystore forsafood-release-key.jks -alias forsafood-key-alias -keyalg RSA -keysize 2048 -validity 10000 -storepass forsafood2025 -keypass forsafood2025
```

### **Error: "wrong password"**
- تحقق من كلمة المرور في `android/key.properties`
- تأكد أنها `forsafood2025`

### **Error: "Kotlin compile daemon"**
- جرب الحلول في قسم "حل مشكلة Gradle Build"
- أو استخدم Android Studio لبناء التطبيق

---

## ✅ Checklist قبل النشر

- [ ] Keystore موجود وآمن
- [ ] Version number محدث في `pubspec.yaml`
- [ ] التطبيق تم اختباره بشكل كامل
- [ ] App Bundle تم بناؤه بنجاح
- [ ] Screenshots جاهزة (1080x1920)
- [ ] Feature Graphic جاهز (1024x500)
- [ ] App Icon جاهز (512x512)
- [ ] Privacy Policy URL جاهز
- [ ] Content Rating Questionnaire مكتمل
- [ ] Store Listing Description جاهز
- [ ] Release Notes جاهزة

---

## 📞 الدعم

إذا واجهت مشاكل في البناء:
1. جرب استخدام Android Studio
2. تحقق من إصدار Flutter: `flutter --version`
3. تحقق من إصدار Java: `java -version` (يجب أن يكون 17+)
4. نظف المشروع وابنيه مرة أخرى

---

**آخر تحديث:** January 2025
**Status:** ✅ Keystore جاهز | ✅ Configuration جاهز | ⚠️ Build يحتاج حل مشكلة Gradle



