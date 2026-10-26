import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jin_reflex_new/api_service/global/utils.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';
import 'package:image/image.dart' as img;
import 'package:screenshot/screenshot.dart';

const String _diagnosisImageFlipPrefKey = "diagnosisImageFlip";

class PointData {
  final String id;
  double x;
  double y;
  final String tag;
  final int index;
  final String group;
  int state = 0;

  PointData({
    required this.id,
    required this.x,
    required this.y,
    required this.tag,
    required this.index,
    required this.group,
  });

  factory PointData.fromJson(Map<String, dynamic> json) {
    return PointData(
      id: json['id'].toString(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      tag: json['tag'].toString(),
      index: int.parse(json['index'].toString()),
      group: json['group'].toString(),
    );
  }
}

class RightHandNewScreen extends StatefulWidget {
  final String diagnosisId;
  final String patientId;
  final String? gender;
  final bool isNew;
  final bool isEdit;
  final bool preferServerOnLoad;

  const RightHandNewScreen({
    required this.diagnosisId,
    required this.patientId,
    this.gender,
    this.isNew = false,
    this.isEdit = false,
    this.preferServerOnLoad = false,
    super.key,
  });

  @override
  State<RightHandNewScreen> createState() => _RightHandNewScreenState();
}

class _RightHandNewScreenState extends State<RightHandNewScreen> {
  // Coordinates in left_hand_new.json are percentages of the hand image.
  static const double imageAspectRatio = 1232 / 1706;

  List<PointData> points = [];
  bool isLoading = true;

