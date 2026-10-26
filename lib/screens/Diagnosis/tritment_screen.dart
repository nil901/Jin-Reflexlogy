import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jin_reflex_new/api_service/api_service.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/main.dart'; // routeObserver
import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_balance_guard.dart';
import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_details_card.dart';
import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_record_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';

/// -------------------------------------------------------
/// MODEL
/// -------------------------------------------------------
class DiagnosisData {
  final String id;
  final String timestamp;

  DiagnosisData({required this.id, required this.timestamp});

  factory DiagnosisData.fromJson(Map<String, dynamic> json) {
    return DiagnosisData(
      id: json['id'].toString(),
      timestamp: json['timestamp'] ?? "",
    );
  }
}

/// -------------------------------------------------------
/// MAIN SCREEN
/// -------------------------------------------------------
class DiagnosisListScreen extends StatefulWidget {
  final String patientName;
  final String patientId;
  final String pid;
  final String diagnosisId;
  final String? gender;

  const DiagnosisListScreen({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.pid,
    required this.diagnosisId,
    this.gender,
  });

  @override
  State<DiagnosisListScreen> createState() => _DiagnosisListScreenState();
}

class _DiagnosisListScreenState extends State<DiagnosisListScreen>
    with RouteAware {
  List<DiagnosisData> diagnosisList = [];
  bool isLoading = true;
  bool _isSubscribed = false;
  bool _isOpeningDiagnosis = false;

  @override
  void initState() {
    super.initState();
    fetchDiagnosisList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute && !_isSubscribed) {
      routeObserver.subscribe(this, route);
      _isSubscribed = true;
    }
  }

  @override
  void didPopNext() {
    fetchDiagnosisList(); // refresh on back
  }

  @override
  void dispose() {
    if (_isSubscribed) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  Future<void> fetchDiagnosisList() async {
    setState(() => isLoading = true);

    try {
      final formData = {
        "pid": widget.pid.toString(),
        "patient_id": widget.patientId.toString(),
      };

      final response = await ApiService().postRequest(
        "https://jinreflexology.in/api1/new/list_diagnosis.php",
        formData,
      );

      dynamic jsonBody =
          response?.data is String
              ? jsonDecode(response!.data)
              : response?.data;

      if (jsonBody != null && jsonBody["success"] == 1) {
        final List raw = jsonBody["data"];
        diagnosisList = raw.map((e) => DiagnosisData.fromJson(e)).toList();
      } else {
        diagnosisList = [];
      }
    } catch (e) {
      diagnosisList = [];
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Treatment"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_isOpeningDiagnosis) return;
          setState(() => _isOpeningDiagnosis = true);
          try {
            final selectedPart = await showDiagnosisTypeDialog(context);
            if (selectedPart == null || !mounted) return;

            final hasBalance = await ensureDiagnosisBalanceAvailable(
              context,
              part: selectedPart,
            );
            if (!hasBalance || !mounted) return;

            final submitted = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => DiagnosisScreen(
                      patient_id: widget.patientId,
                      name: widget.patientName,
                      diagnosis_id: null,
                      gender: widget.gender,
                      part: selectedPart,
                      isNew: true,
                    ),
              ),
            );

            if (submitted == true && mounted) {
              fetchDiagnosisList();
            }
          } finally {
            if (mounted) setState(() => _isOpeningDiagnosis = false);
          }
        },
        backgroundColor: Colors.orange.shade300,
        label: const Text(
          "Add +",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: const Color(0xFFFDF3DD),

      /// -------------------------------------------------------
      /// FULL BODY SCROLL USING ListView
      /// -------------------------------------------------------
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              )
              : ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // Patient Name Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Patient Name : ${widget.patientName}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Patient ID Pill
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: pill("Patient ID : ${widget.patientId}"),
                  ),

                  const SizedBox(height: 12),

                  // Diagnosis List Header (optional)
                  if (diagnosisList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          "No diagnosis records found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...diagnosisList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final parts = item.timestamp.split(" ");
                      final date = parts[0];
                      final time = parts.length > 1 ? parts[1] : "";

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => DiagnosisDetailsCard(
                                    patientId: widget.patientId,
                                    patientName: widget.patientName,
                                    diagnosisId: item.id,
                                    date: date,
                                    time: time,
                                    title: "Day: ${index + 1}",
                                    gender: widget.gender,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${item.id}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 80), // Extra bottom space for FAB
                ],
              ),
    );
  }

  Widget pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
