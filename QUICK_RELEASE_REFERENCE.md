# 🚀 Quick Release Reference Card

## 📦 Your App Bundle

**File Location:**
```
build/app/outputs/bundle/release/app-release.aab
```

**This is the file you upload to Google Play Store!**

---

## 🔑 Your Credentials

```
Store Password: forsafood2025
Key Password:   forsafood2025
Key Alias:      forsafood-key-alias
Keystore File:  android/forsafood-release-key.jks
```

⚠️ **KEEP THESE SAFE! Never lose the keystore!**

---

## ⚡ Quick Commands

### Build App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

### Build APK (for testing):
```bash
flutter build apk --release
```

### Clean Build:
```bash
flutter clean
flutter build appbundle --release
```

---

## 📤 Upload to Play Store

1. Go to: https://play.google.com/console
2. Select your app
3. Go to Release → Production
4. Click "Create new release"
5. Upload: `build/app/outputs/bundle/release/app-release.aab`
6. Fill release notes
7. Click "Start rollout"

---

## 🔄 Update App Version

**Edit** `pubspec.yaml`:
```yaml
version: 1.0.1+2  # Format: version+buildNumber
```

Then rebuild:
```bash
flutter build appbundle --release
```

---

## 💾 CRITICAL: Backup These Files!

1. **android/forsafood-release-key.jks** ← Your keystore
2. **android/key.properties** ← Your credentials

**Make 3 copies:**
- Cloud storage (encrypted)
- External hard drive  
- USB drive (safe location)

**Without keystore = Cannot update app!**

---

## 🚫 Security Checklist

- [ ] Keystore backed up in 3 locations
- [ ] Passwords stored in password manager
- [ ] `key.properties` NOT in Git
- [ ] `.jks` files NOT in Git
- [ ] Only authorized team members have access

---

## 📊 Build Output Locations

```
App Bundle:  build/app/outputs/bundle/release/app-release.aab
APK:         build/app/outputs/apk/release/app-release.apk
```

---

## 🔍 Verify Files Exist

```bash
# Check keystore
dir android\forsafood-release-key.jks

# Check credentials file
dir android\key.properties

# Check app bundle (after build)
dir build\app\outputs\bundle\release\app-release.aab
```

---

## 🐛 Quick Fixes

**Build fails?**
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

**Keystore error?**
- Check `android/key.properties` exists
- Verify passwords are correct
- Ensure keystore file is in `android/` folder

---

## 📱 App Details

- **Package:** com.anmka.forsaaap
- **Min SDK:** 23 (Android 6.0)
- **Target SDK:** 34 (Android 14)

---

## 🎯 Remember

✅ **Always use the SAME keystore** for updates
✅ **Increment version** before each release
✅ **Test thoroughly** before uploading
✅ **Keep backups** of keystore
✅ **Never lose** the keystore file

---

**Status:** ✅ Ready for Release
**Next Step:** Upload app-release.aab to Play Store