  final GlobalKey screenshotKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadPoints();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Safe setState - check if mounted before calling
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // --------------------------------------------------
  // LOAD JSON + LOCAL + SERVER
  // --------------------------------------------------
  Future<void> loadPoints() async {
    try {
      final jsonString = await rootBundle.loadString("assets/right_hand_new.json");
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final List<dynamic> jsonList =
          (jsonMap["LeftHandNew"] ?? jsonMap["RightHandNew"] ?? jsonMap["buttons"]) as List<dynamic>;
      points = jsonList.map((p) => PointData.fromJson(p)).toList();

      if (widget.isNew) {
        // ⭐ Brand new diagnosis: reset all points and do not load old drafts or server data
        for (var p in points) {
          p.state = 0;
        }
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final hasLocalDraft =
          AppPreference()
              .getString("RH_DATA_${widget.diagnosisId}_${widget.patientId}")
              .isNotEmpty;

      // load saved local selections first (if any)
      loadSavedLocal();

      // fetch server states only when no local draft exists
      if (widget.preferServerOnLoad || !hasLocalDraft) {
        await fetchServerStates();
      }

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e, st) {
      debugPrint("JSON ERROR: $e");
      debugPrint("$st");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ---------------------------------------------------
  // LOAD FROM SINGLE JSON STRING (FAST)
  // ---------------------------------------------------
  // void loadSavedLocal() {
  //   final key = "LF_DATA_${widget.diagnosisId}_${widget.patientId}";
  //   final savedJson = AppPreference().getString(key);

  //   debugPrint("LOAD LOCAL KEY -> $key");
  //   debugPrint(
  //     "SAVED JSON PREVIEW -> ${savedJson.isNotEmpty ? savedJson.substring(0, math.min(savedJson.length, 120)) : 'EMPTY'}",
  //   );

  //   if (savedJson.isEmpty) return;

  //   try {
  //     final decoded = jsonDecode(savedJson) as Map<String, dynamic>;

  //     decoded.forEach((idx, val) {
  //       final parts = (val as String).split(",");
  //       try {
  //         final p = points.firstWhere((e) => e.index.toString() == idx);
  //         p.x = double.parse(parts[0]);
  //         p.y = double.parse(parts[1]);
  //         p.state = int.parse(parts[2]);
  //       } catch (e) {
  //         debugPrint("Error applying saved point $idx -> $e");
  //       }
  //     });
  //   } catch (e) {
  //     debugPrint("Error decoding saved JSON for LF: $e");
  //   }
  // }

  void loadSavedLocal() {
    final key = "RH_DATA_${widget.diagnosisId}_${widget.patientId}";
    final savedJson = AppPreference().getString(key);

    if (savedJson.isEmpty) return;

    try {
      final Map<String, dynamic> decoded = jsonDecode(savedJson);

      for (var p in points) {
        final saved = decoded[p.index.toString()];

        if (saved != null) {
          final parts = (saved as String).split(",");

          if (parts.length == 3) {
            p.x = double.parse(parts[0]);
            p.y = double.parse(parts[1]);
            p.state = int.parse(parts[2]); // ⭐ IMPORTANT
          }
        }
      }

      debugPrint("✅ LF Local data restored");
    } catch (e) {
      debugPrint("❌ loadSavedLocal error: $e");
    }
  }

  // ---------------------------------------------------
  // FAST LOCAL SAVE (Only ONE write)
  // ---------------------------------------------------
  Future<void> saveAllPointsFast() async {
    Map<String, String> data = {};

    for (var p in points) {
      data[p.index.toString()] = "${p.x},${p.y},${p.state}";
    }

    final jsonData = jsonEncode(data);
    await AppPreference().setString(
      "RH_DATA_${widget.diagnosisId}_${widget.patientId}",
      jsonData,
    );

    debugPrint(
      "Saved RH_DATA length=${jsonData.length} key=RH_DATA_${widget.diagnosisId}_${widget.patientId}",
    );
  }

  // --------------------------------------------------
  // FETCH SERVER STATES (FIXED URL)
  // --------------------------------------------------
  Future<void> fetchServerStates() async {
    try {
      const apiUrl = "https://jinreflexology.in/api1/new/get_data.php";
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "diagnosisId": widget.diagnosisId.toString(),
          "pid": widget.patientId.toString(),
          "which": "rh",
        },
      );

      final raw = response.body;
      debugPrint(
        "SERVER RESPONSE RAW -> ${raw.length > 200 ? raw.substring(0, 200) + '...' : raw}",
      );

      // Check if response contains JSON
      if (raw.contains("{") && raw.contains("}")) {
        final start = raw.indexOf("{");
        final end = raw.lastIndexOf("}");
        if (start != -1 && end != -1 && end > start) {
          final jsonString = raw.substring(start, end + 1);

          try {
            final jsonBody = jsonDecode(jsonString);

            if (jsonBody["success"] == 1) {
              final dataStr = jsonBody["data"] as String;
              final Map<int, int> serverMap = {};

              for (final item in dataStr.split(";")) {
                if (item.contains(":")) {
                  final part = item.split(":");
                  final idx = int.tryParse(part[0]);
                  final val = int.tryParse(part[1]);
                  if (idx != null && val != null) serverMap[idx] = val;
                }
              }

              for (var p in points) {
                if (serverMap.containsKey(p.index)) {
                  final v = serverMap[p.index]!;
                  if (v == 1) {
                    p.state = 2;
                  } else if (v == -1) {
                    p.state = 0;
                  } else {
                    p.state = 1;
                  }
                }
              }

              debugPrint("Loaded ${serverMap.length} states from server");
            } else {
              debugPrint(
                "Server returned success!=1: ${jsonBody['message'] ?? 'No message'}",
              );
            }
          } catch (e) {
            debugPrint("JSON decode error: $e");
          }
        }
      } else {
        debugPrint("No JSON found in server response");
      }
    } catch (e, st) {
      debugPrint("SERVER Error: $e");
      debugPrint("$st");
    }
  }

  // --------------------------------------------------
  // SAVE TO SERVER (Background call) - FIXED URL
  // --------------------------------------------------
  Future<void> saveAllToServer() async {
    final StringBuffer sb = StringBuffer();

    for (var p in points) {
      int sendVal;
      if (p.state == 2) {
        sendVal = 1;
      } else if (p.state == 0) {
        sendVal = -1;
      } else {
        sendVal = 0;
      }

      sb.write("${p.index}:$sendVal;");
    }

    try {
      const apiUrl = "https://jinreflexology.in/api/save_data.php";
      await http.post(
        Uri.parse(apiUrl),
        body: {
          "diagnosisId": widget.diagnosisId.toString(),
          "pid": widget.patientId.toString(),
          "which": "rh",
          "data": sb.toString(),
        },
      );
      debugPrint("Saved RH to server -> length=${sb.toString().length}");
    } catch (e) {
      debugPrint("SAVE TO SERVER ERROR: $e");
    }
  }

  ScreenshotController screenshotController = ScreenshotController();
  Future<String?> captureScreenshot() async {
    try {
      final bytes = await screenshotController.capture(
        pixelRatio: 2,
        delay: const Duration(milliseconds: 350),
      );

      if (bytes == null) return null;

      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      if (AppPreference().getBool(_diagnosisImageFlipPrefKey, defValue: true)) {
        image = img.flipVertical(image);
      }
      image = img.copyResize(image, width: 900);
      final compressed = img.encodePng(image, level: 6);

      return base64Encode(compressed);
    } catch (e) {
      debugPrint("Screenshot error: $e");
      return null;
    }
  }

  // Future<String?> captureScreenshot() async {
  //   try {
  //     await WidgetsBinding.instance.endOfFrame;
  //     await Future.delayed(const Duration(milliseconds: 80));

  //     final boundary =
  //         screenshotKey.currentContext?.findRenderObject()
  //             as RenderRepaintBoundary?;

  //     if (boundary == null) return null;

  //     final image = await boundary.toImage(
  //       pixelRatio: MediaQuery.of(context).devicePixelRatio,
  //     );

  //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //     if (byteData == null) return null;

  //     final bytes = byteData.buffer.asUint8List();

  //     final decoded = img.decodeImage(bytes);
  //     if (decoded == null) return null;

  //     /// ⭐ ALWAYS fix orientation (NO detection needed)
  //     final fixed = img.flipVertical(decoded);   // ← main fix

  //     return base64Encode(img.encodePng(fixed));

  //   } catch (e) {
  //     debugPrint("Screenshot error: $e");
  //     return null;
  //   }
  // }
  // --------------------------------------------------
  // ENCODE TAGS FOR SERVER (if_result FORMAT)
  // --------------------------------------------------
  String _encodeTagsForServer() {
    // Group by state with UNIQUE tags
    final Set<String> redTags = {};
    final Set<String> greenTags = {};

    for (var point in points) {
      final effectiveTag = _effectiveTag(point);
      if (point.state == 1 && effectiveTag.isNotEmpty) {
        redTags.add(effectiveTag); // red
      } else if (point.state == 2 && effectiveTag.isNotEmpty) {
        greenTags.add(effectiveTag); // green
      }
    }

    final resultBuffer = StringBuffer();

    // Add red tags first
    if (redTags.isNotEmpty) {
      resultBuffer.write(redTags.join('|'));
    }

    // Separator only if both exist
    if (redTags.isNotEmpty && greenTags.isNotEmpty) {
      resultBuffer.write('|');
    }

    // Add green tags
    if (greenTags.isNotEmpty) {
      resultBuffer.write(greenTags.join('|'));
    }

    return resultBuffer.toString();
  }

  String _effectiveTag(PointData point) {
    final normalizedGender = (widget.gender ?? "").trim().toLowerCase();
    final isFemale = normalizedGender == "female" || normalizedGender == "f";
    if (!isFemale) return point.tag;

    switch (point.index) {
      case 98:
      case 99:
        return "Ovaries Gland";
      case 100:
      case 101:
        return "Uterus";
      case 102:
      case 103:
      case 104:
        return "Vagina";
      default:
        return point.tag;
    }
  }

  bool _isDisabledIndex(PointData p) {
    const disabledIndexes = {98, 99, 100, 101, 102, 103, 104};
    return disabledIndexes.contains(p.index);
  }

  Widget _buildDot(PointData p, double dotDiameter) {
    Color color;
    Color borderColor;
    if (p.state == 1) {
      color = const Color.fromARGB(255, 161, 27, 15);
      borderColor = Colors.black;
    } else if (p.state == 2) {
      color = Colors.green;
      borderColor = Colors.black;
    } else {
      color = Colors.transparent;
      borderColor = Colors.transparent;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_isDisabledIndex(p)) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This point is not selectable"),
              duration: Duration(milliseconds: 400),
            ),
          );
          return;
        }

