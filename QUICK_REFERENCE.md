# MotorShop - Quick Reference Guide

## 🚀 Quick Links

- **APK Location:** `build/app/outputs/flutter-apk/app-release.apk`
- **Complete Documentation:** See `README.md`
- **Sharing Instructions:** See `SHARING_INSTRUCTIONS.md`
- **Firebase Setup:** See `FIREBASE_SETUP.md`

## 📱 Installation (End Users)

1. Copy `app-release.apk` to Android device
2. Enable "Unknown Sources" in Settings
3. Tap APK file to install
4. Open app and explore!

## 👥 User Roles

| Role | Access | Main Screen |
|------|--------|-------------|
| **Admin** | Full control | `/admin` |
| **Branch** | Order products | `/branch` |
| **Driver** | Manage deliveries | `/driver` |

## 🎯 Key Features by Role

### 👨‍💼 Admin
- ✅ Manage products inventory
- ✅ Approve/reject orders
- ✅ Assign deliveries to drivers
- ✅ View reports and analytics
- ✅ Calendar scheduling
- ✅ Inventory tracking

### 🏪 Branch Shop
- ✅ Browse product catalog
- ✅ Add items to cart
- ✅ Place orders
- ✅ Schedule deliveries
- ✅ Track order status
- ✅ View order history

### 🚚 Driver
- ✅ View assigned deliveries
- ✅ Update delivery status
- ✅ Calendar view
- ✅ Route planning
- ✅ Delivery history
- ✅ Performance metrics

## 🔄 Order Status Flow

```
Pending → Approved → In Transit → Delivered
```

1. **Pending:** Branch placed order, awaiting admin approval
2. **Approved:** Admin approved, driver assigned
3. **In Transit:** Driver picked up, on the way
4. **Delivered:** Successfully delivered to branch

## 🎨 Color Codes

| Status | Color |
|--------|-------|
| Pending | Orange |
| Approved | Blue |
| In Transit | Purple |
| Delivered | Green |
| Cancelled | Red |

## ⚙️ Tech Stack

- **Framework:** Flutter 3.9.2+
- **Language:** Dart
- **Backend:** Firebase (Auth, Firestore)
- **State Management:** Provider
- **Navigation:** GoRouter
- **UI Components:** Material Design 3

## 📦 Main Dependencies

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
go_router: ^14.2.0
provider: ^6.1.1
table_calendar: ^3.0.9
fl_chart: ^0.69.0
google_maps_flutter: ^2.5.0
```

## 🛠️ Development Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Clean build
flutter clean

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 📂 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `pubspec.yaml` | Dependencies |
| `firebase_options.dart` | Firebase config |
| `google-services.json` | Firebase Android config |
| `README.md` | Complete documentation |

## 🌐 Routes

| Path | Screen |
|------|--------|
| `/splash` | Splash screen (auto-redirects) |
| `/products` | Public products page |
| `/login` | Login page |
| `/register` | Registration page |
| `/role-selection` | Role selection |
| `/admin` | Admin dashboard |
| `/branch` | Branch dashboard |
| `/driver` | Driver dashboard |

## 🎭 Demo Data

The app includes dummy data for demonstration:
- 15+ motor parts products
- Sample orders
- Delivery schedules
- User profiles

## 📸 Screenshot Locations

Recommended screens to capture:
1. Splash screen with slideshow
2. Role selection page
3. Admin dashboard
4. Product catalog (branch view)
5. Shopping cart with items
6. Order management (admin)
7. Delivery tracking (driver)
8. Calendar view

## 🐛 Common Issues & Solutions

### App won't install
- Enable "Unknown Sources"
- Check Android version (need 5.0+)
- Ensure 100MB free space

### Firebase not connecting
- Check internet connection
- Verify Firebase configuration
- Review firebase_options.dart

### Build fails
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

## 📊 App Statistics

- **Lines of Code:** ~5000+
- **Screens:** 15+
- **Widgets:** 20+ custom widgets
- **Firebase Collections:** 4 (products, orders, deliveries, users)
- **User Roles:** 3 (Admin, Branch, Driver)
- **Product Categories:** 6

## 🔐 Security Features

- Firebase Authentication
- Role-based access control
- Secure data storage
- Protected routes
- Input validation

## 🌟 Unique Features

✨ Elegant splash screen with background slideshow
✨ Smooth page transitions and animations
✨ Color-coded status indicators
✨ Interactive calendar for scheduling
✨ Real-time order tracking
✨ Gradient buttons and effects
✨ Custom app bar with search
✨ Bottom navigation for easy access

## 📞 Support

For issues or questions:
- Check `README.md` for detailed docs
- Review `SHARING_INSTRUCTIONS.md` for deployment
- See `FIREBASE_SETUP.md` for backend setup

## 🎓 Learning Resources

- Flutter Docs: https://docs.flutter.dev
- Firebase Docs: https://firebase.google.com/docs
- Dart Docs: https://dart.dev/guides
- Material Design: https://m3.material.io

---

**Version:** 1.0.0  
**Last Updated:** November 2025  
**Built with Flutter** 💙
