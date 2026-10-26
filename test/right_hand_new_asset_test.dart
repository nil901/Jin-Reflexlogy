import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('right_hand_new json asset should load', () async {
    final jsonString = await rootBundle.loadString('assets/right_hand_new.json');

    expect(jsonString, isNotEmpty);
    expect(jsonDecode(jsonString), isA<Map>());
  });
}