        safeSetState(() {
          p.state = (p.state + 1) % 3;
          debugPrint(
            "DOT POSITION => Index: ${p.index}, "
            "X: ${p.x.toStringAsFixed(2)}, "
            "Y: ${p.y.toStringAsFixed(2)}",
          );
        });

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(p.tag),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        width: dotDiameter,
        height: dotDiameter,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SAVE TAGS TO SERVER (Additional API call if needed)
  // --------------------------------------------------
  Future<void> _saveTagsToServer(String encodedTags) async {
    try {
      const apiUrl = "https://jinreflexology.in/api/save_tags.php";
      await http.post(
        Uri.parse(apiUrl),
        body: {
          "diagnosisId": widget.diagnosisId.toString(),
          "pid": widget.patientId.toString(),
          "which": "rh",
          "tags": encodedTags,
          "timestamp": DateTime.now().toString(),
        },
      );
      debugPrint("Saved tags to server: $encodedTags");
    } catch (e) {
      debugPrint("Error saving tags: $e");
    }
  }

  String _encodeIfData() {
    final List<String> items = [];

    for (var point in points) {
      int serverValue;
      if (point.state == 2) {
        serverValue = 1;
      } else if (point.state == 1) {
        serverValue = 0;
      } else {
        serverValue = -1;
      }

      items.add("${point.index}:$serverValue");
    }

    return items.join(";");
  }

