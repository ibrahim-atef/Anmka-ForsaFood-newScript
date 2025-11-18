# Testing Guide: Email Verification Feature

## Pre-Testing Setup

### 1. Firebase Configuration
- ✅ Ensure Firebase is properly configured in the app
- ✅ Check that email/password authentication is enabled in Firebase Console
- ✅ Verify email templates are configured (optional, Firebase has defaults)

### 2. Test Email Account
- Use a real email address you can access (Gmail, Yahoo, etc.)
- Recommended: Create a dedicated test email like `forsafood.test@gmail.com`

### 3. Device/Emulator
- iOS Simulator, Android Emulator, or Physical Device
- Ensure internet connection is available

## Test Scenarios

### ✅ Scenario 1: New User Registration (Happy Path)

**Steps:**
1. Open the app
2. Navigate to Sign Up screen
3. Fill in registration form:
   - First Name: "Test"
   - Last Name: "User"
   - Email: "your-test-email@gmail.com"
   - Phone: "+1234567890"
   - Password: "Test123!"
   - Confirm Password: "Test123!"
4. Click "Sign Up" button

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Account is created
- ✅ Toast message: "Verification email sent! Please check your inbox"
- ✅ Redirected to Email Verification Screen
- ✅ Screen shows your email address
- ✅ Screen shows next steps
- ✅ Check email inbox - verification email received

**Pass/Fail:** [ ]

---

### ✅ Scenario 2: Resend Verification Email

**Steps:**
1. From Email Verification Screen
2. Click "Resend Verification Email" button
3. Wait and observe

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Toast message: "Verification email sent! Please check your inbox"
- ✅ Button becomes disabled
- ✅ Countdown timer shows "Resend in 60 seconds"
- ✅ Timer counts down (60, 59, 58...)
- ✅ After 60 seconds, button becomes active again
- ✅ New email received in inbox

**Pass/Fail:** [ ]

---

### ✅ Scenario 3: Email Verification Process

**Steps:**
1. Open your email inbox
2. Find "Verify your email for Forsa Feed" email
3. Click the verification link in email
4. Browser opens showing "Your email has been verified"
5. Return to the app
6. Click "I've Verified My Email" button

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Toast message: "Email verified successfully! Please login"
- ✅ User is signed out
- ✅ Redirected to Login screen

**Pass/Fail:** [ ]

---

### ✅ Scenario 4: Login - Unverified User (Negative Test)

**Steps:**
1. Register a new user (Scenario 1)
2. Click "Back to Login" without verifying
3. On Login screen, enter:
   - Email: (the unverified email)
   - Password: (the password you set)
4. Click "Login" button

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Authentication succeeds (credentials are correct)
- ✅ Toast message: "Please verify your email before logging in"
- ✅ User is signed out immediately
- ✅ Redirected to Email Verification Screen
- ✅ User CANNOT access the app

**Pass/Fail:** [ ]

---

### ✅ Scenario 5: Login - Verified User (Happy Path)

**Steps:**
1. Complete email verification (Scenario 3)
2. On Login screen, enter:
   - Email: (verified email)
   - Password: (your password)
3. Click "Login" button

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Authentication succeeds
- ✅ Email verification check passes
- ✅ User stays logged in
- ✅ Redirected to Location Permission Screen or Dashboard
- ✅ User CAN access the app

**Pass/Fail:** [ ]

---

### ✅ Scenario 6: Google Sign-In (Should Skip Verification)

**Steps:**
1. On Login screen, click "Sign in with Google"
2. Select Google account
3. Complete Google authentication

**Expected Results:**
- ✅ Google authentication succeeds
- ✅ No email verification prompt shown
- ✅ User can access the app immediately
- ✅ Email verification is NOT required (Google pre-verifies)

**Pass/Fail:** [ ]

---

### ✅ Scenario 7: Apple Sign-In (Should Skip Verification)

**Steps:**
1. On Login screen, click "Sign in with Apple"
2. Complete Apple authentication

**Expected Results:**
- ✅ Apple authentication succeeds
- ✅ No email verification prompt shown
- ✅ User can access the app immediately
- ✅ Email verification is NOT required (Apple pre-verifies)

**Pass/Fail:** [ ]

---

### ✅ Scenario 8: Check Verification Before Clicking Link

**Steps:**
1. Register new user
2. On Email Verification Screen
3. Do NOT click the email link yet
4. Click "I've Verified My Email" button

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Check is performed
- ✅ Toast message: "Email not verified yet. Please check your inbox"
- ✅ User stays on Email Verification Screen
- ✅ User is NOT signed out

**Pass/Fail:** [ ]

---

### ✅ Scenario 9: Multiple Resend Attempts (Rate Limiting)

