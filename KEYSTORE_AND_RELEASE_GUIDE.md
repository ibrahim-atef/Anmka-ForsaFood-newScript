# 🔐 Keystore & App Bundle Release Guide

## ✅ What Was Created

### 1. **Keystore File** 
**Location:** `android/forsafood-release-key.jks`

This is your **digital signature** for the app. Keep it safe!

**Details:**
- **Alias:** forsafood-key-alias
- **Key Algorithm:** RSA
- **Key Size:** 2048 bits
- **Validity:** 10,000 days (~27 years)
- **Store Password:** forsafood2025
- **Key Password:** forsafood2025

### 2. **Key Properties File**
**Location:** `android/key.properties`

Contains keystore credentials (DO NOT commit to Git!)

```properties
storePassword=forsafood2025
keyPassword=forsafood2025
keyAlias=forsafood-key-alias
storeFile=forsafood-release-key.jks
```

### 3. **Signed App Bundle**
**Location:** `build/app/outputs/bundle/release/app-release.aab`

This is the file you upload to Google Play Store!

---

## 🚀 How to Build App Bundle

### **Command:**
```bash
flutter build appbundle --release
```

### **What Happens:**
1. Flutter compiles your app in release mode
2. Gradle signs the bundle with your keystore
3. Creates optimized `.aab` file for Play Store

### **Build Output:**
```
✓ Built build/app/outputs/bundle/release/app-release.aab (XX.XMB)
```

---

## 📦 App Bundle Location

After successful build, find your app bundle at:

```
build/app/outputs/bundle/release/app-release.aab
```

---

## 🔒 CRITICAL: Keep These Files Safe!

### ⚠️ **NEVER Lose These Files:**

1. **`android/forsafood-release-key.jks`** - Your keystore
2. **`android/key.properties`** - Your credentials

### 📝 **Why?**
- Google Play requires the SAME keystore for ALL updates
- If you lose the keystore, you CANNOT update your app
- You'll have to publish a NEW app with a different package name

### 💾 **Backup Strategy:**

1. **Copy to secure location:**
   ```
   Copy forsafood-release-key.jks to:
   - External hard drive
   - Cloud storage (encrypted)
   - USB drive (keep in safe place)
   ```

2. **Document credentials:**
   ```
   Store password in:
   - Password manager (1Password, LastPass, etc.)
   - Encrypted document
   - Company vault
   ```

3. **Multiple backups:**
   - Keep at least 3 copies in different locations
   - Never store ALL copies in the same place

---

## 🚫 Git Security

### **Add to .gitignore:**

Make sure these are in your `.gitignore`:

```gitignore
# Keystore files
*.jks
*.keystore
key.properties

# Build outputs
build/
*.aab
*.apk
```

### **Check if accidentally committed:**
```bash
git status
```

If you see `key.properties` or `.jks` files, DO NOT commit them!

---

## 📤 Upload to Google Play Store

### **Step-by-Step:**

1. **Go to Google Play Console**
   - https://play.google.com/console

2. **Navigate to your app**
   - Select "Forsa Food" app

3. **Create a new release**
   - Go to "Release" → "Production" or "Testing"
   - Click "Create new release"

4. **Upload the app bundle**
   - Click "Upload"
   - Select: `build/app/outputs/bundle/release/app-release.aab`

