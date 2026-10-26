import 'dart:convert';
import 'package:http/http.dart' as http;

class CountryModel {
  final String name;
  final String iso2;
  final String iso3; 

  CountryModel({
    required this.name,
    required this.iso2,
    required this.iso3,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name'] ?? '',
      iso2: json['iso2'] ?? '',
      iso3: json['iso3'] ?? '',
    );
  }
}

class StateModel {
  final String name;
  final String stateCode;

  StateModel({
    required this.name,
    required this.stateCode,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      name: json['name'] ?? '',
      stateCode: json['state_code'] ?? '',
    );
  }
}

class LocationApiService {
  static const String baseUrl = "https://countriesnow.space/api/v0.1/countries";

  static Future<List<CountryModel>> getCountries() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/positions"));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['error'] == false) {
          final List data = decoded['data'] ?? [];
          return data.map((e) => CountryModel.fromJson(e)).toList();
        }
      }
      throw Exception("Failed to load countries");
    } catch (e) {
      throw Exception("Error loading countries: $e");
    }
  }

static Future<List<StateModel>> getStates(String country) async {
  try {
    final url = "https://countriesnow.space/api/v0.1/countries/states";

    print("🌐 STATE API => $url");
    print("🌍 COUNTRY => $country");

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "country": country,
      }),
    );

    print("📥 STATUS => ${response.statusCode}");
    print("📥 DATA => ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["error"] == false) {
        final List list = data["data"]["states"];

        print("✅ STATES FOUND => ${list.length}");

        return list
            .map((e) => StateModel.fromJson(e))
            .toList();
      }
    }

    return [];
  } catch (e) {
    print("❌ STATE ERROR => $e");
    return [];
  }
}

  static Future<List<String>> getCities(String country, String state) async {
    try {
      print("📡 API Request - Get Cities for: $country, $state");
      
      final response = await http.post(
        Uri.parse("$baseUrl/state/cities"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"country": country, "state": state}),
      );

      print("📥 API Response Status: ${response.statusCode}");
      print("📥 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        if (decoded['error'] == false) {
          final List cities = decoded['data'] ?? [];
          print("✅ Cities found: ${cities.length}");
          return cities.map((e) => e.toString()).toList();
        } else {
          print("⚠️ API returned error: ${decoded['msg'] ?? 'Unknown error'}");
          return [];
        }
      }
      
      print("❌ HTTP Error: ${response.statusCode}");
      return [];
    } catch (e) {
      print("❌ Exception in getCities: $e");
      return [];
    }
  }
}
