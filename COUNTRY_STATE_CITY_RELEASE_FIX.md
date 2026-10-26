# Country/State/City Search Fix for Release Mode

## Problem
The country, state, and city search functionality works in debug mode but fails in release mode. This is a common issue with Flutter apps that use the `country_state_city` package.

## Root Cause
In release mode, Android enables code shrinking and obfuscation (ProGuard/R8) by default. This can break packages that:
1. Use reflection to access data
2. Have data files that get stripped during shrinking
3. Rely on class names that get obfuscated

## Solution Implemented

### 1. Added ProGuard Rules
Created `android/app/proguard-rules.pro` to prevent obfuscation of critical classes:
- Flutter classes
- country_state_city package classes
- Parcelable and Serializable objects
- App-specific classes

### 3. Enabled ProGuard with Custom Rules
Updated `android/app/build.gradle.kts` to:
- Enable code shrinking (`isMinifyEnabled = true`)
- Use custom ProGuard rules file
- Keep resource shrinking disabled to avoid issues

```kotlin
buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        isShrinkResources = false
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### 4. Added Import for Foundation
Added `import 'package:flutter/foundation.dart';` to the widget for better debugging capabilities.

## Files Modified
1. `pubspec.yaml` - Updated country_state_city version
2. `android/app/proguard-rules.pro` - Created new file with ProGuard rules
3. `android/app/build.gradle.kts` - Enabled ProGuard with custom rules
4. `lib/widgets/offline_country_state_city_widget.dart` - Added foundation import

## Testing Instructions

### Step 1: Clean and Get Dependencies
```bash
flutter clean
flutter pub get
```

### Step 2: Build Release APK
```bash
flutter build apk --release
```

### Step 3: Install and Test
```bash
flutter install --release
```

### Step 4: Verify Functionality
1. Open the app
2. Go to any screen with country/state/city selection (e.g., Sign Up, Add Patient, Buy Now)
3. Type a country name - verify dropdown shows matching countries
4. Select a country - verify states load correctly
5. Type and select a state - verify cities load correctly
6. Type and select a city - verify selection is saved

## Debug vs Release Differences

| Feature | Debug Mode | Release Mode |
|---------|-----------|--------------|
| Code Obfuscation | Disabled | Enabled (now with exceptions) |
| Tree Shaking | Disabled | Enabled |
| Package Data | Fully accessible | Was stripped, now preserved |
| Performance | Slower | Faster |
| App Size | Larger | Smaller |

## Additional Notes

### If Issues Persist
1. **Clear Build Cache**: Delete the `build/` folder manually
2. **Reinstall Package**: Run `flutter pub cache repair`
3. **Check Logs**: Run `flutter logs` to see any runtime errors
4. **Verify ProGuard**: Check `build/app/outputs/mapping/release/mapping.txt` to ensure classes aren't obfuscated

### Alternative Solution
If the above doesn't work, consider switching to a different package like:
- `country_state_city_picker: ^1.2.8` (already in dependencies)
- `dropdown_search: ^5.0.6` with custom data source

### Performance Impact
Enabling ProGuard actually improves app performance and reduces size, so this change is beneficial overall.

## Verification Checklist
- [ ] Country search works in release mode
- [ ] State search works after selecting country
- [ ] City search works after selecting state
- [ ] Selection persists correctly
- [ ] No crashes or errors in release mode
- [ ] App size is reduced compared to debug build