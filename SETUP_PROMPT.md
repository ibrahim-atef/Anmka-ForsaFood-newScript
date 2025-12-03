# Setup Prompt for AI Agent - Flutter Food Delivery App

You are tasked with setting up the development environment and running a Flutter food delivery application. Follow these instructions precisely.

## Project Overview
This is a Flutter food delivery application with two apps:
1. **Anmka-ForsaFood-newScript** (Customer App) - Current project
2. **Anmka-ForsaFood-Restaurant-main** (Restaurant App) - Related project

## Required Versions (MUST MATCH EXACTLY)

### Common Versions (Both Projects)
- **Flutter**: 3.24.3
- **Dart**: 3.5.3
- **Java JDK**: 17 (JavaVersion.VERSION_17)
- **Kotlin**: 1.9.10
- **Android Gradle Plugin (AGP)**: 8.2.1 (in settings.gradle)
- **AGP Build**: 8.1.1 (in build.gradle)
- **Google Services Plugin**: 4.4.2
- **compileSdk**: 35

### Customer App (Anmka-ForsaFood-newScript) - CURRENT PROJECT
- **Gradle**: 8.2.1
- **targetSdk**: 35
- **minSdk**: 23
- **NDK**: 25.1.8937393
- **Firebase BOM**: 33.13.0
- **Desugar**: 2.0.3
- **MultiDex**: 2.0.1

### Restaurant App (Anmka-ForsaFood-Restaurant-main)
- **Gradle**: 8.7
- **targetSdk**: 34
- **minSdk**: 24
- **NDK**: 26.1.10909125
- **Firebase BOM**: 33.2.0
- **Desugar**: 2.1.2

## Setup Steps

### Step 1: Verify and Install Flutter SDK 3.24.3
```bash
# Check current Flutter version
flutter --version

# If not 3.24.3, install it using FVM (recommended) or download directly
# Option A: Using FVM
dart pub global activate fvm
fvm install 3.24.3
fvm use 3.24.3
fvm flutter --version

# Option B: Direct installation
# Download from: https://docs.flutter.dev/get-started/install
# Extract and add to PATH
```

### Step 2: Verify and Install Java JDK 17
```bash
# Check Java version (MUST be 17, NOT 8, 11, or 21)
java -version

# If not version 17, install it:
# Windows: Download from https://adoptium.net/temurin/releases/?version=17
# macOS: brew install openjdk@17
# Linux: sudo apt install openjdk-17-jdk

# Set JAVA_HOME environment variable
# Windows: setx JAVA_HOME "C:\Program Files\Java\jdk-17"
# macOS/Linux: export JAVA_HOME=/path/to/jdk-17
```

### Step 3: Verify and Setup Android SDK
```bash
# Check if Android SDK is installed
# Usually located at:
# Windows: %LOCALAPPDATA%\Android\Sdk
# macOS: ~/Library/Android/sdk
# Linux: ~/Android/Sdk

# Set ANDROID_HOME environment variable
# Windows: setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk"
# macOS/Linux: export ANDROID_HOME=~/Library/Android/sdk

# Install required SDK components via Android Studio SDK Manager:
# - Android SDK Platform 35
# - Android SDK Build-Tools 35.x.x
# - NDK 25.1.8937393 (for Customer App) or 26.1.10909125 (for Restaurant App)
```

### Step 4: Navigate to Project Directory
```bash
cd e:\anmka_apps\Anmka-ForsaFood-newScript
```

### Step 5: Verify Project Configuration Files

#### Check `android/settings.gradle`:
```gradle
// Should contain:
android {
    compileSdkVersion 35
    // ...
}

// AGP should be 8.2.1
```

#### Check `android/build.gradle`:
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.1'
        classpath 'com.google.gms:google-services:4.4.2'
    }
}

// Ensure Gradle wrapper version is 8.2.1
// Check android/gradle/wrapper/gradle-wrapper.properties:
// distributionUrl should contain gradle-8.2.1-all.zip
```

#### Check `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 35
    defaultConfig {
        minSdkVersion 23
        targetSdkVersion 35
        // ...
        ndkVersion "25.1.8937393"
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:33.13.0')
    implementation 'androidx.multidex:multidex:2.0.1'
    // ...
}
```

### Step 6: Clean and Prepare Project
```bash
# Clean Flutter project
flutter clean

