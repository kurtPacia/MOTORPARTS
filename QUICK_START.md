# Quick Start Guide - MotorShop

## 🚀 Running the App

1. **Open Terminal in VS Code**
2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Select a device:**
   - Choose an emulator, simulator, or connected device
   - The app will compile and launch

## 🎬 App Flow

### First Launch
1. **Splash Screen** - Animated logo with typewriter effect (3 seconds)
2. **Role Selection** - Choose one of three roles:
   - Admin / Main Shop
   - Branch / Partner Shop
   - Delivery Staff

### Admin Journey
1. **Dashboard** - View overview statistics
2. **Manage Products** - Click any quick action:
   - View product grid
   - Search and filter by category
   - Tap product to view details
   - Use FAB to add new products
3. **Manage Orders** - View and approve orders
   - Filter by status
   - Tap order to view details
   - Approve or reject orders
4. **Delivery Calendar** - Visual schedule
   - Calendar view with marked delivery dates
   - Tap date to see deliveries
   - View delivery details

### Branch Journey
1. **Dashboard** - Home screen with stats
2. **Browse Products** (Use FAB):
   - View all motor parts
   - Search products
   - Filter by category
   - Add to cart
   - View cart badge in top-right
3. **Bottom Navigation**:
   - Home
   - Orders (view order history)
   - Notifications (2 unread)
   - Profile

### Driver Journey
1. **Dashboard** - Today's overview
2. **View Deliveries** - Today's delivery list
3. **Update Status** - Tap "Update" button:
   - Mark as "Picked Up"
   - Mark as "On the Way"
   - Mark as "Delivered"
4. **View Route** - See map placeholder
5. **Bottom Navigation**:
   - Home
   - Deliveries
   - Schedule
   - Profile

## 🎨 Key Features to Notice

### Animations
- ✨ Splash screen fade and scale animation
- ✨ Page transitions with slide and fade
- ✨ Card elevations and shadows
- ✨ Smooth status updates

### UI Elements
- 🎯 Gradient backgrounds on key components
- 🎯 Status chips with color coding:
  - Yellow/Amber = Pending
  - Blue = Approved
  - Orange = On the Way
  - Green = Delivered
  - Red = Cancelled
- 🎯 Bottom sheets for details
- 🎯 Floating action buttons
- 🎯 Pull to refresh

### Color System
- **Primary (Deep Blue)**: Main actions, headers
- **Accent (Amber)**: Secondary actions, highlights
- **Status Colors**: Order/delivery status indicators
- **Gradients**: Premium look on cards and buttons

## 🔧 Customization Tips

### Change Colors
Edit `lib/utils/theme.dart`:
```dart
static const Color primaryColor = Color(0xFF0D47A1); // Your color
static const Color accentColor = Color(0xFFFFC107);  // Your color
```

### Add More Products
Edit `lib/models/product_model.dart`:
```dart
static List<Product> getDummyProducts() {
  return [
    Product(
      id: '7',
      name: 'Your Product Name',
      // ... add more fields
    ),
  ];
}
```

### Add Routes
Edit `lib/main.dart`:
```dart
GoRoute(
  path: '/your-route',
  builder: (context, state) => YourPage(),
),
```

## 📱 Testing Different Roles

To test all features:

1. **Start as Admin**:
   - Explore dashboard
   - View products
   - Check orders
   - View calendar

2. **Go back and select Branch**:
   - Browse products
   - Add items to cart
   - View orders

3. **Go back and select Driver**:
   - See today's deliveries
   - Update status
   - Check calendar

## 🐛 Common Issues

### Issue: Packages not found
**Solution:**
```bash
flutter pub get
```

### Issue: App won't build
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Hot reload not working
**Solution:** Press `r` in terminal or restart app

## 📝 Notes

- **Dummy Data**: All data is hardcoded for demonstration
- **No Backend**: This is a UI/UX demonstration
- **State Management**: Uses basic setState (can be upgraded to Provider)
- **Navigation**: Uses GoRouter for clean routing

## 🎯 Next Steps

To make this production-ready:

1. **Add Backend Integration**:
   - Connect to REST API using Dio
   - Implement authentication
   - Real-time database (Firebase/Supabase)

2. **Add State Management**:
   - Implement Provider properly
   - Or use Riverpod/Bloc

3. **Add Features**:
   - Push notifications (Firebase Cloud Messaging)
   - Real Google Maps integration
   - Image uploads (for products)
   - Payment gateway

4. **Testing**:
   - Unit tests
   - Widget tests
   - Integration tests

5. **Polish**:
   - Add loading states
   - Error handling
   - Offline support
   - Analytics

## 💡 Tips

- Use **hot reload** (r) during development
- Use **hot restart** (R) after adding new files
- Check the **Debug Console** for errors
- Use **Flutter DevTools** for debugging

---

**Enjoy building with MotorShop! 🚀**
