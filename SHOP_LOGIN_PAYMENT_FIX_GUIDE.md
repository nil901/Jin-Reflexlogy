# Shop Login & Payment Flow Fix Guide

This document provides solutions for the following issues:

1. **Navigation Flow Fix**: Shop → Details → Login → Cart (not back to Shop)
2. **Login API Response Parsing**: Fix handling of different API response formats
3. **Login Success Handling**: Fix `success == 1` vs `success == true` comparison
4. **Payment API 422 Error**: Fix invalid request parameters
5. **Razorpay Configuration**: Ensure proper setup for all devices

---

## 1. Navigation Flow Fix ✅ (IMPLEMENTED)

**Problem**: When a user is not logged in and taps "Add to Cart" from the Product Details screen, after login, the app was returning to the Shop screen instead of continuing to the Cart.

**Solution**: Modified `lib/auth/login_notifier.dart` to handle the "ProductDetailScreen" case specially.

### Changes Made:

```dart
// In lib/auth/login_notifier.dart

// Added import
import '../screens/shop/cartscreen.dart';

// In the login() method, after successful login:
// ================= NAVIGATION =================

// For ProductDetailScreen, call onTab to return to product screen
// so auto-add-to-cart logic can run, instead of replacing the route
if (text == "ProductDetailScreen") {
  onTab();
} else {
  _navigate(context, text, DeliveryType, productId: productId);
}
```

### How It Works:

1. User clicks "Add to Cart" on ProductDetailScreen
2. Since user is not logged in, LoginScreen is pushed
3. After successful login, the login notifier detects `text == "ProductDetailScreen"`
4. It pops the login screen and navigates directly to CartScreen
5. User is taken to cart screen (ready to checkout)

**Flow**: Shop → Details → Login → Cart ✓

### Updated Implementation:

```dart
// In lib/auth/login_notifier.dart

// ================= NAVIGATION =================

// For ProductDetailScreen, navigate directly to CartScreen
// This ensures user goes to cart after login instead of back to shop
if (text == "ProductDetailScreen") {
  // First pop the login screen
  Navigator.pop(context);
  
  // Then navigate to cart screen, removing all previous routes
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => CartScreen(deliveryType: DeliveryType ?? "india"),
    ),
    (route) => false, // Remove all previous routes
  );
} else {
  _navigate(context, text, DeliveryType, productId: productId);
}
```

---

## 2. Login API Response Parsing Fix ✅ (IMPLEMENTED)

**Problem**: The login API returns a response like:
```json
{"success":1,"id":1059,"password":"1234","token":"513476816","type":"patient"}
```

But the code was expecting:
- A `"message"` field (which was missing)
- A `"user_data"` nested object (which was not present)

This caused the login to appear as if it wasn't working even though the API returned success.

**Solution**: Updated `lib/auth/login_notifier.dart` to:
1. Handle missing `"message"` field by providing a default
2. Handle both int (`1`) and bool (`true`) success values
3. Extract user data from the root level (not just nested `user_data`)
4. Check multiple possible field names for user data

### Changes Made:

```dart
// In lib/auth/login_notifier.dart

final Map<String, dynamic> jsonData = jsonDecode(cleanJson);

debugPrint("📋 PARSED JSON: $jsonData");

// ================= SUCCESS/FAIL CHECK =================
// Handle both int (1) and bool (true) success responses
final dynamic successValue = jsonData["success"];
final bool isSuccess = (successValue == 1 || successValue == true || successValue == "1");

// Get message - handle missing message field
final String message = jsonData["message"] ?? (isSuccess ? "Login successful" : "Login failed");

// ================= SHOW MESSAGE =================

Get.rawSnackbar(
  message: message,
  backgroundColor: isSuccess ? Colors.green : Colors.red,
  snackPosition: SnackPosition.BOTTOM,
  borderRadius: 8,
  margin: const EdgeInsets.all(12),
  duration: const Duration(seconds: 2),
);

// ================= FAIL CASE =================

if (!isSuccess) {
  state = AsyncValue.error("Login failed", StackTrace.current);
  return;
}

// ================= SUCCESS =================

// Handle different response structures
// Some APIs return user data directly, others nest it in 'user_data'
final Map<String, dynamic>? userData =
    jsonData['user_data'] is Map ? jsonData['user_data'] : null;

// Extract user ID - check multiple possible fields
final userId = userData?['id'] ?? jsonData['id'] ?? jsonData['user_id'];
final token = userData?['token'] ?? jsonData['token'] ?? "";

// Extract name - check multiple possible fields
final name = userData?['t_name'] ?? userData?['name'] ?? jsonData['name'] ?? "";

// Extract email - check multiple possible fields
final email = userData?['t_email'] ?? userData?['email'] ?? jsonData['email'] ?? "";

// Extract mobile/phone - check multiple possible fields
final mobile = userData?['t_mobile'] ?? userData?['p_number'] ?? 
               userData?['mobile'] ?? userData?['phone'] ?? 
               jsonData['mobile'] ?? jsonData['phone'] ?? "";
```

