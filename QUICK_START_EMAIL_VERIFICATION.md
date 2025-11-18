# Quick Start: Email Verification

## How It Works (Simple Version)

### For New Users (Registration)
1. User signs up with email/password
2. ✉️ Verification email sent automatically
3. 📱 User sees verification screen
4. User checks email and clicks link
5. ✅ User returns and confirms verification
6. 🚀 User can now login

### For Existing Unverified Users (Login)
1. User tries to login
2. ❌ Login blocked - email not verified
3. 📱 Redirected to verification screen
4. User can resend verification email
5. User verifies email
6. ✅ User can now login

## Code Examples

### Check if User is Verified
```dart
final authService = AuthService();
bool isVerified = authService.isEmailVerified();
```

### Send Verification Email
```dart
final authService = AuthService();
try {
  await authService.sendEmailVerification();
  print('Email sent!');
} catch (e) {
  print('Error: $e');
}
```

### Check if Verification is Required
```dart
final authService = AuthService();
bool needsVerification = authService.requiresEmailVerification();
// Returns true only for email/password users who haven't verified
```

### Reload User Data
```dart
final authService = AuthService();
bool isVerified = await authService.reloadUser();
// Reloads user and returns verification status
```

## Important Notes

### ✅ DO
- Let the system handle verification automatically
- Use the verification screen UI provided
- Test with real email addresses
- Check spam folders during testing

### ❌ DON'T
- Don't modify Firebase Auth rules without testing
- Don't skip verification for production users
- Don't remove the resend cooldown (prevents spam)
- Don't allow unverified users to access sensitive data

## Testing

### Test with Real Email
```dart
// Use a real email you can access
emailEditingController.value.text = 'your-real-email@gmail.com';
```

### Check Firebase Console
1. Go to Firebase Console
2. Navigate to Authentication > Users
3. Look for "Email verified" column
4. Should show checkmark after verification

## Common Scenarios

### User Says: "I didn't receive the email"
**Solution:** Click "Resend Verification Email" button

### User Says: "The link expired"
**Solution:** Click "Resend Verification Email" to get a new link

### User Says: "I verified but still can't login"
**Solution:** 
1. Click "I've Verified My Email" button
2. If that doesn't work, try logging in again
3. Firebase sometimes needs a moment to sync

## For Developers

### To Disable Verification (Testing Only)
**⚠️ WARNING: Only for development/testing!**

In `login_controller.dart`, comment out these lines:
```dart
// if (authService.requiresEmailVerification()) {
//   ShowToastDialog.closeLoader();
//   await FirebaseAuth.instance.signOut();
//   ShowToastDialog.showToast("Please verify your email before logging in.".tr);
//   Get.off(() => EmailVerificationScreen(
//     email: emailEditingController.value.text.trim(),
//   ));
//   return;
// }
```

**Remember to uncomment for production!**

### To Customize Verification Email
1. Go to Firebase Console
2. Authentication > Templates
3. Edit "Email address verification" template
4. Customize subject, body, sender name

### To Add More Languages
1. Open `lib/lang/` directory
2. Add translations for these keys:
   - "Verify Your Email"
   - "Please verify your email before logging in"
   - "Verification email sent! Please check your inbox"
   - "Resend Verification Email"
   - "I've Verified My Email"
   - All other strings with `.tr`

## File Locations

```
lib/
├── services/
│   └── auth_service.dart              # Core verification logic
├── app/
│   └── auth_screen/
│       └── email_verification_screen.dart  # Verification UI
├── controllers/
│   ├── signup_controller.dart         # Modified for signup
│   └── login_controller.dart          # Modified for login
```

## Quick Commands

### Run the app
```bash
flutter run
```

### Check for errors
```bash
flutter analyze
```

### Clear cache (if issues)
```bash
flutter clean
flutter pub get
```

## Support

If you have questions:
1. Check `EMAIL_VERIFICATION_IMPLEMENTATION.md` for detailed docs
2. Review the code comments in `auth_service.dart`
3. Test with the flows described above
4. Check Firebase Console for user status

---

**Happy Coding! 🚀**

