# App Resume Fix Guide

## Problem
When users switch to another app and then return to this app, it doesn't resume properly. Instead, it starts from the beginning (like a fresh launch). This problem happens on some devices, particularly when Android kills the app process to free up memory.

## Root Cause
1. The app always starts with `SplashScreen()` in `main.dart`
2. The splash screen always navigates to `MainHomeScreenDashBoard()` after 5 seconds, regardless of previous state
3. When Android kills the app process (which happens on devices with limited memory), and the user returns, the app restarts from scratch

## Solution Implemented

### 1. Added State Restoration Keys (`lib/api_service/prefs/PreferencesKey.dart`)
```dart
// App state restoration keys
static String lastActiveRoute = "lastActiveRoute";
static String appHasBeenLaunched = "appHasBeenLaunched";
static String lastActiveTabIndex = "lastActiveTabIndex";
```

### 2. Modified `main.dart` to Handle State Restoration
- Added a `FutureBuilder` that checks if the app has been launched before
- On first launch: Shows splash screen and marks app as launched
- On subsequent launches: Skips splash screen and goes directly to `MainHomeScreenDashBoard()`

```dart
home: FutureBuilder<bool>(
  future: _shouldShowSplash(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (snapshot.data == true) {
      return const SplashScreen();  // First time
    }
    
    return MainHomeScreenDashBoard();  // Returning user
  },
)
```

### 3. Modified `MainHomeScreenDashBoard` with Lifecycle Handling
- Added `WidgetsBindingObserver` to detect when app is backgrounded/foreground
- Saves the current tab index when app is paused or detached
- Restores the last active tab index when app starts

```dart
class _MainHomeScreenDashBoardState extends State<MainHomeScreenDashBoard> 
    with WidgetsBindingObserver {
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _saveCurrentTabIndex();  // Save state when backgrounded
        break;
      case AppLifecycleState.detached:
        _saveCurrentTabIndex();  // Save state before termination
        break;
      default:
        break;
    }
  }
}
```

## How It Works

### First Time Launch Flow:
1. App starts → `main.dart` checks `appHasBeenLaunched` (false)
2. Shows `SplashScreen` for 5 seconds
3. Sets `appHasBeenLaunched = true`
4. Navigates to `MainHomeScreenDashBoard`

### Returning User Flow:
1. App starts → `main.dart` checks `appHasBeenLaunched` (true)
2. Skips splash screen
3. Goes directly to `MainHomeScreenDashBoard`
4. `MainHomeScreenDashBoard` restores the last active tab from preferences

### Background/Foreground Flow:
1. User switches to another app
2. `didChangeAppLifecycleState(AppLifecycleState.paused)` is called
3. Current tab index is saved to SharedPreferences
4. User returns to app
5. App restores to the saved tab index

## Testing the Fix

### Test 1: First Time Launch
1. Clear app data/storage
2. Launch the app
3. Verify splash screen is shown for 5 seconds
4. Verify app navigates to home screen

### Test 2: Returning User
1. Launch the app (after first launch)
2. Navigate to a different tab (e.g., Diagnosis or Product)
3. Close the app (swipe away from recent apps)
4. Relaunch the app
5. Verify app opens directly to the last active tab (no splash screen)

### Test 3: Background/Resume
1. Open the app and navigate to a tab other than Home
2. Press home button or switch to another app
3. Wait a few seconds (or open memory-intensive apps to trigger process kill)
4. Return to the app from recent apps
5. Verify app shows the same tab you were on before

## Files Modified
1. `lib/api_service/prefs/PreferencesKey.dart` - Added state restoration keys
2. `lib/main.dart` - Added logic to skip splash for returning users
3. `lib/screens/main_home_dashoabrd_screen.dart` - Added lifecycle handling and tab restoration
4. `lib/screens/splash_screen.dart` - Cleaned up unused imports
5. `lib/screens/shop/shop_screen.dart` - Updated back button handling to navigate to HomeScreen

## Additional Fix: Shop Screen Back Button
The Shop Screen back button now correctly navigates to the HomeScreen instead of exiting the app. This was achieved by:
1. Changing navigation from `pushReplacement` to `push` in `MainHomeScreenDashBoard`
2. Updating `WillPopScope` in `ShopScreen` to simply pop the current screen

## Notes
- The splash screen is now only shown on the very first app launch
- On subsequent launches, users go directly to the home screen
- The current tab index is saved when the app is backgrounded
- This fix works across app restarts and process kills
- Back button from Shop Screen now returns to HomeScreen
