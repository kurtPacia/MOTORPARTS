# Shopping Cart Functionality Guide

## Overview
The shopping cart system now requires users to be logged in before they can add items to their cart. This ensures proper user identification and cart persistence across sessions.

## Key Features

### ✅ Authentication-Protected Cart
- **Non-logged-in users**: Cannot add items to cart
- **Logged-in users**: Can add, view, and manage cart items
- **Session persistence**: Cart data is linked to the user's account

### ✅ User Flow

#### For Non-Logged-In Users
1. Browse products freely on `/products` page
2. View product details on `/product-details` page
3. Click "Add to Cart" or cart FAB → See login prompt
4. Click "LOGIN" button → Redirected to `/login` page
5. After successful login → Redirected back to products
6. Can now add items to cart

#### For Logged-In Users
1. Browse products on `/products` page
2. View product details on `/product-details` page
3. Click "Add to Cart" → Item added successfully
4. See confirmation with "VIEW CART" option
5. Click cart FAB or "VIEW CART" → Go to `/cart` page
6. Manage cart items (add/remove/update quantity)
7. Proceed to checkout

## Files Modified

### 1. `lib/screens/customer/product_details_page.dart`
**Changes:**
- Added `AuthService` and `CartService` imports
- Added `_isLoggedIn` and `_userId` state variables
- Added `_checkLoginStatus()` method
- Added `_addToCart()` method with authentication checks
- Added `_buyNow()` method with authentication checks
- Updated "Add to Cart" button to call `_addToCart()`
- Updated "Buy Now" button to call `_buyNow()`

**Key Methods:**
```dart
void _checkLoginStatus() {
  setState(() {
    _isLoggedIn = _authService.isLoggedIn;
    _userId = _authService.currentUserId ?? _authService.currentUser?.uid;
  });
}

void _addToCart() {
  if (!_isLoggedIn || _userId == null) {
    // Show login prompt with LOGIN button
    return;
  }
  
  // Convert product map to Product model
  // Add to cart via CartService
  // Show success message with VIEW CART option
}
```

### 2. `lib/screens/customer/products_page.dart`
**Changes:**
- Updated cart FAB (Floating Action Button) onPressed handler
- Added authentication check before navigating to cart
- Non-logged-in users see login prompt
- Logged-in users navigate to `/cart` page

**Key Code:**
```dart
floatingActionButton: FloatingActionButton(
  onPressed: () {
    if (!_isLoggedIn) {
      // Show login prompt
    } else {
      // Navigate to cart page
      context.push('/cart');
    }
  },
  child: const Icon(Icons.shopping_cart),
),
```

### 3. `lib/screens/customer/customer_cart_page.dart` (NEW FILE)
**Purpose:** Dedicated cart page for logged-in customers

**Features:**
- Authentication guard (redirects non-logged-in users to login)
- Display cart items with product info
- Quantity controls (increase/decrease)
- Remove item button
- Clear cart option
- Cart total calculation
- Checkout functionality
- Empty cart state

**Key Components:**
```dart
- _buildEmptyCart(): Shows when cart is empty
- _buildCartContent(): Shows cart items and summary
- _buildCartItem(): Individual cart item with controls
- _showClearCartDialog(): Confirm clear all items
- _showCheckoutDialog(): Order confirmation and placement
```

### 4. `lib/main.dart`
**Changes:**
- Added import for `CustomerCartPage`
- Added new route: `/cart`

**Route Configuration:**
```dart
GoRoute(
  path: '/cart',
  pageBuilder: (context, state) => _buildPageWithTransition(
    context: context,
    state: state,
    child: const CustomerCartPage(),
  ),
),
```

## Testing the Cart Functionality

### Test Case 1: Non-Logged-In User
1. Open app → Goes to `/products` page
2. Click any product → Opens `/product-details`
3. Click "Add to Cart" button
   - ✅ Should show snackbar: "Please login to add items to cart"
   - ✅ Should display "LOGIN" button in snackbar
4. Click "LOGIN" → Navigates to `/login` page
5. Click cart FAB on products page
   - ✅ Should show snackbar: "Please login to access your cart"
   - ✅ Should display "LOGIN" button in snackbar

### Test Case 2: Registration Flow
1. Click "LOGIN" → Go to login page
2. Click "Don't have an account? Register"
3. Fill registration form (email, password, full name)
4. Submit registration
   - ✅ User gets 'customer' role by default
   - ✅ Can immediately access cart after registration

### Test Case 3: Logged-In Customer (Email/Password)
1. Login with email: `kurtjhonphilip@gmail.com`
2. Go to products page
3. Click any product → Opens product details
4. Select quantity (use +/- buttons)
5. Click "Add to Cart"
   - ✅ Should show green snackbar: "X items added to cart"
   - ✅ Should display "VIEW CART" button
6. Click "VIEW CART" → Navigates to `/cart`
7. Verify cart shows:
   - ✅ Product name, category, price
   - ✅ Quantity controls
   - ✅ Remove button
   - ✅ Total price
8. Update quantity → Total updates
9. Click "Proceed to Checkout"
   - ✅ Shows order confirmation dialog
10. Click "Place Order"
    - ✅ Shows success dialog with Order ID
    - ✅ Cart is cleared

### Test Case 4: Demo User Login
1. Login as driver: username=`driver1`, password=`driver123`
2. Add items to cart
   - ✅ Cart is linked to driver1 user ID
3. Logout
4. Login as customer with email registration
   - ✅ Cart should be empty (different user)
