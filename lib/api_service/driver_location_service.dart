import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jin_reflex_new/api_service/api_service.dart';
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';

class DriverLocationService {
  Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> sendCurrentLocation({String? authorizationToken}) async {
    await AppPreference().initialAppPreference();

    final position = await getCurrentPosition();
    if (position == null) {
      debugPrint('Location not available/permission denied');
      return;
    }

    final token = (authorizationToken ??
            AppPreference().getString(PreferencesKey.token).toString())
        .trim();

    final res = await ApiService().postDriverLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      heading: position.heading.isNaN ? null : position.heading,
      speed: position.speed.isNaN ? null : position.speed,
      authorizationToken: token.isEmpty ? null : token,
    );

    debugPrint('Driver location response: ${res?.statusCode} ${res?.data}');
  }
}

