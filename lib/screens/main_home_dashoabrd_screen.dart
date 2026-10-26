import 'package:flutter/material.dart';
import 'package:jin_reflex_new/dashbard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_screen_list.dart';
import 'package:jin_reflex_new/screens/ebook_screen.dart';
import 'package:jin_reflex_new/screens/shop/shop_screen.dart';
import 'package:jin_reflex_new/services/welcome_dialog_prefs.dart';
import 'package:jin_reflex_new/widgets/welcome_dialog.dart';

class MainHomeScreenDashBoard extends StatefulWidget {
  const MainHomeScreenDashBoard({super.key});

  @override
  State<MainHomeScreenDashBoard> createState() =>
      _MainHomeScreenDashBoardState();
}

class _MainHomeScreenDashBoardState extends State<MainHomeScreenDashBoard> with WidgetsBindingObserver {
  static bool _welcomeDialogCheckedThisSession = false;

  int _currentIndex = 0;
  int _homeScreenKey = 0; // Key to force HomeScreen rebuild

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getDeliveryType();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcomeDialog();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Restore the last active tab index from preferences
  Future<void> _restoreLastTabIndex() async {
    if (mounted) {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  /// Save the current tab index to preferences
  Future<void> _saveCurrentTabIndex() async {
    // No-op: app should always return to Home after refresh/restart.
  }

  /// Called when app lifecycle state changes (background/foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App is being backgrounded - save current state
        // _saveCurrentTabIndex();
        debugPrint('📱 App paused');
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground
        debugPrint('📱 App resumed');
        if (mounted && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
        break;
      case AppLifecycleState.detached:
        // App is about to be terminated - save state as a last resort
        // _saveCurrentTabIndex();
        debugPrint('📱 App detached');
        break;
      default:
        break;
    }
  }

  String _normalizeDeliveryType(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'india';
    }
    if (normalized == 'india' || normalized == 'in' || normalized == 'indian') {
      return 'india';
    }
    if (normalized == 'outside' ||
        normalized == 'us' ||
        normalized == 'international') {
      return 'outside';
    }
    return 'india';
  }

  Future<void> _checkAndShowWelcomeDialog() async {
    if (_welcomeDialogCheckedThisSession) {
      debugPrint('🔍 Welcome dialog already checked this session, skipping.');
      return;
    }
    _welcomeDialogCheckedThisSession = true;

    debugPrint("🔍 Checking dealer status");
    final shouldShow = await WelcomeDialogPrefs.shouldShowDialog();
    debugPrint("shouldShowWelcomeDialog = $shouldShow");
    if (!shouldShow) return;

    if (!mounted) return;

    await WelcomeDialog.show(
      context,
      onGetStarted: () {
        if (mounted) {
          setState(() {
            _homeScreenKey++;
          });
        }
      },
    );
  }

  /// 🔹 Get latest delivery type
  Future<String> _getDeliveryType() async {
    final prefs = await SharedPreferences.getInstance();
    return _normalizeDeliveryType(prefs.getString("delivery_type"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        onTap: (index) async {
          // ✅ SHOP TAB - Navigate to ShopScreen
          if (index == 2) {
            final deliveryType = await _getDeliveryType();
            
            // Navigate to ShopScreen, but keep HomeScreen in the stack
            // so back button from ShopScreen returns to HomeScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShopScreen(deliveryType: deliveryType),
              ),
            );
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Diagnosis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Product',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'E-Book'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(key: ValueKey(_homeScreenKey));

      case 1:
        return MemberListScreen();

      case 2:
        return FutureBuilder<String>(
          future: _getDeliveryType(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ShopScreen(deliveryType: snapshot.data!);
          },
        );

      case 3:
        return EbookScreen();

      default:
        return HomeScreen(key: ValueKey(_homeScreenKey));
    }
  }
}
