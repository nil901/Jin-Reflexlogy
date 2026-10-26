import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:http/http.dart' as http;

import 'package:jin_reflex_new/api_service/payment_getway_keys.dart';
import 'package:jin_reflex_new/api_service/prefs/PreferencesKey.dart';
import 'package:jin_reflex_new/api_service/prefs/app_preference.dart';
import 'package:jin_reflex_new/login_screen.dart';
import 'package:jin_reflex_new/main.dart';
import 'package:jin_reflex_new/model/dignosis_list_model.dart';
import 'package:jin_reflex_new/screens/Diagnosis/add_patient_screen.dart';
import 'package:jin_reflex_new/screens/Diagnosis/tritment_screen.dart';
import 'package:jin_reflex_new/screens/utils/comman_app_bar.dart';
import 'package:jin_reflex_new/services/auth_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberListScreen extends StatefulWidget {
  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> with RouteAware {
  String getLimitedName({required String text, required double screenWidth}) {
    // 1️⃣ numbers remove
    final withoutNumbers = text.replaceAll(RegExp(r'\d'), '');

    // 2️⃣ clean extra spaces
    final cleanText = withoutNumbers.trim().replaceAll(RegExp(r'\s+'), ' ');

    // 3️⃣ decide character limit
    final int charLimit = screenWidth < 600 ? 22 : 32;

    // 4️⃣ apply limit
    if (cleanText.length <= charLimit) {
      return cleanText;
    }
    return cleanText.substring(0, charLimit);
  }

  List<PatientData> patients = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  bool hasMore = true;
  int page = 1;
  final int limit = 30;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _currentSearchText = '';
  Timer? _searchDebounceTimer;
  late Razorpay _razorpay;
  final TextEditingController amountController = TextEditingController();
  bool showValidation = false;
  int _balanceRefreshTrigger = 0;
  double _footBalance = 0;
  double _handBalance = 0;
  String _currencySymbol = "₹";

  @override
  void initState() {
    super.initState();
    print("🎯 initState called");
    fetchPatients(isInitial: true);
    fetchTherapistWallet();
    scrollController.addListener(_scrollListener);
    searchController.addListener(_onSearchChanged);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> fetchTherapistWallet() async {
    final token = AppPreference().getString(PreferencesKey.userId);
    if (token.isEmpty || !AuthService().isTherapistLoggedIn()) return;
    try {
      final response = await http.post(
        Uri.parse("https://jinreflexology.in/api1/new/getTherapistBalance.php"),
        body: {"therapistId": token},
      );
      final json = jsonDecode(response.body);
      if (json["success"] == 1 && mounted) {
        final footVal = (json["balance"] ??
                json["wallet_balance"] ??
                json["available_balance"] ??
                0)
            .toString();
        final handVal = (json["hand_balance"] ?? 0).toString();
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _footBalance = double.tryParse(footVal) ?? 0;
          _handBalance = double.tryParse(handVal) ?? 0;
          _currencySymbol =
              prefs.getString("delivery_type") == "india" ? "₹" : "\$";
        });
      }
    } catch (e) {
      debugPrint("Therapist wallet fetch error: $e");
    }
  }

  List<Color> _getAvatarGradient(String name) {
    const gradients = [
      [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      [Color(0xFF0284C7), Color(0xFF06B6D4)],
      [Color(0xFF059669), Color(0xFF10B981)],
      [Color(0xFFEA580C), Color(0xFFF97316)],
      [Color(0xFFDB2777), Color(0xFFF43F5E)],
      [Color(0xFF7C2D12), Color(0xFFC2410C)],
    ];
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % gradients.length;
    return gradients[index];
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (currentScroll >= maxScroll - 100 &&
        !isFetchingMore &&
        hasMore &&
        _currentSearchText.isEmpty) {
      print("🎯 Scroll reached bottom, fetching more...");
      print("📊 Current scroll: $currentScroll, Max: $maxScroll");
      print("📊 Page: $page, HasMore: $hasMore");
      fetchPatients();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    // 🔥 screen visible again → fresh load
    fetchPatients(isInitial: true);
    fetchTherapistWallet();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    searchController.dispose();
    amountController.dispose();
    _searchFocusNode.dispose();
    _searchDebounceTimer?.cancel();
    _razorpay.clear();
    super.dispose();
  }

  // ---------------- SEARCH HANDLER ----------------
void _onSearchChanged() {
  _searchDebounceTimer?.cancel();

  _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
    if (!mounted) return;

    final newText = searchController.text.trim();  

    _currentSearchText = newText;

    // 🔥 force reset fetching
    isFetchingMore = false;

    fetchPatients(isInitial: true, search: newText);
  });
}

  // FIXED: fetchPatients function
  Future<void> fetchPatients({
    bool isInitial = false,
    String search = '',
  }) async {
    print("\n" + "=" * 60);
    print("🚀 FETCHING PATIENTS");
    print("📌 isInitial: $isInitial");
    print("📌 Current Page: $page");
    print("📌 Search Text: '$search'");
    print("📌 isFetchingMore: $isFetchingMore");
    print("📌 hasMore: $hasMore");
    print("📌 Current Patients: ${patients.length}");
    print("=" * 60);
    if (isFetchingMore) {
      print("⏸️ Already fetching, skipping...");
      return;
    }
    if (search.isNotEmpty && !isInitial) {
      print("⚠️ Search active, pagination stopped");
      return;
    }

    int fetchPage = isInitial ? 1 : page;
    setState(() {
      if (isInitial) {
        page = 1;
        hasMore = true;
        patients.clear();
        isLoading = true;
      }
      isFetchingMore = true;
    });

    try {
      var url = Uri.parse(
        'https://jinreflexology.in/api1/new/list_patients.php',
      );

      Map<String, String> body = {
        'pid': AppPreference().getString(PreferencesKey.userId),
        'page': fetchPage.toString(),
        'limit': limit.toString(),
      };

      if (search.isNotEmpty) {
        body['search'] = search;
      }
      print("🌐 API Request Details:");
      print("   URL: $url");
      print("   Body: $body");
      print("   Fetching Page: $fetchPage");

      var response = await http.post(
        url,
headers: {'Content-Type': 'application/x-www-form-urlencoded'},  
        body: body,
      );

      print("📥 API Response:");
      print("   Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        var jsonBody = jsonDecode(response.body);
        print("   Success: ${jsonBody['success']}");

        final List raw = jsonBody["data"] ?? [];
        print("   Data Items Received: ${raw.length}");

                if (jsonBody['success'] == 1) {
          final newList = raw.map((e) => PatientData.fromJson(e)).toList();

          print("✅ Patients Loaded: ${newList.length}");
          print("📊 Limit: $limit");
          print("📊 HasMore Check: ${newList.length == limit}");

          setState(() {
            if (isInitial) {
              patients = newList;
            } else {
              patients.addAll(newList);
            }

            isLoading = false;
            isFetchingMore = false;

            // Update hasMore based on response length
            hasMore = newList.length == limit;

            // Increment page only if we got full page
            if (hasMore && !isInitial) {
              page++;
              print("📈 Page incremented to: $page");
            }

            print("📊 Total Patients Now: ${patients.length}");
            print("📊 HasMore Flag: $hasMore");
          });
        } else {
          print("❌ API Error: ${jsonBody['message']}");
          setState(() {
            isLoading = false;
            isFetchingMore = false;
            hasMore = false;
          });
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        setState(() {
          isLoading = false;
          isFetchingMore = false;
        });
      }
    } catch (e, stackTrace) {
      print("❌ Exception: $e");
      print("❌ StackTrace: $stackTrace");
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
    }
    print("=" * 60 + "\n");
  }

  Future<bool> isIndianUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("delivery_type") == "india";
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Success\nPayment ID: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );

    await sendPaymentToBackend(
      status: "success",
      paymentId: response.paymentId,
      orderId: response.orderId,
      amount: int.tryParse(amountController.text) ?? 0,
    );

    if (!mounted) return;
    setState(() {
      _balanceRefreshTrigger++;
    });
    fetchTherapistWallet();
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed\n${response.message}"),
        backgroundColor: Colors.red,
      ),
    );

    await sendPaymentToBackend(
      status: "failed",
      reason: response.message,
      amount: int.tryParse(amountController.text) ?? 0,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Wallet Used: ${response.walletName}")),
    );
  }

  void _showPaymentPopup() {
    amountController.clear();
    showValidation = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<bool>(
          future: isIndianUser(),
          builder: (context, snapshot) {
            final bool isIndia = snapshot.data ?? true;

            return StatefulBuilder(
              builder: (context, setPopupState) {
                return AlertDialog(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Add Payment',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Enter amount to add balance',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              'Enter Amount ${isIndia ? "(Rs)" : "(\$)"}',
                          border: const OutlineInputBorder(),
                          errorText:
                              showValidation ? 'Minimum 50 required' : null,
                        ),
                        onChanged: (_) {
                          if (showValidation) {
                            setPopupState(() => showValidation = false);
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final amountText = amountController.text.trim();

                        if (amountText.isEmpty ||
                            int.tryParse(amountText) == null ||
                            int.parse(amountText) < 50) {
                          setPopupState(() => showValidation = true);
                          return;
                        }

                        final enteredAmount = int.parse(amountText);
                        Navigator.pop(dialogContext);

                        if (isIndia) {
                          _razorpay.open({
                            'key': razorpayKey,
                            'amount': enteredAmount * 100,
                            'name': AppPreference().getString(
                              PreferencesKey.name,
                            ),
                            'description': 'Wallet Payment',
                            'prefill': {
                              'contact': AppPreference().getString(
                                PreferencesKey.contactNumber,
                              ),
                              'email': AppPreference().getString(
                                PreferencesKey.email,
                              ),
                            },
                          });
                        } else {
                          _startPayPalPayment();
                        }
                      },
                      child: const Text('Pay'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _startPayPalPayment() {
    final String amount = amountController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => PaypalCheckoutView(
              sandboxMode: isSandboxMode,
              clientId: paypalClientId,
              secretKey: paypalSecret,
              transactions: [
                {
                  "amount": {"total": amount, "currency": "USD"},
                  "description": "Wallet / Service Payment",
                },
              ],
              note: "Demo PayPal payment",
              onSuccess: (Map params) async {
                final paypalPaymentId = params["data"]?["id"];
                if (paypalPaymentId == null) {
                  debugPrint("PayPal paymentId null");
                  return;
                }

                await sendPaymentToBackend(
                  status: "success",
                  paymentId: paypalPaymentId,
                  orderId: null,
                  amount: int.tryParse(amountController.text) ?? 0,
                );

                if (!mounted) return;
                setState(() {
                  _balanceRefreshTrigger++;
                });
                fetchTherapistWallet();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("PayPal Payment Successful"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              onError: (error) async {
                await sendPaymentToBackend(
                  status: "failed",
                  reason: error.toString(),
                  amount: int.tryParse(amountController.text) ?? 0,
                );

                if (!mounted) return;
                Navigator.pop(context);
              },
              onCancel: () async {
                if (!mounted) return;
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  Future<void> sendPaymentToBackend({
    required String status,
    String? paymentId,
    String? orderId,
    String? reason,
    required int amount,
  }) async {
    try {
      await http.post(
        Uri.parse("https://admin.jinreflexology.in/api/payment_callback"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": AppPreference().getString(PreferencesKey.userId),
          "payment_id": paymentId,
          "orderid": orderId,
          "amount": amount.toString(),
          "status": status,
          "reason": reason,
          "email": AppPreference().getString(PreferencesKey.email),
          "name": AppPreference().getString(PreferencesKey.name),
          "contact": AppPreference().getString(PreferencesKey.contactNumber),
        }),
      );
    } catch (e) {
      debugPrint("Backend API error: $e");
    }
  }

  // ---------------- UI ----------------
  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Diagnosis Wallet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _showPaymentPopup,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Add Balance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Foot Balance Sub-Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("🦶", style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            "Foot Balance",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$_currencySymbol ${_footBalance.toInt()}",
                        style: const TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Hand Balance Sub-Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("✋", style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            "Hand Balance",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$_currencySymbol ${_handBalance.toInt()}",
                        style: const TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = AppPreference().getString(PreferencesKey.userId);
    final type = AppPreference().getString(PreferencesKey.type);
    final isTherapistLoggedIn = AuthService().isTherapistLoggedIn();

    return Scaffold(
      appBar: CommonAppBar(
        title: "Patient List",
        showBalance: isTherapistLoggedIn,
        userId: isTherapistLoggedIn ? token : null,
        balanceRefreshTrigger: _balanceRefreshTrigger,
        actions: [
          if (isTherapistLoggedIn)
            IconButton(
              tooltip: "Add Balance",
              icon: const Icon(Icons.add_card_rounded, color: Colors.white),
              onPressed: _showPaymentPopup,
            ),
          const SizedBox(width: 4),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body:
          type == "patient" ||
                  type == "user" ||
                  type == "prouser" ||
                  token.isEmpty
              ? JinLoginScreen(
                text: "MemberListScreen",
                type: "therapist",
                registershow: true,
                onTab: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MemberListScreen()),
                  );
                },
              )
              : SafeArea(
                child: Column(
                  children: [
                    // Therapist Wallet Card
                    if (isTherapistLoggedIn) _buildWalletCard(),

                    // SEARCH + ADD BUTTON BAR
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 14),
                                  const Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      focusNode: _searchFocusNode,
                                      decoration: const InputDecoration(
                                        hintText:
                                            "Search by Name, Mobile or ID...",
                                        hintStyle: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 13,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (searchController.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFF94A3B8),
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        searchController.clear();
                                        _currentSearchText = '';
                                        fetchPatients(isInitial: true);
                                      },
                                    ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddPatientScreen(
                                        patientName: '',
                                        patientId: '',
                                        pid: AppPreference().getString(
                                          PreferencesKey.userId,
                                        ),
                                        diagnosisId: '',
                                      ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEA580C).withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // LIST HEADER
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Patients",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  "${patients.length} Total",
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_currentSearchText.isNotEmpty)
                            Text(
                              "Filtered: '$_currentSearchText'",
                              style: const TextStyle(
                                color: Color(0xFFF97316),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // PATIENT LIST
                    Expanded(
                      child:
                          isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFEA580C),
                                ),
                              )
                              : patients.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline_rounded,
                                      color: Colors.grey[400],
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _currentSearchText.isEmpty
                                          ? "No Patients Found"
                                          : "No patients match '$_currentSearchText'",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (_currentSearchText.isNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          searchController.clear();
                                          fetchPatients(isInitial: true);
                                        },
                                        child: const Text(
                                          "Clear Search",
                                          style: TextStyle(
                                            color: Color(0xFFEA580C),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
                              : RefreshIndicator(
                                color: const Color(0xFFEA580C),
                                onRefresh: () async {
                                  await fetchTherapistWallet();
                                  await fetchPatients(isInitial: true);
                                },
                                child: ListView.builder(
                                  controller: scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 24,
                                  ),
                                  itemCount:
                                      patients.length +
                                      (hasMore &&
                                              !isFetchingMore &&
                                              _currentSearchText.isEmpty
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    if (index >= patients.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFEA580C),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final patient = patients[index];

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(
                                          color: Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                      ),
                                      color: Colors.white,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => DiagnosisListScreen(
                                                    patientName: patient.name,
                                                    pid:
                                                        AppPreference()
                                                            .getString(
                                                              PreferencesKey
                                                                  .userId,
                                                            )
                                                            .toString(),
                                                    diagnosisId: patient.id,
                                                    patientId: patient.id,
                                                    gender: patient.gender,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Row(
                                            children: [
                                              // Avatar with gradient
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: _getAvatarGradient(
                                                      patient.name,
                                                    ),
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          _getAvatarGradient(
                                                            patient.name,
                                                          )[0].withOpacity(0.25),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    patient.name.isNotEmpty
                                                        ? patient.name[0]
                                                            .toUpperCase()
                                                        : '?',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Patient Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            patient.name,
                                                            style: const TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color: Color(
                                                                0xFF0F172A,
                                                              ),
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 6),
                                                        // ID Pill
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 2,
                                                              ),
                                                          decoration:
                                                              BoxDecoration(
                                                                color:
                                                                    const Color(
                                                                      0xFFFFF7ED,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      6,
                                                                    ),
                                                                border: Border.all(
                                                                  color: const Color(
                                                                    0xFFFFEDD5,
                                                                  ),
                                                                ),
                                                              ),
                                                          child: Text(
                                                            "#${patient.id}",
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              color: Color(
                                                                0xFFEA580C,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        if (patient
                                                            .mobile
                                                            .isNotEmpty) ...[
                                                          const Icon(
                                                            Icons.phone_outlined,
                                                            size: 13,
                                                            color: Color(
                                                              0xFF64748B,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              patient.mobile,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                  0xFF475569,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                        ],
                                                        if (patient
                                                            .registerationDate
                                                            .isNotEmpty) ...[
                                                          const Icon(
                                                            Icons
                                                                .calendar_today_outlined,
                                                            size: 12,
                                                            color: Color(
                                                              0xFF94A3B8,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Text(
                                                            patient
                                                                .registerationDate,
                                                            style: const TextStyle(
                                                              fontSize: 11,
                                                              color: Color(
                                                                0xFF64748B,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF8FAFC,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE2E8F0,
                                                    ),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  color: Color(0xFF64748B),
                                                  size: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