5. **Fill in release details**
   - Release name (e.g., "Version 1.0.0")
   - Release notes (what's new)

6. **Review and rollout**
   - Review everything
   - Click "Start rollout to production"

---

## 🔄 For Future Updates

### **When updating the app:**

1. **Update version in pubspec.yaml:**
   ```yaml
   version: 1.0.1+2  # Increment version number
   ```

2. **Build new app bundle:**
   ```bash
   flutter build appbundle --release
   ```

3. **Upload to Play Store**
   - Same process as initial release
   - Google will verify it's signed with the same key

---

## 🛠️ Build Commands Reference

### **Build App Bundle (Release):**
```bash
flutter build appbundle --release
```

### **Build APK (For testing):**
```bash
flutter build apk --release
```

### **Build APK (Debug):**
```bash
flutter build apk --debug
```

### **Clean build:**
```bash
flutter clean
flutter build appbundle --release
```

---

## 📊 App Bundle vs APK

| Feature | App Bundle (.aab) | APK (.apk) |
|---------|-------------------|------------|
| **For** | Google Play Store | Direct installation |
| **Size** | Optimized per device | One size for all |
| **Required** | Yes (for Play Store) | No |
| **Recommended** | ✅ Yes | Only for testing |

---

## 🔍 Verify Signing Configuration

### **Check if properly configured:**

1. **Check key.properties exists:**
   ```bash
   dir android\key.properties
   ```

2. **Check keystore exists:**
   ```bash
   dir android\forsafood-release-key.jks
   ```

3. **Verify signing in build.gradle:**
   - Open `android/app/build.gradle`
   - Look for `signingConfigs { release { ... } }`

---

## ⚙️ Your Current Configuration

### **App Details:**
- **Package Name:** com.anmka.forsaaap
- **Min SDK:** 23 (Android 6.0)
- **Target SDK:** 34 (Android 14)
- **Compile SDK:** 34

### **Signing Configuration:**
- **Keystore:** forsafood-release-key.jks
- **Alias:** forsafood-key-alias
- **Location:** android/forsafood-release-key.jks

### **Build Output:**
- **App Bundle:** build/app/outputs/bundle/release/app-release.aab
- **APK (if built):** build/app/outputs/apk/release/app-release.apk

---

## 🐛 Troubleshooting

### **Error: "keystore not found"**
**Solution:**
```bash
# Check if keystore exists
dir android\forsafood-release-key.jks

# If missing, recreate it:
cd android
keytool -genkey -v -keystore forsafood-release-key.jks ...
```

### **Error: "key.properties not found"**
**Solution:**
- Make sure `android/key.properties` exists
- Check file path in build.gradle

### **Error: "wrong password"**
**Solution:**
- Verify passwords in `key.properties` match keystore
- Default: forsafood2025

### **Build fails**
**Solution:**
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## 📝 Keystore Information

### **View keystore details:**
```bash
cd android
keytool -list -v -keystore forsafood-release-key.jks -storepass forsafood2025
```

### **Change keystore password (if needed):**
```bash
keytool -storepasswd -keystore forsafood-release-key.jks
```

### **Change key password (if needed):**
```bash
keytool -keypasswd -alias forsafood-key-alias -keystore forsafood-release-key.jks
```

---

## 📱 Testing Before Release

### **Test the release build:**

1. **Build release APK:**
   ```bash
   flutter build apk --release
   ```

2. **Install on device:**
   ```bash
   flutter install
   ```

3. **Test thoroughly:**
   - All features work
   - No crashes
   - Performance is good

---

## ✅ Pre-Release Checklist

Before uploading to Play Store:

- [ ] App version updated in pubspec.yaml
- [ ] All features tested
- [ ] Firebase configuration correct
- [ ] Permissions properly configured
- [ ] App icons updated
- [ ] Splash screen configured
- [ ] Release notes written
- [ ] Screenshots prepared
- [ ] Privacy policy updated
- [ ] Terms of service updated

---

## 🎯 Quick Reference

### **Build Commands:**
```bash
# Clean and build
flutter clean
flutter build appbundle --release

# APK for testing
flutter build apk --release

# Check version
flutter --version
```

### **File Locations:**
```
Keystore:    android/forsafood-release-key.jks
Properties:  android/key.properties
App Bundle:  build/app/outputs/bundle/release/app-release.aab
APK:         build/app/outputs/apk/release/app-release.apk
```

### **Passwords:**
```
Store Password: forsafood2025
Key Password:   forsafood2025
Key Alias:      forsafood-key-alias
```

---

## 🔐 Security Best Practices

1. **Never share passwords publicly**
2. **Don't commit keystore to Git**
3. **Keep multiple backups**
4. **Use password manager**
5. **Limit access to keystore**
6. **Document recovery process**
7. **Test restore from backup**

---

## 📞 Support

### **If you lose the keystore:**
- **Option 1:** Restore from backup (recommended)
- **Option 2:** Create new app with different package name
- **Option 3:** Contact Google Play support (limited options)

### **For build issues:**
1. Check Flutter version: `flutter --version`
2. Clean project: `flutter clean`
3. Update dependencies: `flutter pub get`
4. Rebuild: `flutter build appbundle --release`

---

## 🎉 Congratulations!

You now have:
- ✅ Secure keystore for signing
- ✅ Configured build system
- ✅ Signed app bundle ready for Play Store
- ✅ Complete documentation

**Ready to upload to Google Play Store!** 🚀

---

**Created:** October 21, 2025
**Keystore:** forsafood-release-key.jks
**Validity:** 10,000 days
**Next Steps:** Upload app-release.aab to Play Store

