import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:country_state_city/country_state_city.dart' as csc;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/auth/upload_document.dart';
import 'package:jin_reflex_new/bannar.dart';
import 'package:jin_reflex_new/dashbord_forlder/colors/color_screen.dart';
import 'package:jin_reflex_new/dashbord_forlder/feedback_form.dart';
import 'package:jin_reflex_new/dashbord_forlder/feedback_from_screen.dart';
import 'package:jin_reflex_new/dashbord_forlder/freddback_list.dart';
import 'package:jin_reflex_new/dashbord_forlder/free_power_yoga.dart';
import 'package:jin_reflex_new/dashbord_forlder/healthy_tips.dart';
import 'package:jin_reflex_new/dashbord_forlder/food/food_screen.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2015.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2016.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2017.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2018.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2019.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2020.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2021.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2022.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2023.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2024.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2025.dart';
import 'package:jin_reflex_new/dashbord_forlder/helth_awraness/wrw_2026.dart';
import 'package:jin_reflex_new/dashbord_forlder/minerals/minerals.dart';
import 'package:jin_reflex_new/dashbord_forlder/murdra/mudra.dart';
import 'package:jin_reflex_new/dashbord_forlder/spine/spine_screen.dart';
import 'package:jin_reflex_new/dashbord_forlder/training_coureses.dart';
import 'package:jin_reflex_new/dashbord_forlder/vitamin/vitamin.dart';
import 'package:jin_reflex_new/dashbord_forlder/year_comaining.dart';
import 'package:jin_reflex_new/dashbord_forlder/yoga/yoga.dart';
import 'package:jin_reflex_new/foot_chart_screen.dart';
import 'package:jin_reflex_new/hand_chart_screen.dart';
import 'package:jin_reflex_new/marking_screen.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_screen_list.dart';
import 'package:jin_reflex_new/screens/aboutUs%20copy.dart';
import 'package:jin_reflex_new/screens/anil_jain_about_screen.dart';
import 'package:jin_reflex_new/screens/comman_webview_screen.dart';

