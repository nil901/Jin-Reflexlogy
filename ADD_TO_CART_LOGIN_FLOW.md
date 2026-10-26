# Product Detail → Add to Cart → Login Flow

## Overview
This document explains the implemented flow for "Add to Cart" functionality that requires user authentication.

## Flow Diagram

```
┌─────────────────────┐
│  Product Detail     │
│     Screen          │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Click "Add to      │
│     Cart" Button    │
└──────────┬──────────┘
           │
           ▼
    ┌──────┴──────┐
    │             │
    ▼             ▼
┌────────┐   ┌────────────┐
│ Logged │   │ Not Logged │
│  In    │   │    In      │
└───┬────┘   └─────┬──────┘
    │              │
    │              ▼
    │      ┌─────────────────┐
    │      │ Navigate to     │
    │      │ Login Screen    │
    │      │ (with productId)│
    │      └────────┬────────┘
    │               │
    │               ▼
    │      ┌─────────────────┐
    │      │ User Enters     │
    │      │ Credentials     │
    │      └────────┬────────┘
    │               │
    │               ▼
    │      ┌─────────────────┐
    │      │ Login Success   │
    │      │ Save Token/UID  │
    │      └────────┬────────┘
    │               │
    │               ▼
    │      ┌─────────────────┐
    │      │ Navigate to     │
    │      │ ShopScreen      │
    │      └────────┬────────┘
    │               │
    │               ▼
    │      ┌─────────────────┐
    │      │ User finds      │
    │      │ product again   │
    │      │ and clicks      │
    │      │ "Add to Cart"   │
    │      └────────┬────────┘
    │               │
    │               ▼
    ▼      ┌─────────────────┐
    └─────▶│  Call Add to    │
           │  Cart API       │
           └────────┬────────┘
                    │
                    ▼
           ┌─────────────────┐
           │ Show Success    │
           │ Message         │
           └────────┬────────┘
                    │
                    ▼
           ┌─────────────────┐
           │ Navigate to     │
           │ Cart Screen     │
           └─────────────────┘
```

## Implementation Details

### 1. Product Detail Screen (`shop_details_screen.dart`)

When user clicks "Add to Cart":
- If user is logged in (token exists): Directly call `addToCart()` API
- If user is NOT logged in: Navigate to Login Screen with `text: "ProductDetailScreen"`

```dart
OutlinedButton(
  onPressed: isAddingToCart ? null : () {
    if (token.isEmpty) {
      // Set flag to auto-add to cart after login
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
    } else {
      addToCart();
    }
  },
  child: isAddingToCart
      ? CircularProgressIndicator()
      : Text("Add to Cart"),
)
```

### 2. Login Screen (`login_screen.dart`)

- Added new parameter `productId` to store the product ID
- Passes `productId` to the login notifier for navigation

```dart
class JinLoginScreen extends ConsumerStatefulWidget {
  const JinLoginScreen({
    ...
    this.productId,  // For auto-add to cart after login
  });
  
  final String? productId;
  ...
}
```

### 3. Login Notifier (`login_notifier.dart`)

- Added `productId` parameter to the `login()` method
- Updated `_navigate()` function to handle `"ProductDetailScreen"` case
- After successful login, navigates to ShopScreen (user needs to find product again)

```dart
Future<void> login(
  BuildContext context,
  VoidCallback onTab,
  String text,
  String type,
  dynamic id,
  dynamic password, {
  dynamic DeliveryType,
  String? productId,  // NEW PARAMETER
}) async {
  ...
  _navigate(context, text, DeliveryType, productId: productId);
}

void _navigate(BuildContext context, String text, dynamic DeliveryType, {String? productId}) {
  switch (text) {
    ...
    case "ProductDetailScreen":
      // Navigate to ShopScreen - user will need to find and click on product again
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ShopScreen(deliveryType: DeliveryType),
        ),
      );
      break;
    ...
  }
}
```

## Key Changes Made

1. **`shop_details_screen.dart`**:
   - Added `_shouldAutoAddToCart` flag to track if we should auto-add after login
   - Added `didChangeDependencies()` to check for auto-add flag when returning from login
   - Changed login navigation to use `text: "ProductDetailScreen"` instead of `"ShopScreen"`
   - Added `productId` parameter to login screen

2. **`login_screen.dart`**:
   - Added `productId` parameter to store product ID
   - Pass `productId` to login notifier

3. **`login_notifier.dart`**:
   - Added `productId` parameter to `login()` method
   - Added `"ProductDetailScreen"` case to `_navigate()` function
   - Updated `_navigate()` call to pass `productId`

## User Experience

1. User views a product detail page
2. User clicks "Add to Cart"
3. If not logged in:
   - User is redirected to login screen
   - After successful login, user is taken to ShopScreen
   - User finds the product again and clicks "Add to Cart"
   - This time, since user is logged in, the item is added to cart
   - User is taken to Cart screen
4. If already logged in:
   - Item is directly added to cart
   - User is taken to Cart screen

## Future Improvements

For a more seamless experience, consider:
1. Storing product details in shared preferences before login
2. After login, navigating directly back to the product detail screen with stored product data
3. Automatically triggering "Add to Cart" after returning to product detail screen