# Get Flutter dependencies
flutter pub get

# Navigate to Android directory
cd android

# Clean Gradle
./gradlew clean
# Windows: gradlew.bat clean

# Verify Gradle version
./gradlew --version
# Should show Gradle 8.2.1

# Return to project root
cd ..
```

### Step 7: Check and Fix Version Mismatches

If you encounter version errors, update the following files:

#### Update `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2.1-all.zip
```

#### Update `android/build.gradle` if needed:
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.1'
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

#### Update `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 35
    ndkVersion "25.1.8937393"
    
    defaultConfig {
        minSdkVersion 23
        targetSdkVersion 35
        multiDexEnabled true
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:33.13.0')
    implementation 'androidx.multidex:multidex:2.0.1'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3'
}
```

### Step 8: Verify Environment Variables
```bash
# Windows (PowerShell)
echo $env:JAVA_HOME
echo $env:ANDROID_HOME
echo $env:PATH

# macOS/Linux
echo $JAVA_HOME
echo $ANDROID_HOME
echo $PATH

# Ensure:
# - JAVA_HOME points to JDK 17
# - ANDROID_HOME points to Android SDK
# - Both are in PATH
```

### Step 9: Check Connected Devices
```bash
# List connected devices/emulators
flutter devices

# If no devices, start an emulator or connect a physical device
# For emulator:
# android avd
# Or start from Android Studio: Tools > Device Manager
```

### Step 10: Run the Application
```bash
# From project root (e:\anmka_apps\Anmka-ForsaFood-newScript)
flutter run

# Or run on specific device
flutter run -d <device-id>

# For release mode
flutter run --release
```

## Troubleshooting Common Issues

### Issue 1: "Java version mismatch"
**Solution**: Ensure Java 17 is installed and JAVA_HOME points to it.
```bash
java -version  # Should show version 17
```

### Issue 2: "Gradle version mismatch"
**Solution**: Update gradle-wrapper.properties to use Gradle 8.2.1

### Issue 3: "NDK version not found"
**Solution**: Install correct NDK version via Android Studio SDK Manager:
- For Customer App: NDK 25.1.8937393
- For Restaurant App: NDK 26.1.10909125

### Issue 4: "compileSdk 35 not found"
**Solution**: Install Android SDK Platform 35 via Android Studio SDK Manager

### Issue 5: "Kotlin version mismatch"
**Solution**: Ensure `android/build.gradle` has `ext.kotlin_version = '1.9.10'`

### Issue 6: "Firebase dependencies error"
**Solution**: Ensure Firebase BOM version matches:
- Customer App: 33.13.0
- Restaurant App: 33.2.0

## Verification Checklist

Before running the app, verify:
- [ ] Flutter version is 3.24.3
- [ ] Dart version is 3.5.3
- [ ] Java version is 17
- [ ] JAVA_HOME is set to JDK 17
- [ ] ANDROID_HOME is set correctly
- [ ] Gradle version is 8.2.1 (Customer App) or 8.7 (Restaurant App)
- [ ] compileSdk is 35
- [ ] targetSdk is 35 (Customer) or 34 (Restaurant)
- [ ] NDK version matches project requirement
- [ ] Kotlin version is 1.9.10
- [ ] Firebase BOM version matches project
- [ ] At least one device/emulator is available
- [ ] All dependencies are installed (`flutter pub get`)

## Expected Output

After successful setup, running `flutter run` should:
1. Build the app without version errors
2. Install the app on connected device/emulator
3. Launch the app successfully

## Important Notes

⚠️ **CRITICAL**: 
- Java 17 is MANDATORY (do NOT use Java 8, 11, or 21)
- Kotlin 1.9.10 exactly
- Gradle differs between projects: 8.2.1 (Customer) / 8.7 (Restaurant)
- NDK differs: 25.1.8937393 (Customer) / 26.1.10909125 (Restaurant)
- compileSdk 35 is required for all projects

## Additional Resources

- Flutter Installation: https://docs.flutter.dev/get-started/install
- Java JDK 17 Download: https://adoptium.net/temurin/releases/?version=17
- Android Studio: https://developer.android.com/studio
- Gradle Documentation: https://gradle.org/docs/

---

**END OF SETUP PROMPT**

Follow these steps in order. If you encounter any errors, refer to the troubleshooting section before proceeding to the next step.

