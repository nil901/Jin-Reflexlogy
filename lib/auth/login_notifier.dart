import 'dart:io';
import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get/get.dart' hide FormData;
import 'package:http/http.dart' as http;
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/dashbord_forlder/CourseDetailScreen.dart';
import 'package:jin_reflex_new/dashbord_forlder/freddback_list.dart';
import 'package:jin_reflex_new/dashbord_forlder/training_coureses.dart';
import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_screen_list.dart';
import 'package:jin_reflex_new/screens/ebook_screen.dart';
import 'package:jin_reflex_new/screens/life_style/life_style_screen.dart';
import 'package:jin_reflex_new/screens/point_finder_screen.dart';
import 'package:jin_reflex_new/screens/treatment/triment_screen.dart';

import '../screens/shop/cartscreen.dart';
import '../screens/shop/shop_screen.dart';

final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<void>>((
  ref,
) {
  return LoginNotifier();
});

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  LoginNotifier() : super(const AsyncValue.data(null));

  bool _isLoggingIn = false;

  Future<void> login(
    BuildContext context,
    VoidCallback onTab,
    String text,
    String type,
    dynamic id,
    dynamic password, {
    dynamic DeliveryType,
    String? productId,
  }) async {
    if (_isLoggingIn) return;
    _isLoggingIn = true;

    state = const AsyncValue.loading();

    try {
      final oldType = AppPreference().getString(PreferencesKey.type);

      if (type.trim().isNotEmpty && oldType.isNotEmpty && oldType != type) {
        state = const AsyncValue.data(null);

        _showTypeConflictDialog(
          context,
          oldType: oldType,
          newType: type,
          onConfirm: () async {
            await AppPreference().clearSharedPreferences();
            Navigator.pop(context);

            _isLoggingIn = false;

            login(
              context,
              onTab,
              text,
              type,
              id,
              password,
              DeliveryType: DeliveryType,
            );
          },
        );
        return;
      }

      final response = await http.post(
        Uri.parse("https://jinreflexology.in/api1/new/login.php"),
        body: {
          "id": id.toString(),
          "password": password.toString(),
          "type": type.toString(),
        },
      ).timeout(const Duration(seconds: 20));

      final raw = response.body.trim();
      debugPrint("===== LOGIN RAW RESPONSE =====");
      debugPrint(raw);
      debugPrint("=============================");

      if (!raw.startsWith("{")) {
        throw "Invalid server response";
      }

      final int jsonStart = raw.indexOf('{');
      if (jsonStart == -1) {
        throw "Invalid server response";
      }

      final cleanJson = raw.substring(jsonStart);
      final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

      debugPrint("PARSED JSON: $jsonData");

      final dynamic successValue = jsonData["success"];
      final bool isSuccess =
          successValue == 1 || successValue == true || successValue == "1";

      final String message =
          jsonData["message"] ??
          (isSuccess ? "Login successful" : "Login failed");

      if (context.mounted) {
        Get.rawSnackbar(
          message: message,
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          borderRadius: 8,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2),
        );
      }

      if (!isSuccess) {
        state = AsyncValue.error("Login failed", StackTrace.current);
        return;
      }

      final Map<String, dynamic>? userData =
          jsonData['user_data'] is Map ? jsonData['user_data'] : null;

      final dynamic dataNode = jsonData['data'];
      final Map<String, dynamic>? dataMap =
          dataNode is Map
              ? dataNode.cast<String, dynamic>()
              : (dataNode is List &&
                    dataNode.isNotEmpty &&
                    dataNode.first is Map)
              ? (dataNode.first as Map).cast<String, dynamic>()
              : null;

      final userId =
          userData?['id'] ??
          userData?['user_id'] ??
          dataMap?['id'] ??
          dataMap?['user_id'] ??
          jsonData['id'] ??
          jsonData['user_id'] ??
          jsonData['userId'];

      final token =
          userData?['token'] ??
          userData?['t_token'] ??
          dataMap?['token'] ??
          dataMap?['t_token'] ??
          jsonData['token'] ??
          jsonData['t_token'] ??
          "";

      final name =
          userData?['t_name'] ??
          userData?['name'] ??
          dataMap?['t_name'] ??
          dataMap?['name'] ??
          jsonData['name'] ??
          "";

      final email =
          userData?['t_email'] ??
          userData?['email'] ??
          dataMap?['t_email'] ??
          dataMap?['email'] ??
          jsonData['email'] ??
          "";

      final mobile =
          userData?['t_mobile'] ??
          userData?['p_number'] ??
          userData?['mobile'] ??
          userData?['phone'] ??
          dataMap?['t_mobile'] ??
          dataMap?['p_number'] ??
          dataMap?['mobile'] ??
          dataMap?['phone'] ??
          jsonData['mobile'] ??
          jsonData['phone'] ??
          "";

      if (userId == null || userId.toString().isEmpty) {
        throw "User ID missing";
      }

      String finalType =
          type.trim().isNotEmpty ? type : (jsonData['type'] ?? "").toString();

      if (finalType.isEmpty && text == "BodyPartScreen") {
        finalType = "patient";
      }

      await AppPreference().initialAppPreference();
      await AppPreference().setString(PreferencesKey.userId, userId.toString());
      await AppPreference().setString(PreferencesKey.token, token.toString());
      await AppPreference().setString(PreferencesKey.name, name.toString());
      await AppPreference().setString(PreferencesKey.email, email.toString());
      await AppPreference().setString(
        PreferencesKey.contactNumber,
        mobile.toString(),
      );
      await AppPreference().setString(PreferencesKey.type, finalType);

      state = const AsyncValue.data(null);

      debugPrint("===== LOGIN SUCCESS =====");

      const popReturnFlows = {
        "ProductDetailScreen",
        "CourseDetailScreen",
        "CourseScreen",
        "Treatment",
      };

      if (!context.mounted) {
        return;
      }

      if (popReturnFlows.contains(text)) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
        return;
      }

      _navigate(context, text, DeliveryType, productId: productId);
    } catch (e, st) {
      debugPrint("LOGIN ERROR => $e");
      debugPrint("$st");

      if (context.mounted) {
        Get.rawSnackbar(
          message: _mapLoginError(e),
          backgroundColor: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      state = AsyncValue.error(e, st);
    } finally {
      _isLoggingIn = false;
    }
  }
}