import 'package:jin_reflex_new/screens/contactUs/feedBack.dart';
import 'package:jin_reflex_new/screens/ebook_screen.dart';
import 'package:jin_reflex_new/screens/faq_screen.dart';
import 'package:jin_reflex_new/screens/history_screen.dart';
import 'package:jin_reflex_new/screens/info_screen.dart';
import 'package:jin_reflex_new/screens/health_campaign_pdf_screen.dart';
import 'package:jin_reflex_new/screens/life_style/life_style_screen.dart';
import 'package:jin_reflex_new/screens/life_style/treatmentPlan.dart';
import 'package:jin_reflex_new/screens/shop/shop_screen.dart';
import 'package:jin_reflex_new/screens/speesh_screen.dart';
import 'package:jin_reflex_new/screens/treatment/helth_meeter_screen.dart';
import 'package:jin_reflex_new/screens/visitUsScreen.dart';
import 'package:jin_reflex_new/screens/point_finder_screen.dart';
import 'package:jin_reflex_new/screens/point_screen.dart';
import 'package:jin_reflex_new/screens/relaxing_screen.dart';
import 'package:jin_reflex_new/screens/settings_screen.dart';
import 'package:jin_reflex_new/screens/sussess_story_screen.dart';
import 'package:jin_reflex_new/screens/treatment/triment_screen.dart';
import 'package:jin_reflex_new/services/welcome_dialog_prefs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jin_reflex_new/widgets/welcome_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _countryName = 'Loading...';
  String _countryCode = '';
  bool _isLoadingLocation = true;

  // Welcome user data
  String _welcomeMobile = '';
  String _welcomeEmail = '';
  String _welcomeDealerId = '';

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

  Future<void> _saveDeliveryType(String value) async {
    final normalized = _normalizeDeliveryType(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("delivery_type", normalized);

    debugPrint("âœ… delivery_type saved = $normalized");
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLocationPermission();
      _checkDocumentsAndShowPopup();
    });

    _loadWelcomeData();

    Future.delayed(const Duration(seconds: 2), _autoSlide);
  }

  /// Load welcome user data from SharedPreferences
  Future<void> _loadWelcomeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _welcomeMobile = prefs.getString(WelcomeDialogPrefs.keyMobile) ?? '';
      _welcomeEmail = prefs.getString(WelcomeDialogPrefs.keyEmail) ?? '';
      _welcomeDealerId = prefs.getString(WelcomeDialogPrefs.keyDealerId) ?? '';
    });

    debugPrint("ðŸ“Š Loaded welcome data:");
    debugPrint("   Mobile: $_welcomeMobile");
    debugPrint("   Email: $_welcomeEmail");
    debugPrint("   Dealer ID: $_welcomeDealerId");
  }

  Future<void> _checkDocumentsAndShowPopup() async {
    try {
      final userId = AppPreference().getString(PreferencesKey.userId);

      /// 1ï¸âƒ£ userId check
      if (userId == null || userId.isEmpty) return;

      /// 2ï¸âƒ£ type check
      final userType = AppPreference().getString(PreferencesKey.type);

      if (userType != "therapist") return;

      final response = await http.get(
        Uri.parse(
          'https://jinreflexology.in/api1/new/check_documents.php?id=$userId',
        ),
      );

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);

      /// âœ… If status true â†’ all good
      if (data["status"] == true) {
        return;
      }

      /// â— document_uploaded false à¤…à¤¸à¥‡à¤² à¤¤à¤° popup
      final bool documentUploaded = data['document_uploaded'] == true;

      debugPrint("ðŸ“„ Document Uploaded: $documentUploaded");

      if (!documentUploaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showUploadPopup();
        });
      }
    } catch (e) {
      debugPrint('âŒ Document check error: $e');
    }
  }

  void _showUploadPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => PopScope(
            canPop: true,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              iconPadding: const EdgeInsets.only(top: 8, right: 8),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      size: 40,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Upload Required",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Your documents are pending upload.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Upload now to continue using all features.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("LATER"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DocumentUploadScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload, size: 20),
                            SizedBox(width: 8),
                            Text("UPLOAD NOW"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            ),
          ),
    );
  }

  void _autoSlide() {
    if (!mounted) return;
    _currentPage = (_currentPage + 1) % 3;

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> checkLocationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDeliveryType = prefs.getString("delivery_type");
      if (savedDeliveryType != null && savedDeliveryType.isNotEmpty) {
        final normalized = _normalizeDeliveryType(savedDeliveryType);
        if (mounted) {
          setState(() {
            _countryName = normalized == 'india' ? 'India' : 'International';
            _countryCode = normalized == 'india' ? 'IN' : 'US';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      /// Step 1 : check location service safely with timeout
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _countryName = 'India';
            _countryCode = 'IN';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      /// Step 2 : check permission with timeout
      var permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 2), onTimeout: () => LocationPermission.denied);
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 3), onTimeout: () => LocationPermission.denied);
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _countryName = 'India';
            _countryCode = 'IN';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      debugPrint("checkLocationPermission error: $e");
      if (mounted) {
        setState(() {
          _countryName = 'India';
          _countryCode = 'IN';
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Permission Required"),
            content: Text("Location permission is required."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: Text("Open Settings"),
              ),
            ],
          ),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Location Disabled"),
            content: Text("Please enable location service."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: Text("Enable"),
              ),
            ],
          ),
    );
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    _getCurrentLocation();

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        setState(() {
          _countryName = 'Permission denied';
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _countryName = 'Permission denied';
        _isLoadingLocation = false;
      });
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _getCurrentLocation();
  }

  Future<String> _getEnglishCountryName(String? rawCountry, String? isoCode) async {
    final cleanCode = (isoCode ?? '').trim().toUpperCase();
    if (cleanCode == 'IN') return 'India';
    if (cleanCode == 'US') return 'United States';
    if (cleanCode == 'GB' || cleanCode == 'UK') return 'United Kingdom';
    if (cleanCode == 'AE') return 'United Arab Emirates';
    if (cleanCode == 'CA') return 'Canada';
    if (cleanCode == 'AU') return 'Australia';

    if (cleanCode.isNotEmpty) {
      try {
        final allCountries = await csc.getAllCountries();
        final match = allCountries.where((c) => c.isoCode.toUpperCase() == cleanCode).firstOrNull;
        if (match != null && match.name.isNotEmpty) {
          return match.name;
        }
      } catch (_) {}
    }

    final lower = (rawCountry ?? '').toLowerCase();
    if (lower.contains('india') || lower.contains('bharat') || lower.contains('hindustan')) {
      return 'India';
    }

    return (rawCountry != null && rawCountry.isNotEmpty) ? rawCountry : 'Unknown';
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2), onTimeout: () => false);
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _countryName = 'India';
            _countryCode = 'IN';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      final permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 2), onTimeout: () => LocationPermission.denied);
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _countryName = 'India';
            _countryCode = 'IN';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      try {
        await setLocaleIdentifier('en').timeout(const Duration(seconds: 1));
      } catch (_) {}

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 3),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 3), onTimeout: () => []);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final rawCountry = place.country ?? 'India';
        final code = (place.isoCountryCode ?? 'IN').toUpperCase();

        final englishCountry = await _getEnglishCountryName(rawCountry, code);

        final deliveryType =
            (code == "IN" || englishCountry.toLowerCase().contains("india"))
                ? "india"
                : "outside";

        await _saveDeliveryType(deliveryType);

        if (mounted) {
          setState(() {
            _countryName = englishCountry;
            _countryCode = code.isNotEmpty ? code : (deliveryType == 'india' ? 'IN' : 'US');
            _isLoadingLocation = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _countryName = 'India';
            _countryCode = 'IN';
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Current location error: $e");
      if (mounted) {
        setState(() {
          _countryName = 'India';
          _countryCode = 'IN';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<String> _getSavedDeliveryType() async {
    final prefs = await SharedPreferences.getInstance();
    return _normalizeDeliveryType(prefs.getString("delivery_type"));
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _countryName = 'Loading...';
      _countryCode = '';
    });
    await _requestLocationPermission();
  }

  /// ================= DATA =================

  List<CampaignItem> campaignItems1() => [
    CampaignItem(
      title: 'History',
      img: 'assets/jinImages/01.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Info',
      img: 'assets/jinImages/02.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfoScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Foot Chart',
      img: 'assets/jinImages/03.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FootChartScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Hand Chart',
      img: 'assets/jinImages/04.png',
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HandChartScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Marking',
      img: 'assets/jinImages/05.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MarkingProcedureScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Relaxing',
      img: 'assets/jinImages/06.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FootRelaxingScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Effective Points',
      img: 'assets/jinImages/07.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PointsScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'FAQ',
      img: 'assets/jinImages/08.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FaqScreen()),
        );
      },
    ),
  ];

  List<CampaignItem> campaignItems2() => [
    CampaignItem(
      title: 'Diagnosis',
      img: 'assets/jinImages/09.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MemberListScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Finder',
      img: 'assets/jinImages/10.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PointFinderScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Life Style',
      img: 'assets/jinImages/11.png',
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LifestyleScreen()),
        );
      },
    ),

    CampaignItem(
      title: 'Feedback',
      img: 'assets/jinImages/12.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BodyPartScreen(
                  pId: AppPreference().getString(PreferencesKey.userId),
                  dId: null,
                  day: "last",
                  isShow: true,
                ),
          ),
        );
      },
    ),
  ];

  List<CampaignItem> campaignItems3() => [
    // CampaignItem(
    //   title: 'Shop',
    //   img: 'assets/jinImages/13.png',
    //   onTap: () async {
    //     final deliveryType = await _getSavedDeliveryType();
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) => ShopScreen(deliveryType: deliveryType),
    //       ),
    //     );
    //   },
    // ),
    // CampaignItem(
    //   title: 'Treat Video',
    //   img: 'assets/jinImages/14.png',
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => Treatment()),
    //     );
    //   },
    // ),
    // CampaignItem(
    //   title: 'JIN Refle.Book',
    //   img: 'assets/jinImages/15.png',
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => EbookScreen()),
    //     );
    //   },
    // ),

    //    CampaignItem(
    //   title: 'Training',
    //   img: 'assets/jinImages/20.png',
    //   onTap: () async {
    //     final deliveryType = await _getSavedDeliveryType();
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) => CourseScreen(deliveryType: deliveryType),
    //       ),
    //     );
    //   },
    // ),
    CampaignItem(
      title: 'Seminar',
      img: 'assets/jinImages/17.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CommonWebView(
                  url: "https://jinreflexology.in/seminar/",
                  title: "Seminar",
                ),
          ),
        );
      },
    ),
    CampaignItem(
      title: 'Workshop',
      img: 'assets/jinImages/18.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CommonWebView(
                  url: "https://jinreflexology.in/seminar/",
                  title: "Workshop",
                ),
          ),
        );
      },
    ),
    CampaignItem(
      title: 'Update',
      img: 'assets/jinImages/38.png',
      onTap: () {
        //Navigator.pop(context);
        launchUrl(
          Uri.parse("https://www.facebook.com/profile.php?id=61580519183420"),
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    CampaignItem(
      title: 'Treatement Plan',
      img: 'assets/jinImages/16.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TreatmentPlanScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Free power Yoga',
      img: 'assets/jinImages/19.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PowerYogaScreen()),
        );
      },
    ),

    CampaignItem(
      title: 'Healthy Tips',
      img: 'assets/jinImages/21.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HealthyTipsScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Health Meter',
      img: 'assets/images/metericon.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HealthFormScreen()),
        );
      },
    ),

    CampaignItem(
      title: 'Success Story',
      img: 'assets/jinImages/24.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SuccessStoryScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Food',
      img: 'assets/jinImages/food.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FoodScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Vitamin',
      img: 'assets/jinImages/vitamin.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VitaminsScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Minerals',
      img: 'assets/jinImages/minerals.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MineralsScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Speeches',
      img: 'assets/jinImages/speech.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SpeechesScreen()),
        );
      },
    ),

    CampaignItem(
      title: 'Mudra',
      img: 'assets/jinImages/mudra.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MudrasScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Yoga',
      img: 'assets/jinImages/yoga.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => YogasScreen()),
        );
      },
    ),

    CampaignItem(
      title: 'Color',
      img: 'assets/jinImages/color.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ColorsScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'Spinal',
      img: 'assets/jinImages/spinal.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SpinesScreen()),
        );
      },
    ),
  ];
  List<CampaignItem> campaignItems6() => [
    CampaignItem(
      title: 'Shop',
      img: 'assets/jinImages/13.png',
      onTap: () async {
        final deliveryType = await _getSavedDeliveryType();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopScreen(deliveryType: deliveryType),
          ),
        );
      },
    ),
    CampaignItem(
      title: 'Treat Video',
      img: 'assets/jinImages/14.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Treatment()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Refle.Book',
      img: 'assets/jinImages/15.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EbookScreen()),
        );
      },
    ),

    CampaignItem(
      title: 'Training',
      img: 'assets/jinImages/20.png',
      onTap: () async {
        final deliveryType = await _getSavedDeliveryType();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseScreen(deliveryType: deliveryType),
          ),
        );
      },
    ),
    // CampaignItem(
    //   title: 'Seminar',
    //   img: 'assets/jinImages/17.png',
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder:
    //             (_) => CommonWebView(
    //               url: "https://jinreflexology.in/seminar/",
    //               title: "Seminar",
    //             ),
    //       ),
    //     );
    //   },
    // ),
    // CampaignItem(
    //   title: 'Workshop',
    //   img: 'assets/jinImages/18.png',
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder:
    //             (_) => CommonWebView(
    //               url: "https://jinreflexology.in/seminar/",
    //               title: "Workshop",
    //             ),
    //       ),
    //     );
    //   },
    // ),
    //   CampaignItem(
    //     title: 'Update',
    //     img: 'assets/jinImages/38.png',
    //     onTap: () {
    //       //Navigator.pop(context);
    //       launchUrl(
    //         Uri.parse("https://www.facebook.com/profile.php?id=61580519183420"),
    //         mode: LaunchMode.externalApplication,
    //       );
    //     },
    //   ),
    //  CampaignItem(
    //     title: 'Treatement Plan',
    //     img: 'assets/jinImages/16.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (context) => TreatmentPlanScreen()),
    //       );
    //     },
    //   ),
    //   CampaignItem(
    //     title: 'Free power Yoga',
    //     img: 'assets/jinImages/19.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => const PowerYogaScreen()),
    //       );
    //     },
    //   ),

    //   CampaignItem(
    //     title: 'Healthy Tips',
    //     img: 'assets/jinImages/21.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => HealthyTipsScreen()),
    //       );
    //     },
    //   ),
    //   CampaignItem(
    //     title: 'Health Meter',
    //     img: 'assets/images/metericon.jpeg',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => HealthFormScreen()),
    //       );
    //     },
    //   ),

    //   CampaignItem(
    //     title: 'Success Story',
    //     img: 'assets/jinImages/24.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => SuccessStoryScreen()),
    //       );
    //     },
    //   ),
    //   CampaignItem(
    //     title: 'Food',
    //     img: 'assets/jinImages/food.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => FoodScreen()),
    //       );
    //     },
    //   ),
    //   CampaignItem(
    //     title: 'Vitamin',
    //     img: 'assets/jinImages/vitamin.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => VitaminsScreen()),
    //       );
    //     },
    //   ),
    //   CampaignItem(
    //     title: 'Minerals',
    //     img: 'assets/jinImages/minerals.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => MineralsScreen()),
    //       );
    //     },
    //   ),
    //   CampaignItem(
    //     title: 'Speeches',
    //     img: 'assets/jinImages/speech.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => SpeechesScreen()),
    //       );
    //     },
    //   ),

    //   CampaignItem(
    //     title: 'Mudra',
    //     img: 'assets/jinImages/mudra.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => MudrasScreen()),
    //       );
    //     },
    //   ),
    //   CampaignItem(
    //     title: 'Yoga',
    //     img: 'assets/jinImages/yoga.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => YogasScreen()),
    //       );
    //     },
    //   ),

    //   CampaignItem(
    //     title: 'Color',
    //     img: 'assets/jinImages/color.png',
    //     onTap: () {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (_) => ColorsScreen()),
    //       );
    //     },
    //   ),
    // CampaignItem(
    //   title: 'Spinal',
    //   img: 'assets/jinImages/spinal.png',
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (_) => SpinesScreen()),
    //     );
    //   },
    // ),
  ];
  List<CampaignItem> campaignItems4() => [
    // CampaignItem(
    //   title: 'Health Awareness PDFs',
    //   img: 'assets/jinImages/25.png',
    //   onTap: () {
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => const HealthCampaignScreen()),
    //     );
    //   },
    // ),
    CampaignItem(
      title: 'JIN Day 2015',
      img: 'assets/jinImages/2015p.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Wrw2015Screen()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Day 2016',
      img: 'assets/jinImages/2016p.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Wrw2016Screen()),
        );
      },
    ),
    CampaignItem(
      title: '2017',
      img: 'assets/jinImages/2017p.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Wrw2017Screen()),
        );
      },
    ),
    CampaignItem(
      title: '2018',
      img: 'assets/jinImages/2018p.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Wrw2018Screen()),
        );
      },
    ),
    CampaignItem(
      title: '2019',
      img: 'assets/jinImages/2019p.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Wrw2019Screen()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Day 2020',
      img: 'assets/jinImages/2020p.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Wrw2020Screen()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Day 2021',
      img: 'assets/jinImages/2021.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Wrw2021Screen()),
        );
      },
    ),

    CampaignItem(
      title: 'JIN Day 2022',
      img: 'assets/jinImages/2022.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Wrw2022Screen()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Day 2023',
      img: 'assets/jinImages/2023.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Wrw2023Screen()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Day 2024',
      img: 'assets/jinImages/2024.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Wrw2024Screen()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Day 2025',
      img: 'assets/jinImages/2025.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Wrw2025Screen()),
        );
      },
    ),
    CampaignItem(
      title: 'JIN Day 2026',
      img: 'assets/jinImages/2026.jpeg',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HealthCampaign2026Screen()),
        );
      },
    ),
    // CampaignItem(title: '2019', img: 'assets/jinImages/31.png', onTap: () {}),
    // CampaignItem(title: '2018', img: 'assets/jinImages/31.png', onTap: () {}),

    // CampaignItem(
    //   title: '1989 to 2014',
    //   img: 'assets/jinImages/31.png',
    //   onTap: () {},
    // ),
  ];

  List<CampaignItem> campaignItems5() => [
    CampaignItem(
      title: 'About us',
      img: 'assets/jinImages/37.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'JR Anil Jain',
      img: 'assets/jinImages/23.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AboutJinReflexologyScreen()),
        );
      },
    ),

    CampaignItem(
      title: 'Contact Us',
      img: 'assets/jinImages/39.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VisitUsScreen()),
        );
      },
    ),
    CampaignItem(
      title: 'WhatsApp',
      img: 'assets/jinImages/40.png',
      onTap: () async {
        final url = Uri.parse(
          "https://wa.me/${7620616269}?text=${Uri.encodeComponent("")}",
        );

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          print("Could not launch WhatsApp");
        }
      },
    ),
    CampaignItem(
      title: 'Review',
      img: 'assets/jinImages/41.png',
      onTap: () {
        launchUrl(
          Uri.parse("https://maps.app.goo.gl/scfouzyb2nEzdBkr8?g_st=aw"),
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    CampaignItem(
      title: 'Facebook',
      img: 'assets/jinImages/42.png',
      onTap: () {
        launchUrl(
          Uri.parse("https://www.facebook.com/profile.php?id=61580519183420"),
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    CampaignItem(
      title: 'Youtube',
      img: 'assets/jinImages/43.png',
      onTap: () {
        launchUrl(
          Uri.parse("https://www.youtube.com/@JINReflexology"),
          mode: LaunchMode.externalApplication,
        );
      },
    ),
    CampaignItem(
      title: 'FeedBack',
      img: 'assets/jinImages/44.png',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeedbackFormScreen()),
        ); //2
      },
    ),
  ];

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEAEA),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 19, 4, 66),
        title: const Text(
          'JIN Reflexology',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        actions: [
          // âœ… Country Selector Dropdown
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: FutureBuilder<String>(
              future: _getSavedDeliveryType(),
              builder: (context, snapshot) {
                final deliveryType = snapshot.data ?? 'india';
                final countryCode = deliveryType == 'india' ? 'in' : 'us';

                return PopupMenuButton<String>(
                  onSelected: (value) async {
                    await _saveDeliveryType(value);

                    // Update UI
                    setState(() {
                      _countryName =
                          value == 'india' ? 'India' : 'International';
                      _countryCode = value == 'india' ? 'IN' : 'US';
                    });

                    // Show feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value == 'india'
                              ? 'Switched to India (Prices in ₹)'
                              : 'Switched to International (Prices in \$)',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_countryCode.isNotEmpty && !_isLoadingLocation)
                          SizedBox(
                            width: 16,
                            height: 10,
                            child: CountryFlag.fromCountryCode(_countryCode),
                          ),
                        if (_countryCode.isNotEmpty && !_isLoadingLocation)
                          const SizedBox(width: 6),
                        Text(
                          _countryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 20,
                        ),
                        if (_isLoadingLocation) ...[
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'india',
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: SizedBox(
                                  width: 24,
                                  height: 16,
                                  child: CountryFlag.fromCountryCode('IN'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'India',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Prices in ₹ (INR)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (deliveryType == 'india') ...[
                                const Spacer(),
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'outside',
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 16,
                                child: Center(
                                  child: Icon(
                                    Icons.public,
                                    color: Color(0xFF1976D2),
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'International',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Prices in \$ (USD)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (deliveryType == 'outside') ...[
                                const Spacer(),
                                const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                );
              },
    ),
      )],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 19, 4, 66),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  // JIN Logo Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      "assets/images/jin_reflexo.png",
                      height: 60,
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_welcomeMobile.isNotEmpty) ...[
                    Text(
                      _welcomeMobile,
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],

                  // Show email if available
                  if (_welcomeEmail.isNotEmpty) ...[
                    Text(
                      _welcomeEmail,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                  ],

                  // Show dealer ID if available
                  if (_welcomeDealerId.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "VD ID: $_welcomeDealerId",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],

                  // Show default text if no user data
                  if (_welcomeMobile.isEmpty && _welcomeEmail.isEmpty) ...[
                    Text(
                      "JIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "REFLEXOLOGY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded),
              title: Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CommonWebView(
                          url: "https://jinreflexology.in/privacypolicy.php",
                          title: "Privacy Policy",
                        ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.orange),
              title: const Text('Rate Us'),
              onTap: () async {
                final Uri url = Uri.parse(
                  "https://play.google.com/store/apps/details?id=com.jin.reflexology",
                );

                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.indigo),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(bottom: 20),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
    ),
        )],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            // AutoSlider(pageController: _pageController),
            BannerSlider(),
            _campaignSection(header: "JIN Reflexolog", items: campaignItems1()),
            // const SizedBox(height: 4),
            _campaignSection(
              header: "For JIN Reflexologist                   For Patients",
              items: campaignItems2(),
            ),
            // const SizedBox(height: 4),
            _campaignSection(header: "Premium", items: campaignItems6()),

            _campaignSection(header: "Utility", items: campaignItems3()),

            // const SizedBox(height: 4),
            _campaignSection(header: "Contact us", items: campaignItems5()),

            // Container(
            //   color: const Color(0xFF3B3B8F),
            //   child: YeraHelathScreen(),
            // ),

            // campaignItems4(),
            _campaignSection(
              header: " India's Biggest Health Awareness Campaign",
              items: campaignItems4(),
            ),

            // const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CommonWebView(
                            url: "https://jinreflexology.in/news-2/",
                            title: "All Event News Paper Clip 2010 to 2025",
                          ),
                    ),
                  );
                },
                child: Container(
                  //height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B3B8F),

                    // borderRadius: BorderRadius.circular(25)
                  ),
                  child: Text(
                    "All Event News Paper Clip 2010 to 2025",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CommonWebView(
                            url: "https://jinreflexology.in/mi/",
                            title: "Social Works in Mahavir International",
                          ),
                    ),
                  );
                },
                child: Container(
                  //height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B3B8F),

                    // borderRadius: BorderRadius.circular(25)
                  ),
                  child: Text(
                    "Social Works in Mahavir International",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// ================= CAMPAIGN SECTION =================

  Widget _campaignSection({
    required String header,
    required List<CampaignItem> items,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF3B3B8F),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Text(
            header,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) {
              final item = items[index];
              return Column(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: item.onTap,
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 1,
                          bottom: 1,
                          left: 18,
                          right: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Image.asset(item.img, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ================= AUTO SLIDER =================

class AutoSlider extends StatelessWidget {
  final PageController pageController;
  const AutoSlider({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView(
        controller: pageController,
        children: const [
          _SliderCard(color: Colors.blue, title: "Page 1"),
          _SliderCard(color: Colors.green, title: "Page 2"),
          _SliderCard(color: Colors.orange, title: "Page 3"),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final Color color;
  final String title;
  const _SliderCard({required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// ================= MODEL =================

class CampaignItem {
  final String title;
  final String img;
  final VoidCallback onTap;

  const CampaignItem({
    required this.title,
    required this.img,
    required this.onTap,
  });
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await AppPreference().initialAppPreference();
              final userId = AppPreference().getString(PreferencesKey.userId);
              final type = AppPreference().getString(PreferencesKey.type);
              try {
                final url = 'https://jinreflexology.in/api1/new/logout.php';
                var request = http.MultipartRequest('POST', Uri.parse(url));
                request.fields['id'] = userId.toString();
                request.fields['type'] = type.toString();
                print("------------ LOGOUT API DEBUG ------------");
                print("URL: $url");
                print("FIELDS: id => $userId, type => $type");
                var response = await request.send();
                var responseBody = await response.stream.bytesToString();
                print("STATUS CODE => ${response.statusCode}");
                print("RESPONSE BODY => $responseBody");
                final decoded = jsonDecode(responseBody);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(decoded["message"] ?? "Logout success"),
                    duration: const Duration(milliseconds: 800),
                  ),
                );

                await AppPreference().clearSharedPreferences();

                Navigator.pop(context);
              } catch (e) {
                print("Logout API Error (ignored): $e");
              }

              print('User logged out successfully');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}













































