import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jin_reflex_new/api_service/global/utils.dart';
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:jin_reflex_new/api_service/urls.dart';
import 'package:jin_reflex_new/screens/Diagnosis/left_foot_screen.dart';
import 'package:jin_reflex_new/screens/Diagnosis/left_hand_new_diagnoso_screen.dart';
import 'package:jin_reflex_new/screens/Diagnosis/left_hand_sc.dart';
import 'package:jin_reflex_new/screens/Diagnosis/right_hand_new_screen.dart';
import 'package:jin_reflex_new/screens/Diagnosis/right_hand_sc.dart';
import 'package:jin_reflex_new/screens/Diagnosis/right_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';

enum DiagnosisPart { hand, foot }

/// Shows a dialog allowing the user to choose between Hand and Foot diagnosis.
Future<DiagnosisPart?> showDiagnosisTypeDialog(BuildContext context) async {
  return showDialog<DiagnosisPart>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xffF9CF63).withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: Color(0xffC69009),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Select Diagnosis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Which diagnosis would you like to perform?",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                "Please choose Hand or Foot to proceed:",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 16),
            // Foot Option Card
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(dialogContext).pop(DiagnosisPart.foot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF8E7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffF9CF63), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xffF9CF63),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.do_not_step,
                        color: Colors.black87,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Foot Diagnosis",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Foot & Hand reflexology (LF, RF, LH, RH)",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Hand Option Card
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.of(dialogContext).pop(DiagnosisPart.hand),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xffEEF5FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade300, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.front_hand,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Hand Diagnosis (New)",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Left & Right Hand reflexology (New)",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
        ],
      );
    },
  );
}

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({
    super.key,
    this.patient_id,
    this.name,
    this.diagnosis_id,
    this.gender,
    this.isNew = false,
    this.isEdit = false,
    this.part,
  });

  final dynamic patient_id;
  final dynamic name;
  final dynamic diagnosis_id;
  final String? gender;
  final bool isNew;
  final bool isEdit;
  final DiagnosisPart? part;

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String? satisfaction = "Yes";
  final TextEditingController matchedProblem = TextEditingController();
  final TextEditingController notDetected = TextEditingController();

  bool lfSaved = false;
  bool rfSaved = false;
  bool lhSaved = false;
  bool rhSaved = false;

  String? lfData;
  String? lfImg64;
  String? lfResult;
  String? rfData;
  String? rfResult;
  String? rfImg;
  String? rhData;
  String? rhResult;
  String? rhImg;
  String? lhData;
  String? lhResult;
  String? lhImg;
  String? leftHandNew;
  String? rightHandNew;
  String? leftHandResult;
  String? rightHandResult;
  String? leftHandImg;
  String? rightHandImg;

  bool isLoading = false;
  double uploadProgress = 0.0;

  // Initialize as empty list, will be populated in initState
  late List<Map<String, dynamic>> diagnosisOptions;

  @override
  void initState() {
    super.initState();
    if (widget.isNew) {
      AppPreference().clearDiagnosisDrafts(patientId: widget.patient_id?.toString());
    }
    // Initialize diagnosisOptions in initState where widget is available
    diagnosisOptions = [
      {
        "title": "Diagnose Left Foot",
        "type": "lf",
        // These will be updated dynamically in onTap
        "screen": LeftFootScreenNew(
          diagnosisId: widget.diagnosis_id?.toString() ?? "",
          patientId: widget.patient_id?.toString() ?? "",
          gender: widget.gender,
          isNew: widget.isNew,
          isEdit: widget.isEdit,
          preferServerOnLoad: widget.isEdit,
        ),
      },
      {
        "title": "Diagnose Right Foot",
        "type": "rf",
        "screen": RightFootScreenNew(
          patientId: widget.patient_id?.toString() ?? "",
          diagnosisId: widget.diagnosis_id?.toString() ?? "",
          gender: widget.gender,
          isNew: widget.isNew,
          isEdit: widget.isEdit,
          preferServerOnLoad: widget.isEdit,
        ),
      },
      {
        "title": "Diagnose Left Hand",
        "type": "lh",
        "screen": LeftHandScreen(
          pid: widget.patient_id?.toString() ?? "",
          diagnosisId: widget.diagnosis_id?.toString() ?? "",
          gender: widget.gender,
          isEdit: widget.isEdit,
        ),
      },
      {
        "title": "Diagnose Right Hand",
        "type": "rh",
        "screen": RightHandScreen(
          pid: widget.patient_id?.toString() ?? "",
          diagnosisId: widget.diagnosis_id?.toString() ?? "",
          gender: widget.gender,
          isEdit: widget.isEdit,
        ),
      },
      {
        "title": "Diagnose Left Hand (New)",
        "type": "lhn",
        "screen": LeftHandNewScreen(
          patientId: widget.patient_id?.toString() ?? "",
          diagnosisId: widget.diagnosis_id?.toString() ?? "",
          gender: widget.gender,
          isNew: widget.isNew,
          isEdit: widget.isEdit,
          preferServerOnLoad: widget.isEdit,
        ),
      },
      {
        "title": "Diagnose Right Hand (New)",
        "type": "rhn",
        "screen": RightHandNewScreen(
          patientId: widget.patient_id?.toString() ?? "",
          diagnosisId: widget.diagnosis_id?.toString() ?? "",
          gender: widget.gender,
          isNew: widget.isNew,
          isEdit: widget.isEdit,
          preferServerOnLoad: widget.isEdit,
        ),
      },
    ];
  }

  void showSnack(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int get completedPartsCount {
    int count = 0;
    if (lfSaved) count++;
    if (rfSaved) count++;
    if (lhSaved) count++;
    if (rhSaved) count++;
    return count;
  }

  int get completionPercentage {
    if (widget.part == DiagnosisPart.foot) {
      int count = 0;
      if (lfSaved) count++;
      if (rfSaved) count++;
      if (lhSaved) count++;
      if (rhSaved) count++;
      return count * 25;
    } else if (widget.part == DiagnosisPart.hand) {
      int count = 0;
      if (lhSaved) count++;
      if (rhSaved) count++;
      return count * 50;
    }
    return completedPartsCount * 25;
  }

  bool get canSubmit {
    if (widget.part == DiagnosisPart.foot) {
      return lfSaved || rfSaved || lhSaved || rhSaved;
    } else if (widget.part == DiagnosisPart.hand) {
      return lhSaved && rhSaved;
    }
    return completedPartsCount > 0;
  }

  bool get allPartsCompleted {
    if (widget.part == DiagnosisPart.foot) {
      return lfSaved && rfSaved && lhSaved && rhSaved;
    } else if (widget.part == DiagnosisPart.hand) {
      return lhSaved && rhSaved;
    }
    return lfSaved && rfSaved && lhSaved && rhSaved;
  }

  bool _isVisibleOption(String type) {
    if (widget.part == DiagnosisPart.hand) {
      // Hand section has LeftHandNew and RightHandNew
      return type == "lhn" || type == "rhn";
    } else if (widget.part == DiagnosisPart.foot) {
      // Foot section has Foot + Left Hand and Right Hand
      return type == "lf" || type == "rf" || type == "lh" || type == "rh";
    }
    return true; // Show all options
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: const [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Confirm Exit",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Your data will not be saved if you go back.\nAre you sure you want to exit?",
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  actions: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F3EB),
        appBar: CommonAppBar(
          title: widget.part == DiagnosisPart.foot
              ? "Foot Diagnosis"
              : widget.part == DiagnosisPart.hand
                  ? "Hand Diagnosis"
                  : "Diagnosis",
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF9CF63),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Patient ID : ${widget.patient_id}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Patient Name : ${widget.name}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xffF9CF63),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child: Center(
                  child: Text(
                    widget.part == DiagnosisPart.foot
                        ? "Foot Diagnosis"
                        : widget.part == DiagnosisPart.hand
                            ? "Hand Diagnosis"
                            : "Diagnosis",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ...diagnosisOptions
                  .where((option) => _isVisibleOption(option["type"]))
                  .map((option) {
                    String type = option["type"];
                    bool isCompleted = false;
                    String result = "";

                    switch (type) {
                      case "lf":
                        isCompleted = lfSaved;
                        result = lfResult ?? "";
                        break;
                      case "rf":
                        isCompleted = rfSaved;
                        result = rfResult ?? "";
                        break;
                      case "lh":
                      case "lhn":
                        isCompleted = lhSaved;
                        result = (lhResult != null && lhResult!.isNotEmpty)
                            ? lhResult!
                            : (leftHandResult ?? "");
                        break;
                      case "rh":
                      case "rhn":
                        isCompleted = rhSaved;
                        result = (rhResult != null && rhResult!.isNotEmpty)
                            ? rhResult!
                            : (rightHandResult ?? "");
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                isCompleted
                                    ? Colors.green
                                    : const Color(0xffF9CF63),
                            width: isCompleted ? 3 : 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isCompleted
                                    ? Colors.green
                                    : const Color(0xffF9CF63),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                color:
                                    isCompleted ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          option["title"],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        subtitle:
                            isCompleted && result.isNotEmpty
                                ? Text(
                                  "Result: $result",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                                : null,
                        trailing: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.arrow_forward_ios,
                          color: isCompleted ? Colors.green : Colors.grey,
                          size: 20,
                        ),
                        onTap: () async {
                          dynamic result;

                          if (type == "lf") {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => LeftFootScreenNew(
                                      diagnosisId:
                                          widget.diagnosis_id.toString(),
                                      patientId: widget.patient_id.toString(),
                                      gender: widget.gender,
                                      isNew: widget.isNew,
                                      isEdit: widget.isEdit,
                                      preferServerOnLoad: widget.isEdit,
                                    ),
                              ),
                            );
                          } else if (type == "rf") {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => RightFootScreenNew(
                                      patientId: widget.patient_id.toString(),
                                      diagnosisId:
                                          widget.diagnosis_id.toString(),
                                      gender: widget.gender,
                                      isNew: widget.isNew,
                                      isEdit: widget.isEdit,
                                      preferServerOnLoad: widget.isEdit,
                                    ),
                              ),
                            );
                          } else if (type == "rh") {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => RightHandScreen(
                                      pid: widget.patient_id.toString(),
                                      diagnosisId:
                                          widget.diagnosis_id.toString(),
                                      gender: widget.gender,
                                      isEdit: widget.isEdit,
                                    ),
                              ),
                            );
                          } else if (type == "lh") {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => LeftHandScreen(
                                      pid: widget.patient_id.toString(),
                                      diagnosisId:
                                          widget.diagnosis_id.toString(),
                                      gender: widget.gender,
                                      isEdit: widget.isEdit,
                                    ),
                              ),
                            );
                          } else if (type == "lhn") {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => LeftHandNewScreen(
                                      patientId: widget.patient_id.toString(),
                                      diagnosisId:
                                          widget.diagnosis_id.toString(),
                                      gender: widget.gender,
                                      isNew: widget.isNew,
                                      isEdit: widget.isEdit,
                                      preferServerOnLoad: widget.isEdit,
                                    ),
                              ),
                            );
                          } else if (type == "rhn") {
                            result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => RightHandNewScreen(
                                      patientId: widget.patient_id.toString(),
                                      diagnosisId:
                                          widget.diagnosis_id.toString(),
                                      gender: widget.gender,
                                      isNew: widget.isNew,
                                      isEdit: widget.isEdit,
                                      preferServerOnLoad: widget.isEdit,
                                    ),
                              ),
                            );
                          }

                          if (result != null && result is Map) {
                            debugPrint("⬅️ Data received from $type: $result");

                            setState(() {
                              switch (type) {
                                case "lf":
                                  lfSaved = true;
                                  lfResult = result['if_result'];
                                  lfData = result['if_data'];
                                  lfImg64 = result['screenshot_base64'];
                                  debugPrint("LF RESULT => $lfResult");
                                  break;
                                case "rf":
                                  // RightFootScreenNew returns these RF-specific
                                  // keys.  Without this case its successful save
                                  // was discarded and the RF card stayed pending.
                                  rfSaved = true;
                                  rfData = result["rf_data"];
                                  rfResult = result["rf_result"];
                                  rfImg = result["rf_img"];
                                  debugPrint("RF RESULT => $rfResult");
                                  break;
                                case "lh":
                                  lhSaved = true;
                                  lhData =
                                      result["lh_data"] ?? result["if_data"];
                                  lhResult =
                                      result["lh_result"] ??
                                      result["if_result"];
                                  lhImg =
                                      result["lh_img"] ??
                                      result["screenshot_base64"];
                                  break;
                                case "rh":
                                  rhSaved = true;
                                  rhData =
                                      result["rh_data"] ?? result["if_data"];
                                  rhResult =
                                      result["rh_result"] ??
                                      result["if_result"];
                                  rhImg =
                                      result["rh_img"] ??
                                      result["screenshot_base64"];
                                  break;
                                case "lhn":
                                  lhSaved = true;
                                  leftHandNew = result["if_data"] ?? "";
                                  leftHandResult = result["if_result"] ?? "";
                                  leftHandImg =
                                      result["screenshot_base64"] ?? "";
                                  lhData = leftHandNew;
                                  lhResult = leftHandResult;
                                  lhImg = leftHandImg;
                                  break;
                                case "rhn":
                                  rhSaved = true;
                                  rightHandNew = result["if_data"] ?? "";
                                  rightHandResult = result["if_result"] ?? "";
                                  rightHandImg =
                                      result["screenshot_base64"] ?? "";
                                  rhData = rightHandNew;
                                  rhResult = rightHandResult;
                                  rhImg = rightHandImg;
                                  break;
                              }
                            });

                            if (mounted) {
                              showSnack(
                                context,
                                "${option["title"]} completed successfully!",
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                  }),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.part == null || widget.part == DiagnosisPart.foot) ...[
                      _statusIndicator("LF", lfSaved),
                      _statusIndicator("RF", rfSaved),
                      _statusIndicator("LH", lhSaved),
                      _statusIndicator("RH", rhSaved),
                    ],
                    if (widget.part == DiagnosisPart.hand) ...[
                      _statusIndicator("LH", lhSaved),
                      _statusIndicator("RH", rhSaved),
                    ],
                  ],
                ),
              ),
              Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text(
                      "Are You Satisfied with the Diagnosis?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: "Yes",
                            groupValue: satisfaction,
                            title: const Text("Yes"),
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() => satisfaction = value);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            value: "No",
                            groupValue: satisfaction,
                            title: const Text("No"),
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() => satisfaction = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _textInput(
                      "Which of the Diagnosis points match your problem?",
                      matchedProblem,
                    ),
                    const SizedBox(height: 12),
                    _textInput(
                      "Which problems were not detected?",
                      notDetected,
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: canSubmit
                ? isLoading
                    ? Center(child: _loadingButton())
                    : _button(
                        completionPercentage == 100
                            ? "Submit"
                            : "Submit ($completionPercentage%)",
                        Colors.green,
                        () {
                          if (matchedProblem.text.isEmpty) {
                            Utils().showToastMessage(
                              "Please enter which diagnosis points match your problem?",
                            );
                            return;
                          }
                          if (notDetected.text.isEmpty) {
                            Utils().showToastMessage(
                              "Please enter which problems were not detected?",
                            );
                            return;
                          }
                          submitDiagnosis();
                        },
                        isEnabled: true,
                      )
                : _button(
                    "Submit ($completionPercentage%)",
                    Colors.grey.shade400,
                    () {
                      if (widget.part == DiagnosisPart.hand && (!lhSaved || !rhSaved)) {
                        showSnack(
                          context,
                          "Please complete both Left Hand and Right Hand diagnosis first!",
                          error: true,
                        );
                      } else {
                        showSnack(
                          context,
                          "Please complete at least one diagnosis part first!",
                          error: true,
                        );
                      }
                    },
                    isEnabled: true,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _statusIndicator(String label, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? Colors.green.shade800 : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isCompleted ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isCompleted ? "✓ Done" : "Pending",
          style: TextStyle(
            color: isCompleted ? Colors.green : Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _textInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _button(
    String label,
    Color color,
    VoidCallback onTap, {
    bool isEnabled = true,
  }) {
    return ElevatedButton(
      onPressed: isEnabled ? onTap : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isEnabled ? Colors.white : Colors.grey,
          fontSize: 15,
        ),
      ),
    );
  }

  Future<String> _optimizeBase64Image(String? rawB64) async {
    if (rawB64 == null || rawB64.isEmpty) return "";
    String b64 = rawB64.contains(',')
        ? rawB64.substring(rawB64.indexOf(',') + 1)
        : rawB64;
    // Strip whitespace and line breaks that can corrupt Base64 or trigger WAF issues
    b64 = b64.replaceAll(RegExp(r'\s+'), '');
    if (b64.isEmpty) return "";

    try {
      final bytes = base64Decode(b64);
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        // Resize and quantize colors to eliminate high-frequency pixel noise that triggers ModSecurity regexes
        final resized = img.copyResize(decoded, width: 360);
        final quantized = img.quantize(resized, numberOfColors: 128);
        final encoded = img.encodePng(quantized, level: 6);
        final result = base64Encode(encoded);
        debugPrint(
          "Optimized image: ~${b64.length ~/ 1024} KB -> ~${result.length ~/ 1024} KB",
        );
        return result;
      }
    } catch (e) {
      debugPrint("Image optimize error: $e");
    }
    return b64;
  }

  // Future<void> submitDiagnosis() async {
  //   setState(() {
  //     isLoading = true;
  //     uploadProgress = 0.0;
  //   });

  //   try {
  //     debugPrint("=== Original Image Sizes ===");
  //     if (lfImg64 != null) debugPrint("LF: ${lfImg64!.length ~/ 1024} KB");
  //     if (rfImg != null) debugPrint("RF: ${rfImg!.length ~/ 1024} KB");
  //     if (lhImg != null) debugPrint("LH: ${lhImg!.length ~/ 1024} KB");
  //     if (rhImg != null) debugPrint("RH: ${rhImg!.length ~/ 1024} KB");
  //     int totalSize = 0;
  //     debugPrint("Total size to upload: ${totalSize ~/ 1024} KB");

  //     if (totalSize > 5 * 1024 * 1024) {
  //       showSnack(
  //         context,
  //         "Warning: Large data size (${totalSize ~/ 1024}KB). Upload may take time.",
  //         error: true,
  //       );
  //     }

  //     FormData formData = FormData.fromMap({
  //       "lf_data": lfData ?? "",
  //       "lf_img": lfImg64 ?? lfImg64 ?? "",
  //       "lf_result": lfResult ?? "",
  //       "rf_data": rfData ?? "",
  //       "rf_img": rfImg ?? rfImg ?? "",
  //       "rf_result": rfResult ?? "",
  //       "lh_data": lhData ?? "",
  //       "lh_img": lhImg ?? lhImg ?? "",
  //       "lh_result": lhResult ?? "",
  //       "rh_data": rhData ?? "",
  //       "rh_img": rhImg ?? rhImg ?? "",
  //       "rh_result": rhResult ?? "",
  //       "problems_matched": matchedProblem.text,
  //       "not_detected": notDetected.text,
  //       "patient_id": widget.patient_id,
  //       "pid": AppPreference().getString(PreferencesKey.userId).toString(),
  //       "diagnosis_id": widget.diagnosis_id,
  //       "is_satisfied": satisfaction ?? "Yes",
  //       "timestamp": DateTime.now().toString().replaceAll(" ", "+"),
  //     });

  //     debugPrint("===== SUBMIT API BODY START =====");
  //     debugPrint("URL => $add_diagnosis");
  //     debugPrint("gender => ${widget.gender}");
  //     debugPrint("patient_id => ${widget.patient_id}");
  //     debugPrint("pid => ${AppPreference().getString(PreferencesKey.userId)}");
  //     debugPrint("diagnosis_id => ${widget.diagnosis_id}");
  //     debugPrint("lf_result => ${lfResult ?? ""}");
  //     debugPrint("rf_result => ${rfResult ?? ""}");
  //     debugPrint("lh_result => ${lhResult ?? ""}");
  //     debugPrint("rh_result => ${rhResult ?? ""}");
  //     debugPrint("lf_data => ${lfData ?? ""}");
  //     debugPrint("rf_data => ${rfData ?? ""}");
  //     debugPrint("lh_data => ${lhData ?? ""}");
  //     debugPrint("rh_data => ${rhData ?? ""}");
  //     debugPrint("problems_matched => ${matchedProblem.text}");
  //     debugPrint("not_detected => ${notDetected.text}");
  //     debugPrint("is_satisfied => ${satisfaction ?? "Yes"}");
  //     debugPrint("lf_img_length => ${lfImg64?.length ?? 0}");
  //     debugPrint("rf_img_length => ${rfImg?.length ?? 0}");
  //     debugPrint("lh_img_length => ${lhImg?.length ?? 0}");
  //     debugPrint("rh_img_length => ${rhImg?.length ?? 0}");
  //     debugPrint("===== SUBMIT API BODY END =====");

  //     final dio = Dio();

  //     dio.options.connectTimeout = Duration(seconds: 60);
  //     dio.options.receiveTimeout = Duration(seconds: 60);
  //     dio.options.sendTimeout = Duration(seconds: 120);

  //     final response = await dio.post(
  //      widget.isEdit ? update_diagnosis : add_diagnosis,
  //       data: formData,
  //       options: Options(
  //         contentType: "multipart/form-data",
  //         responseType: ResponseType.plain,
  //         headers: {'Connection': 'keep-alive'},
  //       ),
  //       onSendProgress: (sent, total) {
  //         if (total != -1) {
  //           double progress = (sent / total) * 100;
  //           if (mounted) {
  //             setState(() {
  //               uploadProgress = progress;
  //             });
  //           }

  //           debugPrint(
  //             "Upload: ${sent ~/ 1024}KB / ${total ~/ 1024}KB (${progress.toStringAsFixed(1)}%)",
  //           );
  //         }
  //       },
  //     );

  //     debugPrint("===== FORM DATA FIELDS =====");
  //     debugPrint("===== ${response.data} =====");
  //     for (var field in formData.fields) {
  //       debugPrint(
  //         "${field.key} => ${field.value.length > 100 ? field.value.substring(0, 100) + '...' : field.value}",
  //       );
  //     }

  //     debugPrint("===== FORM DATA FILES =====");
  //     for (var file in formData.files) {
  //       debugPrint("${file.key} => ${file.value.filename}");
  //     }

  //     debugPrint("STATUS: ${response.statusCode}");

  //     if (response.statusCode == 200) {
  //       setState(() {
  //         uploadProgress = 100;
  //       });

  //       await Future.delayed(Duration(milliseconds: 500));

  //       showSnack(context, "Diagnosis Submitted Successfully!");

  //       if (mounted) {
  //         Navigator.pop(context, true);
  //       }
  //     } else {
  //       showSnack(context, "Server error: ${response.statusCode}", error: true);
  //     }
  //   } catch (e) {
  //     debugPrint("API ERROR: $e");

  //     if (e is DioException) {
  //       if (e.type == DioExceptionType.connectionTimeout) {
  //         showSnack(
  //           context,
  //           "Connection timeout. Check internet.",
  //           error: true,
  //         );
  //       } else if (e.type == DioExceptionType.sendTimeout) {
  //         showSnack(context, "Upload timeout. Images too large.", error: true);
  //       } else if (e.response != null) {
  //         showSnack(
  //           context,
  //           "Server error: ${e.response!.statusCode}",
  //           error: true,
  //         );
  //       } else {
  //         showSnack(context, "Network error: ${e.message}", error: true);
  //       }
  //     } else {
  //       showSnack(context, "Error: $e", error: true);
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  String _buildCurlCommand(
    String url,
    Map<String, String> headers,
    Map<String, String> fields,
  ) {
    final buffer = StringBuffer();
    buffer.write("curl --location '$url' \\\n");
    headers.forEach((key, value) {
      buffer.write("--header '$key: $value' \\\n");
    });
    final entries = fields.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final key = entries[i].key;
      final value = entries[i].value;
      final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      final isLast = (i == entries.length - 1);
      if (isLast) {
        buffer.write("--form '$key=\"$escaped\"'\n");
      } else {
        buffer.write("--form '$key=\"$escaped\"' \\\n");
      }
    }
    return buffer.toString();
  }

  void _printCurlCommand(String curl, Map<String, String> fields) {
    debugPrint("\n===================== 📋 REQUEST FIELDS SUMMARY (${fields.length} FIELDS) =====================");
    fields.forEach((key, value) {
      if (value.length > 80) {
        debugPrint("  $key (${value.length} chars) => ${value.substring(0, 40)}... [truncated preview]");
      } else {
        debugPrint("  $key => \"$value\"");
      }
    });
    debugPrint("===================================================================================\n");

    debugPrint("\n===================== 🚀 GENERATED CURL START =====================");
    final lines = curl.split('\n');
    for (final line in lines) {
      if (line.length <= 800) {
        debugPrint(line);
      } else {
        for (int i = 0; i < line.length; i += 800) {
          final end = (i + 800 < line.length) ? i + 800 : line.length;
          debugPrint(line.substring(i, end));
        }
      }
    }
    debugPrint("===================== 🚀 GENERATED CURL END =====================\n");
  }

  Future<void> submitDiagnosis() async {
    setState(() {
      isLoading = true;
      uploadProgress = 10.0;
    });

    Timer? progressTimer;
    progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (uploadProgress < 90) {
        setState(() {
          uploadProgress += (90 - uploadProgress) * 0.15 + 2.0;
          if (uploadProgress > 92) uploadProgress = 92;
        });
      }
    });

    final isHand = widget.part == DiagnosisPart.hand;
    final targetUrl = widget.isEdit
        ? update_diagnosis
        : (isHand ? add_hand_diagnosis : add_diagnosis);
    final prefUserId = AppPreference().getString(PreferencesKey.userId);
    final pid = (prefUserId.isNotEmpty && prefUserId != "null") ? prefUserId : "22";

    debugPrint("\n=======================================================");
    debugPrint("🚀 [DIAGNOSIS API CALL START]");
    debugPrint("URL: $targetUrl");
    debugPrint("Type: ${isHand ? 'HAND DIAGNOSIS' : 'FOOT DIAGNOSIS'}");
    debugPrint("Patient ID: ${widget.patient_id}");
    debugPrint("User ID (pid): $pid");
    debugPrint("Is Edit Mode: ${widget.isEdit}");
    debugPrint("Completed Parts Count: $completedPartsCount of ${isHand ? 2 : 4} ($completionPercentage%)");

    try {
      final currentLhImg = (lhImg != null && lhImg!.isNotEmpty)
          ? lhImg
          : ((leftHandImg != null && leftHandImg!.isNotEmpty)
              ? leftHandImg
              : AppPreference().getString("LH_IMG_${widget.diagnosis_id}_${widget.patient_id}"));
      final currentRhImg = (rhImg != null && rhImg!.isNotEmpty)
          ? rhImg
          : ((rightHandImg != null && rightHandImg!.isNotEmpty)
              ? rightHandImg
              : AppPreference().getString("RH_IMG_${widget.diagnosis_id}_${widget.patient_id}"));

      final currentLhData = (lhData != null && lhData!.isNotEmpty)
          ? lhData!
          : (leftHandNew ?? "");
      final currentLhResult = (lhResult != null && lhResult!.isNotEmpty)
          ? lhResult!
          : (leftHandResult ?? "");
      final currentRhData = (rhData != null && rhData!.isNotEmpty)
          ? rhData!
          : (rightHandNew ?? "");
      final currentRhResult = (rhResult != null && rhResult!.isNotEmpty)
          ? rhResult!
          : (rightHandResult ?? "");

      Map<String, String> formFields;

      if (isHand) {
        // Optimize Hand images
        final results = await Future.wait([
          _optimizeBase64Image(currentLhImg),
          _optimizeBase64Image(currentRhImg),
        ]);
        final optimizedLhImg = results[0];
        final optimizedRhImg = results[1];

        debugPrint("Optimized Hand Images payload check:");
        debugPrint("  LH Image: ${optimizedLhImg.isEmpty ? 'none' : '~${optimizedLhImg.length ~/ 1024} KB'}");
        debugPrint("  RH Image: ${optimizedRhImg.isEmpty ? 'none' : '~${optimizedRhImg.length ~/ 1024} KB'}");

        // 🔹 EXACT HAND DIAGNOSIS FORM DATA FIELDS
        formFields = <String, String>{
          "pid": pid,
          "patient_id": widget.patient_id?.toString() ?? "",
          "lh_data": currentLhData,
          "lh_result": currentLhResult,
          "lh_img": optimizedLhImg,
          "rh_data": currentRhData,
          "rh_result": currentRhResult,
          "rh_img": optimizedRhImg,
          "is_satisfied": satisfaction ?? "Yes",
          "problems_matched": matchedProblem.text.trim(),
          "not_detected": notDetected.text.trim(),
          "timestamp": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
        };
      } else {
        // Retrieve Foot images
        final currentLfImg = (lfImg64 != null && lfImg64!.isNotEmpty)
            ? lfImg64
            : AppPreference().getString("LF_IMG_${widget.diagnosis_id}_${widget.patient_id}");
        final currentRfImg = (rfImg != null && rfImg!.isNotEmpty)
            ? rfImg
            : AppPreference().getString("RF_IMG_${widget.diagnosis_id}_${widget.patient_id}");

        // Optimize all 4 images concurrently to prevent ModSecurity 406 WAF filter triggers
        final results = await Future.wait([
          _optimizeBase64Image(currentLfImg),
          _optimizeBase64Image(currentLhImg),
          _optimizeBase64Image(currentRhImg),
          _optimizeBase64Image(currentRfImg),
        ]);

        final optimizedLfImg = results[0];
        final optimizedLhImg = results[1];
        final optimizedRhImg = results[2];
        final optimizedRfImg = results[3];

        debugPrint("Optimized Images payload check:");
        debugPrint("  LF Image: ${optimizedLfImg.isEmpty ? 'none' : '~${optimizedLfImg.length ~/ 1024} KB'}");
        debugPrint("  LH Image: ${optimizedLhImg.isEmpty ? 'none' : '~${optimizedLhImg.length ~/ 1024} KB'}");
        debugPrint("  RH Image: ${optimizedRhImg.isEmpty ? 'none' : '~${optimizedRhImg.length ~/ 1024} KB'}");
        debugPrint("  RF Image: ${optimizedRfImg.isEmpty ? 'none' : '~${optimizedRfImg.length ~/ 1024} KB'}");

        final currentLfData = (lfData != null && lfData!.isNotEmpty) ? lfData! : "";
        final currentLfResult = (lfResult != null && lfResult!.isNotEmpty) ? lfResult! : "";
        final currentRfData = (rfData != null && rfData!.isNotEmpty) ? rfData! : "";
        final currentRfResult = (rfResult != null && rfResult!.isNotEmpty) ? rfResult! : "";

        // 🔹 ALL 18 FORM DATA FIELDS FOR FOOT DIAGNOSIS
        formFields = <String, String>{
          "pid": pid,
          "patient_id": widget.patient_id?.toString() ?? "",
          "timestamp": DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
          "is_satisfied": satisfaction ?? "Yes",
          "problems_matched": matchedProblem.text.trim(),
          "not_detected": notDetected.text.trim(),
          "lf_data": currentLfData,
          "lh_data": currentLhData,
          "lf_result": currentLfResult,
          "lh_result": currentLhResult,
          "lf_img": optimizedLfImg,
          "lh_img": optimizedLhImg,
          "rh_data": currentRhData,
          "rf_data": currentRfData,
          "rh_result": currentRhResult,
          "rf_result": currentRfResult,
          "rh_img": optimizedRhImg,
          "rf_img": optimizedRfImg,
        };
      }

      if (widget.isEdit && widget.diagnosis_id != null) {
        formFields["diagnosisId"] = widget.diagnosis_id.toString();
        formFields["diagnosis_id"] = widget.diagnosis_id.toString();
        debugPrint("  diagnosisId: ${widget.diagnosis_id}");
      }

      final uri = Uri.parse(targetUrl);
      final request = http.MultipartRequest('POST', uri);

      // Headers matching Postman; let http.MultipartRequest generate boundary automatically
      request.headers['Accept'] = 'application/json, text/plain, */*';
      request.headers['User-Agent'] = 'PostmanRuntime/7.43.0';

      // Add all form fields
      request.fields.addAll(formFields);

      // 🔹 GENERATE & PRINT EXACT CURL COMMAND
      final curlCommand = _buildCurlCommand(targetUrl, request.headers, formFields);
      _printCurlCommand(curlCommand, formFields);
      try {
        await Clipboard.setData(ClipboardData(text: curlCommand));
        debugPrint("📋 [CLIPBOARD] Full cURL command copied to device clipboard!");
      } catch (_) {}

      debugPrint("Request field keys (${request.fields.length}): ${request.fields.keys.toList()}");
      debugPrint("Request headers: ${request.headers}");

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final response = await http.Response.fromStream(streamedResponse);

      progressTimer.cancel();
      if (mounted) setState(() => uploadProgress = 100);

      final statusCode = response.statusCode;
      final contentType = response.headers['content-type'] ?? '';
      final rawBody = response.body.trim();

      debugPrint("----------------- SERVER RESPONSE -----------------");
      debugPrint("STATUS CODE => $statusCode");
      debugPrint("RESPONSE CONTENT TYPE => $contentType");
      debugPrint("RESPONSE BODY LENGTH => ${rawBody.length} bytes");

      // Handle HTTP 406 ModSecurity or HTML responses safely without crashing on JSON parsing
      if (statusCode == 406 || (contentType.contains('text/html') && rawBody.toLowerCase().contains('mod_security'))) {
        debugPrint("❌ [MOD_SECURITY 406 DETECTED]");
        debugPrint("The request was blocked by server-side Apache ModSecurity filter.");
        debugPrint("Note: The server administrator must inspect the ModSecurity audit log to review the triggered rule ID.");
        if (mounted) {
          showSnack(
            context,
            "Server security filter blocked the request (HTTP 406). Please contact administrator.",
            error: true,
          );
        }
        return;
      }

      if (statusCode != 200 && contentType.contains('text/html')) {
        debugPrint("❌ [SERVER ERROR $statusCode]: Non-JSON HTML response received.");
        if (mounted) {
          showSnack(context, "Server Error ($statusCode). Please try again.", error: true);
        }
        return;
      }

      dynamic jsonData;
      if (rawBody.startsWith('{') || rawBody.startsWith('[')) {
        try {
          jsonData = jsonDecode(rawBody);
          debugPrint("PARSED JSON => $jsonData");
        } catch (e) {
          debugPrint("Failed to parse JSON directly: $e");
        }
      }

      // Fallback clean extraction if PHP notices are present
      if (jsonData == null && rawBody.contains('{')) {
        final cleanText = rawBody.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        final startIdx = cleanText.indexOf('{');
        final endIdx = cleanText.lastIndexOf('}');
        if (startIdx != -1 && endIdx != -1 && endIdx > startIdx) {
          try {
            jsonData = jsonDecode(cleanText.substring(startIdx, endIdx + 1));
            debugPrint("EXTRACTED JSON => $jsonData");
          } catch (e) {
            debugPrint("Fallback JSON parse error: $e");
          }
        }
      }

      debugPrint("===================================================\n");

      if (statusCode == 200 &&
          jsonData != null &&
          (jsonData['success'] == 1 || jsonData['status'] == true)) {
        debugPrint("✅ SUCCESS: Diagnosis Submitted Successfully! Message: ${jsonData['message']}");
        // Clear all cached diagnosis data so next "add new" starts completely fresh
        await AppPreference().clearDiagnosisDrafts(patientId: widget.patient_id?.toString());
        if (mounted) {
          showSnack(context, "Diagnosis Submitted Successfully!");
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        String errorMsg = "Server Error";
        if (jsonData is Map && jsonData['message'] != null) {
          errorMsg = jsonData['message'].toString();
        } else if (statusCode != 200) {
          errorMsg = "Server Error (Status $statusCode)";
        } else {
          errorMsg = "Server returned invalid response";
        }
        debugPrint("❌ [API ERROR OCCURRED] => $errorMsg");
        if (mounted) {
          showSnack(context, errorMsg, error: true);
        }
      }
    } catch (e, stackTrace) {
      progressTimer.cancel();
      debugPrint("\n❌❌❌ [API EXCEPTION] ❌❌❌");
      debugPrint("Exception: $e");
      debugPrint("StackTrace:\n$stackTrace");
      debugPrint("===================================================\n");
      if (mounted) {
        showSnack(context, "Error: $e", error: true);
      }
    } finally {
      progressTimer.cancel();
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _loadingButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: uploadProgress / 100,
              strokeWidth: 3,
              backgroundColor: Colors.green.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "${uploadProgress.toStringAsFixed(0)}%",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