String _mapLoginError(dynamic error) {
  if (error is TimeoutException) {
    return "Request timed out. Please try again.";
  }
  if (error is SocketException) {
    return kIsWeb
        ? "Website API unavailable. Check server CORS settings."
        : "No internet connection. Please check your network and try again.";
  }
  return "Unable to complete login right now. Please try again.";
}

class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  final String _baseUrl = "https://jinreflexology.in/api1/new/";

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl + endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": 0, "message": "Server Error ${response.statusCode}"};
      }
    } catch (e) {
      return {"success": 0, "message": e.toString()};
    }
  }
}

void _navigate(
  BuildContext context,
  String text,
  dynamic DeliveryType, {
  String? productId,
}) {
  switch (text) {
    case "MemberListScreen":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MemberListScreen()),
      );
      break;

    case "LifestyleScreen":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LifestyleScreen()),
      );
      break;

    case "EbookScreen":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EbookScreen()),
      );
      break;

    case "PointFinderScreen":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PointFinderScreen()),
      );
      break;
    case "CourseDetailScreen":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => CourseDetailScreen(course: {}, deliveryType: DeliveryType),
        ),
      );
      break;

    case "CourseScreen":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CourseScreen(deliveryType: DeliveryType),
        ),
      );
      break;

    case "Treatment":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Treatment()),
      );
      break;

    case "BodyPartScreen":
      final uid = AppPreference().getString(PreferencesKey.userId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => BodyPartScreen(
                pId: uid,
                dId: null,
                day: "last",
                isShow: false,
              ),
        ),
      );
      break;

    case "ShopScreen":
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ShopScreen(deliveryType: DeliveryType),
        ),
      );
      break;

    case "ProductDetailScreen":
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => CartScreen(deliveryType: DeliveryType),
        ),
        (route) => false,
      );
      break;
  }
}

void _showTypeConflictDialog(
  BuildContext context, {
  required String oldType,
  required String newType,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        title: const Text("Already Logged In"),
        content: Text(
          "You are already logged in as $oldType.\n\n"
          "Do you want to logout $oldType and login as $newType?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text(
              "Logout & Continue",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