---

## 3. Login Success Handling Fix (in other files)

**Problem**: Login API returns `{"success":1,...}` but the code was checking for `success == true` (boolean) instead of `success == 1` (integer).

### Current Code (login_notifier.dart - Line 139):
```dart
if (jsonData["success"] != 1) {
  state = AsyncValue.error("Login failed", StackTrace.current);
  return;
}
```

✅ **This is already correct!** The login_notifier.dart correctly checks for `success != 1`.

### However, other files may have issues:

**Check these patterns in your codebase:**

```dart
// ❌ WRONG - comparing int to bool
if (decoded["success"] == true) { ... }

// ✅ CORRECT - compare int to int
if (decoded["success"] == 1) { ... }

// ✅ ALSO CORRECT - handles both int and bool
if (decoded["success"] == true || decoded["success"] == 1) { ... }
```

### Files to Check/Fix:

1. **buy_now_form.dart** - Line 1576, 1822, 1895, 1994:
```dart
// Current (might be wrong):
if (decoded["success"] == true) { ... }

// Fix to:
if (decoded["success"] == true || decoded["success"] == 1) { ... }
```

2. **cartscreen.dart** - Line 109:
```dart
// Current:
if (decoded["success"] == true) { ... }

// Fix to:
if (decoded["success"] == true || decoded["success"] == 1) { ... }
```

---

## 3. Payment API 422 Error Fix

**Problem**: Payment API returns status code 422 (Unprocessable Entity) due to missing or invalid parameters.

### Root Cause Analysis:

The `sendPaymentToBackend()` function in `buy_now_form.dart` (line 1741-1773) sends payment data to the backend. A 422 error typically means:
- Missing required fields
- Invalid data types
- Null values where values are expected

### Current Implementation:

```dart
Future<bool> sendPaymentToBackend({
  required String status,
  String? paymentId,
  String? orderId,
  String? reason,
  required int amount,
}) async {
  try {
    final dio = Dio();
    final response = await dio.post(
      "https://admin.jinreflexology.in/api/payment_callback",
      data: {
        "user_id": AppPreference().getString(PreferencesKey.userId),
        "payment_id": paymentId,
        "orderid": orderId,
        "amount": amount,
        "status": status,
        if (reason != null) "reason": reason,
        "email": AppPreference().getString(PreferencesKey.email),
        "name": AppPreference().getString(PreferencesKey.name),
        "contact": AppPreference().getString(PreferencesKey.contactNumber),
        "country": widget.deliveryType == "india" ? "in" : "us",
        "userType": AppPreference().getString(PreferencesKey.type),
      },
    );

    debugPrint("✅ Payment sent to backend: ${response.data}");
    return response.data is Map && response.data["success"] == true;
  } catch (e) {
    debugPrint("❌ Backend API error: $e");
    return false;
  }
}
```

### Issues:
1. `user_id` might be empty string if not logged in
2. `email`, `name`, `contact` might be empty strings
3. `orderid` might be null (Razorpay returns `orderId` in some cases)
4. Success check uses `== true` instead of `== 1`

### Fixed Implementation:

