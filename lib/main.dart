import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/login_screen.dart';
import 'package:jin_reflex_new/screens/main_home_dashoabrd_screen.dart';
import 'package:jin_reflex_new/screens/splash_screen.dart';
import 'package:jin_reflex_new/services/auth_service.dart';

// Global RouteObserver
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreference().initialAppPreference();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JIN Reflexology',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      navigatorObservers: [routeObserver],
      // Determine initial route based on app state
      home: FutureBuilder<Map<String, bool>>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a minimal loading widget while checking state
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final showSplash = snapshot.data?['showSplash'] ?? false;
          final isLoggedIn = snapshot.data?['isLoggedIn'] ?? false;
          
          // If this is the first launch, show splash screen
          if (showSplash) {
            return const SplashScreen();
          }
          
       
        
          // Otherwise, show home screen (user is logged in)
          return MainHomeScreenDashBoard();
        },
      ),
    );
  }

  Future<bool> _shouldShowSplash() async {
    final appPref = AppPreference();
    final hasBeenLaunched = appPref.getBool(PreferencesKey.appHasBeenLaunched);
    
    if (!hasBeenLaunched) {
      // First time launch - mark as launched and show splash
      await appPref.setBool(PreferencesKey.appHasBeenLaunched, true);
      return true;
    }
  
    return false;
  }

  /// Get initial screen state (splash + authentication)
  Future<Map<String, bool>> _getInitialScreen() async {
    final showSplash = await _shouldShowSplash();
    final isLoggedIn = AuthService().isLoggedIn();
    
    return {
      'showSplash': showSplash,
      'isLoggedIn': isLoggedIn,
    };
  }
}