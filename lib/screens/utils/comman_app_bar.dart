import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TherapistBalances {
  final double footBalance;
  final double handBalance;

  const TherapistBalances({
    this.footBalance = 0,
    this.handBalance = 0,
  });
}

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final bool showBalance;
  final String? userId;
  final int balanceRefreshTrigger;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.onBack,
    this.showBalance = false,
    this.userId,
    this.balanceRefreshTrigger = 0,
  });

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CommonAppBarState extends State<CommonAppBar> {
  Future<TherapistBalances>? _balanceFuture;

  bool get _canShowBalance {
    final id = widget.userId?.trim() ?? '';
    return widget.showBalance && id.isNotEmpty;
  }
  String _currencySymbol = "₹";

  @override
  void initState() {
    super.initState();
    if (_canShowBalance) {
      _balanceFuture = fetchBalance();

      _loadCurrencySymbol();
    }
  }

  @override
  void didUpdateWidget(covariant CommonAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_canShowBalance &&
        (oldWidget.userId != widget.userId ||
            oldWidget.balanceRefreshTrigger != widget.balanceRefreshTrigger)) {
      setState(() {
        _balanceFuture = fetchBalance();
      });
    }
  }

  /// 🔹 FETCH BALANCE (FORM-DATA API)
  Future<TherapistBalances> fetchBalance() async {
    final therapistId = widget.userId?.trim() ?? '';
    if (therapistId.isEmpty) {
      throw Exception("Invalid therapistId");
    }
    // if (therapistId == null || therapistId.isEmpty) {
    //   throw Exception("Invalid therapistId");
    // }
    debugPrint(
      "BALANCE REQUEST therapistId=$therapistId",
    );
    final response = await http.post(
      Uri.parse("https://jinreflexology.in/api1/new/getTherapistBalance.php"),
      body: {"therapistId": therapistId},
    );

    final json = jsonDecode(response.body);
    debugPrint("BALANCE RESPONSE => $json");

    if (json["success"] == 1) {
      final footVal = (json["balance"] ??
              json["wallet_balance"] ??
              json["available_balance"] ??
              0)
          .toString();
      final handVal = (json["hand_balance"] ?? 0).toString();
      return TherapistBalances(
        footBalance: double.tryParse(footVal) ?? 0,
        handBalance: double.tryParse(handVal) ?? 0,
      );
    } else {
      throw Exception(json["message"] ?? "No balance");
    }
  }

  /// 🔹 LOAD ₹ / $
  Future<void> _loadCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currencySymbol =
          prefs.getString("delivery_type") == "india" ? "₹" : "\$";
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 19, 4, 66),
      automaticallyImplyLeading: false,
      centerTitle: false,
     leading: widget.showBack
    ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: widget.onBack ?? () => Navigator.pop(context),
      )
    : null,
      title: Text(
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      actions: [
        if (_canShowBalance)
          FutureBuilder<TherapistBalances>(
            future: _balanceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Center(
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const SizedBox(); // error ignore
              }

              final balances =
                  snapshot.data ?? const TherapistBalances();

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Foot balance badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("🦶", style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(
                            "$_currencySymbol${balances.footBalance.toInt()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Hand balance badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("✋", style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Text(
                            "$_currencySymbol${balances.handBalance.toInt()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        ...?widget.actions,
      ],
    );
  }
}

class ApiServices {
  static const baseUrl = 'https://jinreflexology.in/api1/new/';

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, String> body,
  ) async {
    final response = await http.post(Uri.parse(baseUrl + endpoint), body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API failed');
    }
  }
}

final therapistBalanceProvider = FutureProvider.family<int, String>((
  ref,
  therapistId,
) async {
  final res = await ApiServices.post('getTherapistBalance.php', {
    'therapistId': therapistId,
  });

  if (res['success'] == 1) {
    return res['balance'];
  } else {
    throw Exception('No balance');
  }
});