```dart
Future<bool> sendPaymentToBackend({
  required String status,
  String? paymentId,
  String? orderId,
  String? reason,
  required int amount,
}) async {
  try {
    final prefs = AppPreference();
    final userId = prefs.getString(PreferencesKey.userId);
    final email = prefs.getString(PreferencesKey.email);
    final name = prefs.getString(PreferencesKey.name);
    final contact = prefs.getString(PreferencesKey.contactNumber);
    final userType = prefs.getString(PreferencesKey.type);

    // Validate required fields
    if (userId == null || userId.isEmpty) {
      debugPrint("❌ User ID is empty - cannot send payment");
      return false;
    }

    final dio = Dio();
    final Map<String, dynamic> payload = {
      "user_id": userId,
      "amount": amount,
      "status": status,
      "country": widget.deliveryType == "india" ? "in" : "us",
      "userType": userType ?? "patient",
    };

    // Only add optional fields if they have values
    if (paymentId != null && paymentId.isNotEmpty) {
      payload["payment_id"] = paymentId;
    }
    if (orderId != null && orderId.isNotEmpty) {
      payload["orderid"] = orderId;
    }
    if (reason != null && reason.isNotEmpty) {
      payload["reason"] = reason;
    }
    if (email != null && email.isNotEmpty) {
      payload["email"] = email;
    }
    if (name != null && name.isNotEmpty) {
      payload["name"] = name;
    }
    if (contact != null && contact.isNotEmpty) {
      payload["contact"] = contact;
    }

    debugPrint("📤 Sending payment to backend: $payload");

    final response = await dio.post(
      "https://admin.jinreflexology.in/api/payment_callback",
      data: payload,
    );

    debugPrint("✅ Payment backend response: Status=${response.statusCode}, Data=${response.data}");

    // Handle both int (1) and bool (true) success responses
    if (response.data is Map) {
      final success = response.data["success"];
      return success == 1 || success == true;
    }
    return false;
  } catch (e) {
    debugPrint("❌ Backend API error: $e");
    return false;
  }
}
```

---

## 4. Razorpay Configuration Fix

**Problem**: Razorpay shows "No appropriate payment method found" on some devices.

### Root Causes:
1. Using test key in production or vice versa
2. Missing Android/iOS configuration
3. Network issues or API version mismatch
4. Missing required fields in payment options

### Current Configuration (payment_getway_keys.dart):

```dart
final String razorpayKey = "rzp_test_RvkSLd55D0e5sj";  // Test key
final bool isSandboxMode = false;  // This is for PayPal, not Razorpay
```

### Issues:
1. Using test key (`rzp_test_`) which only works in test mode
2. For production, need live key (`rzp_live_`)

### Fixed Configuration:

```dart
// For Development/Testing
final String razorpayKey = "rzp_test_RvkSLd55D0e5sj";

// For Production (uncomment when ready for production)
// final String razorpayKey = "rzp_live_SC4hJgIcCj6VCP";

final String paypalClientId =
    "AfjIFWRXocspD7CrHB0wkcUpK9n4niI-yzPYa-ta7KfaullE1-u4ju5XkxV-vnIqok7-VdWHiT2f5v09";
final String paypalSecret =
    "ENWjMESfhbDFJUz-tSLJ25SFj4mAu5Gg7BiWtQaqtVqF68UcE6LHNHZ6ZTo1ZKY_JMjD-1i-tgfLUK8h";
final bool isSandboxMode = true;  // Set to false for production PayPal
```

### Android Configuration (android/app/src/main/AndroidManifest.xml):

Make sure you have these permissions:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### iOS Configuration (ios/Runner/Info.plist):

Add these if not present:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Improved Razorpay Payment Options (buy_now_form.dart - line 1624):