  // --------------------------------------------------
  // SAVE & EXIT BUTTON - UPDATED VERSION
  // --------------------------------------------------
  Future<void> _saveAndExit() async {
    // Show saving indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saving data..."),
        duration: Duration(seconds: 2),
      ),
    );

    // 1. Encode tags for if_result format
    final encodedTags = _encodeTagsForServer();

    // 2. Encode for if_data format
    final encodedIfData = _encodeIfData();

    // 3. Fast local save
    await saveAllPointsFast();

    // 4. Capture screenshot (must succeed)
    final base64 = await captureScreenshot();
    if (base64 == null) {
      Utils().showToastMessage("❌ Image capture failed. Try again.");
      return;
    }

    await AppPreference().setString(
      "RH_IMG_${widget.diagnosisId}_${widget.patientId}",
      base64,
    );
    debugPrint(
      "Saved RH image key=RH_IMG_${widget.diagnosisId}_${widget.patientId} length=${base64.length}",
    );

    // 5. Mark as completed
    await AppPreference().setBool(
      "RH_SAVED_${widget.diagnosisId}_${widget.patientId}",
      true,
    );

    // 6. PRINT THE ENCODED DATA (सर्व डेटा प्रिंट करा)
    debugPrint("=== RH COMPLETE DATA ===");
    debugPrint("if_result format: $encodedTags");
    debugPrint("if_data format: $encodedIfData");

    // Also print individual points with states for debugging
    for (var point in points) {
      int serverValue;
      if (point.state == 2) {
        serverValue = 1;
      } else if (point.state == 1) {
        serverValue = 0;
      } else {
        serverValue = -1;
      }

      debugPrint(
        "Point ${point.index} (${point.tag}): "
        "UI State=${point.state}, "
        "Server Value=$serverValue, "
        "Position=${point.x},${point.y}",
      );
    }
    debugPrint("=========================");

    final Map<String, dynamic> resultData = {
      'if_result': encodedTags,
      'if_data': encodedIfData,
      'screenshot_base64': base64,
      'points_count': points.length,
      'selected_points': points.where((p) => p.state != 0).length,
      'timestamp': DateTime.now().toString(),
    };

    // Save to server in background (don't wait for it)
    Future.microtask(() async {
      try {
        await saveAllToServer();
        await _saveTagsToServer(encodedTags);
        debugPrint("Background server save completed");
      } catch (e) {
        debugPrint("Background server save failed: $e");
      }
    });

    // Return to previous screen
    if (mounted) {
      Navigator.pop(context, resultData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double desiredAspect = imageAspectRatio;
    final double screenW = MediaQuery.of(context).size.width * 0.98;
    final double screenH = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double availableH =
        screenH - topPadding - kToolbarHeight - bottomPadding - 16;

    // Width fits screen width, height increased moderately for a larger and taller view
    final double containerW = screenW;
    final double baseH = containerW / desiredAspect;
    final double containerH = math.min(availableH * 0.88, baseH * 1.15);
    final double dotDiameter = containerW * 0.035;

    return Scaffold(
      appBar: CommonAppBar(title: "Right Hand"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAndExit,
        label: const Text("Save", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 118, 202, 121),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: SizedBox(
                  width: containerW,
                  height: containerH,
                  child: Screenshot(
                    controller: screenshotController,
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Image.asset(
                          'assets/images/right_hand_new.jpg',
                          width: containerW,
                          height: containerH,
                          fit: BoxFit.fill,
                        ),
                        ...points.map((p) {
                          final double left =
                              (p.x / 100.0 * containerW) - (dotDiameter / 2);
                          final double top =
                              (p.y / 100.0 * containerH) - (dotDiameter / 2);
                          return Positioned(
                            left: left,
                            top: top,
                            child: _buildDot(p, dotDiameter),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
