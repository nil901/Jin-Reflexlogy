import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_payment_helper.dart';
import 'package:jin_reflex_new/screens/Diagnosis/diagnosis_record_screen.dart';

Future<bool> ensureDiagnosisBalanceAvailable(
  BuildContext context, {
  DiagnosisPart? part,
}) async {
  try {
    final therapistId = AppPreference().getString(PreferencesKey.userId);

    if (therapistId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to verify balance. Please login again."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    Future<double> fetchBalance() async {
      final response = await http.post(
        Uri.parse("https://jinreflexology.in/api1/new/getTherapistBalance.php"),
        body: {"therapistId": therapistId},
      );

      final data = jsonDecode(response.body);
      if (data["success"] != 1) return 0;
      final footVal = (data["balance"] ??
              data["wallet_balance"] ??
              data["available_balance"] ??
              0)
          .toString();
      final handVal = (data["hand_balance"] ?? 0).toString();
      final foot = double.tryParse(footVal) ?? 0;
      final hand = double.tryParse(handVal) ?? 0;

      if (part == DiagnosisPart.hand) {
        return hand;
      } else if (part == DiagnosisPart.foot) {
        return foot;
      }
      return (foot > 0 || hand > 0) ? (foot + hand) : 0;
    }

    double balance = await fetchBalance();

    if (balance <= 0) {
      final bool paid = await showDiagnosisPaymentPopup(context);
      if (!paid) {
        return false;
      }

      for (int attempt = 0; attempt < 4; attempt++) {
        await Future.delayed(Duration(milliseconds: 800 + (attempt * 700)));
        balance = await fetchBalance();
        if (balance > 0) {
          break;
        }
      }

      if (balance <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Payment completed. Balance is updating, please try diagnosis again.",
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    }

    return true;
  } catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Could not check balance. Please try again."),
        backgroundColor: Colors.red,
      ),
    );
    return false;
  }
}