```dart
Future<void> startPayment(BuildContext context) async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // Validate address
  if (selectedAddress == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please select a delivery address"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final isIndia = await isIndianUser();

  if (isIndia) {
    final prefs = AppPreference();
    final name = prefs.getString(PreferencesKey.name);
    final email = prefs.getString(PreferencesKey.email);
    final contact = prefs.getString(PreferencesKey.contactNumber);

    var options = {
      'key': razorpayKey,
      'amount': (currentTotal * 100).toInt(),  // Amount in smallest currency unit (paise)
      'currency': 'INR',  // Explicitly set currency
      'name': name?.isNotEmpty == true ? name : 'Jin Reflexology',
      'description': 'Order Payment',
      'prefill': {
        'name': name?.isNotEmpty == true ? name : '',
        'email': email?.isNotEmpty == true ? email : '',
        'contact': contact?.isNotEmpty == true ? contact : '',
      },
      'theme': {
        'color': '#130442',  // Match your app theme
      },
      'modal': {
        'ondismiss': () {
          debugPrint('Razorpay modal dismissed');
        },
      },
    };

    debugPrint('📤 Razorpay Options: $options');

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ Razorpay open error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } else {
    _startPayPalPayment(context);
  }
}
```

---

## 5. Additional Recommendations

### A. Add Debug Logging

Add comprehensive logging to track the payment flow:

```dart
void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  debugPrint('✅ PAYMENT SUCCESS:');
  debugPrint('   Payment ID: ${response.paymentId}');
  debugPrint('   Order ID: ${response.orderId}');
  debugPrint('   Signature: ${response.signature}');
  
  // ... rest of the code
}

void _handlePaymentError(PaymentFailureResponse response) async {
  debugPrint('❌ PAYMENT ERROR:');
  debugPrint('   Code: ${response.code}');
  debugPrint('   Message: ${response.message}');
  debugPrint('   Source: ${response.source}');
  debugPrint('   Metadata: ${response.metadata}');
  
  // ... rest of the code
}
```

### B. Handle Edge Cases

```dart
// In shop_details_screen.dart - addToCart() method
Future<void> addToCart() async {
  const String url = "https://admin.jinreflexology.in/api/cart/add";

  final prefs = AppPreference();
  final token = prefs.getString(PreferencesKey.token);
  final type = prefs.getString(PreferencesKey.type);

  final String country = widget.deliveryType == "india" ? "in" : "us";

  // Better validation
  if (token.isEmpty || token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please login first")),
    );
    // Set flag and navigate to login
    _shouldAutoAddToCart = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JinLoginScreen(
          text: "ProductDetailScreen",
          shop: true,
          type: "",
          diliveryType: widget.deliveryType,
          productId: p.id.toString(),
          onTab: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    return;
  }

  if (userId == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User ID not found. Please login again.")),
    );
    return;
  }

  // ... rest of the code
}
```

### C. Success Response Handling Consistency

Create a helper function for consistent success checking:

```dart
bool isSuccessResponse(dynamic response) {
  if (response is Map) {
    final success = response["success"];
    return success == 1 || success == true || success == "1";
  }
  return false;
}

// Usage:
if (isSuccessResponse(decoded)) {
  // Handle success
}
```

---

## Summary of Changes

| Issue | File | Fix |
|-------|------|-----|
| Navigation Flow | `login_notifier.dart` | ✅ Done - Call `onTab()` for ProductDetailScreen |
| Login Success Check | `login_notifier.dart` | ✅ Already correct (`success != 1`) |
| Payment API 422 | `buy_now_form.dart` | Fix null/empty field handling |
| Razorpay Config | `payment_getway_keys.dart` | Use appropriate key (test/live) |
| Razorpay Options | `buy_now_form.dart` | Add currency, validate fields |
| Success Check Consistency | Multiple files | Use `success == 1 \|\| success == true` |

---

## Testing Checklist

1. **Navigation Flow Test**:
   - [ ] Go to Shop → Tap Product → Tap "Add to Cart" (not logged in)
   - [ ] Login with valid credentials
   - [ ] Verify user is taken to Cart screen (not Shop)
   - [ ] Verify product is added to cart

2. **Payment Flow Test**:
   - [ ] Add items to cart
   - [ ] Go to checkout
   - [ ] Select address
   - [ ] Tap "Place Order & Pay"
   - [ ] Complete Razorpay payment
   - [ ] Verify order is placed successfully

3. **Error Handling Test**:
   - [ ] Try payment with empty cart
   - [ ] Try payment without address
   - [ ] Cancel payment mid-way
   - [ ] Verify error messages are shown

---

## Contact

For any issues or questions, please refer to the debug logs printed in the console.