**Steps:**
1. On Email Verification Screen
2. Click "Resend Verification Email"
3. Wait for countdown to reach 30 seconds (don't wait full 60)
4. Try clicking button again

**Expected Results:**
- ✅ Button is disabled during countdown
- ✅ Button cannot be clicked
- ✅ No additional email is sent
- ✅ Countdown continues normally
- ✅ After 60 seconds, button becomes active

**Pass/Fail:** [ ]

---

### ✅ Scenario 10: Network Error Handling

**Steps:**
1. On Email Verification Screen
2. Turn OFF wifi/mobile data
3. Click "Resend Verification Email"
4. Observe error handling
5. Turn ON wifi/mobile data
6. Try again

**Expected Results:**
- ✅ Loading indicator appears
- ✅ Error message shown (Firebase error)
- ✅ Button remains active (can retry)
- ✅ After reconnecting, resend works

**Pass/Fail:** [ ]

---

## Edge Cases

### 🔍 Test Case: Email Already Exists

**Steps:**
1. Register with email "test@example.com"
2. Sign out / go back to registration
3. Try to register again with same email

**Expected Result:**
- ✅ Error: "The account already exists for that email"

**Pass/Fail:** [ ]

---

### 🔍 Test Case: Weak Password

**Steps:**
1. Try to register with password "123"

**Expected Result:**
- ✅ Error: "Please enter minimum 6 characters password"

**Pass/Fail:** [ ]

---

### 🔍 Test Case: Invalid Email Format

**Steps:**
1. Try to register with email "notanemail"

**Expected Result:**
- ✅ Error: "Enter email is Invalid"

**Pass/Fail:** [ ]

---

### 🔍 Test Case: Back to Login from Verification Screen

**Steps:**
1. On Email Verification Screen
2. Click "Back to Login"

**Expected Result:**
- ✅ User is signed out
- ✅ Redirected to Login screen
- ✅ Can login with different account

**Pass/Fail:** [ ]

---

## Firebase Console Verification

### Check User Status
1. Go to Firebase Console
2. Navigate to Authentication > Users
3. Find your test user
4. Check "Email verified" column

**Before verification:** Should show empty or "No"
**After verification:** Should show checkmark or "Yes"

**Pass/Fail:** [ ]

---

## Performance Tests

### ⚡ Test: Email Send Time
- Verification email should arrive within 1-2 minutes
- If delayed, check Firebase quota/limits

**Average Time:** _____ seconds

---

### ⚡ Test: Verification Check Speed
- "I've Verified" button should respond within 1-3 seconds
- Network dependent

**Average Time:** _____ seconds

---

## Localization Tests

If your app supports multiple languages:

### 📱 Test: Arabic Language
1. Change app language to Arabic
2. Navigate to Email Verification Screen
3. Check all text is properly translated

**Pass/Fail:** [ ]

---

### 📱 Test: Other Languages
Repeat for each supported language

**Pass/Fail:** [ ]

---

## Test Results Summary

**Date:** _______________
**Tester:** _______________
**Device:** _______________
**OS Version:** _______________

### Pass/Fail Summary
- Total Tests: 14 scenarios + 4 edge cases + 2 performance = 20 tests
- Passed: _____
- Failed: _____
- Blocked: _____

### Issues Found
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Notes
_______________________________________________
_______________________________________________
_______________________________________________

---

## Troubleshooting Common Issues

### ❌ Issue: Email Not Received
**Solutions:**
- Check spam/junk folder
- Verify internet connection
- Wait 2-3 minutes (Firebase delay)
- Try resending
- Check Firebase Console > Authentication > Templates

### ❌ Issue: Verification Link Not Working
**Solutions:**
- Ensure clicking correct link
- Check if link expired (try new one)
- Try different browser
- Check Firebase Console for errors

### ❌ Issue: "I've Verified" Not Working
**Solutions:**
- Ensure verification link was clicked first
- Wait 30 seconds and try again
- Check internet connection
- Try signing out and back in

### ❌ Issue: App Crashes on Verification Screen
**Solutions:**
- Check logs for error details
- Verify all imports are correct
- Ensure Provider is properly set up
- Check Firebase initialization

---

## Automated Testing (Optional)

For developers who want to add automated tests:

```dart
// Example widget test
testWidgets('Email verification screen shows email', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: EmailVerificationScreen(email: 'test@example.com'),
    ),
  );
  
  expect(find.text('test@example.com'), findsOneWidget);
  expect(find.text('Verify Your Email'), findsOneWidget);
});
```

---

## Sign-Off

**Tested By:** _______________
**Date:** _______________
**Signature:** _______________

**Approved By:** _______________
**Date:** _______________
**Signature:** _______________

---

**Status:** [ ] Approved for Production / [ ] Needs Revision

**Notes:**
_______________________________________________
_______________________________________________