5. Add items to cart
   - ✅ Cart is linked to customer's email/user ID
6. Logout and login again as same customer
   - ✅ Cart should persist (same user ID)

### Test Case 5: Cart Persistence
1. Login as customer
2. Add 3 items to cart
3. Navigate away (back to products)
4. Click cart FAB
   - ✅ Cart still shows 3 items
5. Close app and reopen
6. Login with same credentials
   - ✅ Cart still shows 3 items (session-based, not Firebase-persisted)

### Test Case 6: Multiple Users
1. Login as User A, add items
2. Logout
3. Login as User B, add different items
   - ✅ User B cart should NOT contain User A's items
4. Logout
5. Login as User A again
   - ✅ User A cart should still contain their items

## Architecture

### Authentication Flow
```
User Opens App
    ↓
Products Page (Public)
    ↓
Click Add to Cart
    ↓
Check: _authService.isLoggedIn?
    ↓
NO  → Show Login Prompt → Navigate to /login
    ↓
YES → Check: _userId exists?
    ↓
    YES → Add to CartService
        ↓
        CartService.addToCart(userId, product)
        ↓
        Show Success Message
        ↓
        Option: VIEW CART → Navigate to /cart
```

### Cart Data Flow
```
CartService (Static Storage)
    ↓
Map<String, List<CartItem>> _userCarts
    ↓
Key: userId (from AuthService)
Value: List of CartItem objects
    ↓
Each CartItem contains:
    - Product model
    - Quantity
    - Total price (calculated)
```

### User Identification
```
AuthService provides userId:
    ↓
1. Demo Users (admin, branch1, driver1)
   → _currentUserId = username
    ↓
2. Registered Demo Users
   → _currentUserId = email
    ↓
3. Firebase Users
   → _currentUserId = Firebase UID
    ↓
CartService uses userId as key
```

## Security Features

### ✅ Authentication Required
- All cart operations require valid user session
- Non-authenticated users see login prompts
- No cart access without authentication

### ✅ User Isolation
- Each user has separate cart data
- Cart data keyed by unique userId
- No cross-user cart contamination

### ✅ Session Validation
- `_authService.isLoggedIn` checks session active
- `_userId` must be non-null to proceed
- Session cleared on logout (via AuthService)

## Error Handling

### Authentication Errors
```dart
if (!_isLoggedIn || _userId == null) {
  // Show login prompt with action button
  return;
}
```

### Cart Operation Errors
```dart
try {
  _cartService.addToCart(_userId!, product, quantity: _quantity);
  // Success handling
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error adding to cart: $e')),
  );
}
```

### Empty Cart Handling
- Shows empty cart illustration
- "Continue Shopping" button
- Clear messaging

## UI/UX Improvements

### Login Prompts
- Clear icon (ℹ️ info icon)
- Descriptive message
- Prominent LOGIN button
- Auto-dismiss or user-dismissible

### Success Messages
- Green success color
- Check mark icon
- Item count confirmation
- VIEW CART action button

### Cart Page
- Clean white cards
- Product thumbnails
- Clear pricing
- Easy quantity controls
- Remove button per item
- Prominent checkout button
- Total always visible

## API Reference

### AuthService Methods Used
```dart
bool get isLoggedIn
String? get currentUserId
String? get currentUsername
User? get currentUser
String? getUserEmail()
```

### CartService Methods Used
```dart
void addToCart(String userId, Product product, {int quantity = 1})
List<CartItem> getUserCart(String userId)
double getCartTotal(String userId)
int getCartItemCount(String userId)
void updateQuantity(String userId, String productId, int quantity)
void removeFromCart(String userId, String productId)
void clearCart(String userId)
String placeOrder(String userId, String userName, String userEmail)
```

## Future Enhancements

### Recommended Features
1. **Firebase Cart Persistence**: Save cart to Firestore for cross-device access
2. **Guest Cart**: Allow temporary cart before login, merge on login
3. **Cart Badge**: Show item count on cart FAB
4. **Save for Later**: Move items from cart to wishlist
5. **Price Alerts**: Notify when cart items go on sale
6. **Abandoned Cart**: Email reminders for incomplete checkouts
7. **Quick Add**: Add to cart from products grid without opening details
8. **Bulk Actions**: Select multiple items to remove at once

## Troubleshooting

### Cart Not Persisting
**Issue**: Cart items disappear after logout
**Solution**: This is expected - cart is session-based. Implement Firebase persistence for permanent storage.

### Wrong User Cart Displayed
**Issue**: Seeing another user's cart items
**Solution**: 
1. Check `_clearSession()` is called on logout
2. Verify `_userId` is updated on login
3. Ensure `CartService` uses correct userId key

### Add to Cart Button Not Working
**Issue**: Nothing happens when clicking Add to Cart
**Solution**:
1. Check console for authentication errors
2. Verify `_isLoggedIn` is true
3. Confirm `_userId` is not null
4. Check `CartService` import is present

### Login Redirect Not Working
**Issue**: After login, not redirected back
**Solution**: The app uses go_router which maintains navigation state. Use `context.push('/login')` not `context.go('/login')`.

## Summary

The cart functionality now enforces authentication at every entry point:
- ✅ Product details "Add to Cart" button
- ✅ Product details "Buy Now" button  
- ✅ Cart FAB on products page
- ✅ Cart page itself

Non-logged-in users are guided to login with clear prompts and action buttons. Logged-in users enjoy seamless cart operations with proper user isolation and session management.
