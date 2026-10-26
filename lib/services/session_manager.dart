import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jin_reflex_new/screens/main_home_dashoabrd_screen.dart';
import 'package:jin_reflex_new/services/auth_service.dart';

class SessionManager {
  SessionManager._();

  static bool _logoutInProgress = false;

  static Future<void> forceLogout({
    String? message,
    bool notifyServer = true,
  }) async {
    if (_logoutInProgress) return;
    _logoutInProgress = true;

    try {
      if (notifyServer) {
        await AuthService().logoutWithApi(silent: true);
      } else {
        await AuthService().logout();
      }

      if (message != null && message.trim().isNotEmpty) {
        Get.rawSnackbar(
          message: message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          duration: const Duration(seconds: 2),
        );
      }

      Get.offAll(() => const MainHomeScreenDashBoard());
    } finally {
      _logoutInProgress = false;
    }
  }
}

