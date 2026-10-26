import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiDebugHelper {
  static Future<Map<String, dynamic>> testApiFormats({
    required String therapistId,
    required String patientId,
    required String day,
    required List<String> selectedCells,
    File? feedbackImage,
  }) async {
    final results = <String, dynamic>{};
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://jinreflexology.in/api1/new/generateDiagnosisPdf.php'),
      );
      request.fields['therapistId'] = therapistId;
      request.fields['patientId'] = patientId;
      request.fields['day'] = day;
      request.fields['selectedCells'] = selectedCells.join(',');
      if (feedbackImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'feedbackImage',
            feedbackImage.path,
            filename: 'body_map.png',
          ),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      results['status'] = response.statusCode;
      results['data'] = response.body;
    } catch (e) {
      results['error'] = e.toString();
    }
    return results;
  }
}
