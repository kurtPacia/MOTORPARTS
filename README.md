# MotorShop - Motor Parts Delivery & Scheduling System

A modern, elegant Flutter application for managing motor parts delivery and scheduling with three distinct user roles.

## 🎯 Features

### 👨‍💼 Admin / Main Shop

- **Dashboard** - Overview with statistics and quick actions
- **Manage Products** - Add, edit, and manage motor parts inventory
- **Manage Orders** - View, approve, and manage orders from branches
- **Manage Deliveries** - Assign drivers and track deliveries
- **Delivery Calendar** - Visual calendar view of scheduled deliveries
- **Reports** - Sales and delivery analytics
- **Inventory Management** - Track stock levels and replenishment
- **Notifications** - Real-time updates on orders and deliveries

### 🏪 Branch / Partner Shop

- **Dashboard** - Quick access to orders and shop statistics
- **Browse Products** - Searchable catalog of motor parts with categories
- **Shopping Cart** - Add products and manage cart
- **Place Orders** - Order products with delivery scheduling
- **Order Tracking** - Track order status (Pending → Approved → Delivered)
- **Schedule Management** - Select delivery date and time slots
- **Notifications** - Updates on order status

### 🚚 Delivery Staff
- **Dashboard** - Overview of today's deliveries
- **My Deliveries** - List of assigned deliveries
- **Delivery Calendar** - Schedule of upcoming deliveries
- **Update Status** - Real-time status updates (Picked Up → On the Way → Delivered)
- **Route View** - Map integration for delivery routes
- **Delivery History** - Past delivery records

## 🎨 Design Features

- **Modern UI/UX** - Clean, professional interface with smooth animations
- **Color Scheme**:
  - Primary: Deep Blue (#0D47A1)
  - Accent: Amber (#FFC107)
  - Background: Light Grey (#F5F6FA)
- **Gradient Effects** - Beautiful gradient overlays on key components
- **Smooth Animations** - Page transitions, fade effects, and slide animations
- **Status Indicators** - Color-coded chips for order and delivery status
- **Responsive Layout** - Adapts to different screen sizes
- **Card-based Design** - Elevated cards with shadows for depth
- **Bottom Navigation** - Easy navigation for mobile users

## 📦 Packages Used

- `go_router` - Advanced routing and navigation
- `provider` - State management
- `table_calendar` - Calendar widget for delivery scheduling
- `syncfusion_flutter_charts` - Charts for reports and analytics
- `flutter_datetime_picker_plus` - Date and time picker
- `lottie` - Animated illustrations
- `animated_text_kit` - Text animations
- `dio` - HTTP client for API calls
- `google_maps_flutter` - Map integration for delivery routes
- `font_awesome_flutter` - Additional icons
- `intl` - Internationalization and date formatting

## 🚀 Quick Start Guide

### System Requirements

- **For Development:**
  - Flutter SDK 3.9.2 or higher
  - Dart SDK 3.0.0 or higher
  - Android Studio or VS Code with Flutter extensions
  - Android SDK (for Android development)
  - Xcode (for iOS development, macOS only)

- **For Running the App (End Users):**
  - Android device with Android 5.0 (Lollipop) or higher
  - Minimum 2GB RAM
  - 100MB free storage space

### Installation Options

#### Option 1: Install APK (Recommended for End Users)

1. **Download the APK:**
   - APK file location: `build/app/outputs/flutter-apk/app-release.apk`
   - Copy this file to your Android device

2. **Enable Unknown Sources:**
   - Go to Settings > Security (or Apps & Notifications)
   - Enable "Install from Unknown Sources" or "Allow from this source"

3. **Install the App:**
   - Open the APK file on your Android device
   - Tap "Install"
   - Wait for installation to complete
   - Tap "Open" to launch the app

#### Option 2: Build from Source (For Developers)

1. **Clone/Download the Repository:**
   ```bash
   # If using Git
   git clone <repository-url>
   cd motorshop
   
   # Or download and extract the ZIP file
   cd c:\flutter\motorshop
   ```

2. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase (Optional - for backend features):**
   - The app includes Firebase configuration files
   - Review `FIREBASE_SETUP.md` for detailed Firebase setup instructions
   - Files needed: `google-services.json` (Android), `GoogleService-Info.plist` (iOS)

4. **Run the App:**
   ```bash
   # For connected device or emulator
   flutter run
   
   # For release build
   flutter build apk --release
   ```

5. **Build APK Manually:**
   ```bash
   # Build release APK
   flutter build apk --release
   
   # APK will be generated at:
   # build/app/outputs/flutter-apk/app-release.apk
   ```

## 📱 How to Use the App

### First Launch

1. **Splash Screen:**
   - Beautiful animated splash screen with logo and background slideshow
   - Displays company branding (FKK ENTERPRISE)
   - Automatically navigates to products page after 6 seconds

2. **Initial Navigation:**
   - App opens to the Products page (public view)
   - Browse available motor parts without login
   - View product details and prices

### User Roles & Access

The app supports three distinct user roles. To access role-specific features:

1. Navigate to Login/Role Selection (if available via menu)
2. Select your role from the Role Selection page

#### 👨‍💼 Admin / Main Shop Role

**How to Access:**
- From Role Selection, tap "Admin / Main Shop"

**Main Features:**

1. **Dashboard**
   - View total orders, deliveries, and revenue statistics
   - Quick action cards for common tasks
   - Recent activity overview

2. **Manage Products**
   - **Add Product:** Tap the "+" button
     - Enter product name, description, price
     - Select category (Engine, Brakes, Transmission, etc.)
     - Add stock quantity
     - Upload product image (optional)
   - **Edit Product:** Tap any product card
   - **Delete Product:** Swipe left on product
   - **Search:** Use search bar to filter products

3. **Manage Orders**
   - View all orders from branch shops
   - Filter by status: Pending, Approved, Delivered
   - **Approve Order:** Tap "Approve" button
   - **Assign Driver:** Select driver from dropdown
   - View order details and items

4. **Delivery Calendar**
   - Visual calendar showing scheduled deliveries
   - Color-coded by delivery status
   - Tap date to see deliveries for that day
   - Schedule new deliveries

5. **Reports**
   - Sales charts and analytics
   - Revenue tracking
   - Delivery performance metrics
   - Export reports (if enabled)

6. **Inventory Management**
   - Track stock levels
   - Low stock alerts
   - Reorder notifications
   - Stock history

**Navigation:** Bottom navigation bar with icons for Dashboard, Products, Orders, Calendar, Reports

#### 🏪 Branch / Partner Shop Role

**How to Access:**
- From Role Selection, tap "Branch / Partner Shop"

**Main Features:**

1. **Dashboard**
   - View your order statistics
   - Quick access to cart and orders
   - Browse featured products

2. **Browse Products**
   - **Search:** Use search bar at top
   - **Filter by Category:** Tap category chips
     - All, Engine, Brakes, Transmission, Electrical, Body Parts, Accessories
   - **View Product:** Tap product card for details
   - **Add to Cart:** Tap "+" button on product card

3. **Shopping Cart**
   - View selected items
   - Adjust quantities with +/- buttons
   - Remove items (swipe left or tap X)
   - See total amount
   - **Checkout:** Tap "Proceed to Checkout" button

4. **Place Order**
   - Review cart items
   - Select delivery date from calendar
   - Choose time slot (Morning, Afternoon, Evening)
   - Add delivery notes (optional)
   - Confirm order

5. **My Orders**
   - View all your orders
   - Filter by status:
     - **Pending:** Awaiting admin approval
     - **Approved:** Confirmed by admin
     - **In Transit:** Out for delivery
     - **Delivered:** Successfully delivered
   - Tap order for detailed view
   - Track order progress

6. **Schedule**
   - Calendar view of your delivery schedules
   - See upcoming deliveries
   - Reschedule requests (if allowed)

7. **Profile**
   - View account information
   - Edit shop details
   - Contact information
   - Order history

**Navigation:** Bottom navigation bar with Dashboard, Products, Orders, Cart, Schedule, Profile

#### 🚚 Delivery Staff Role

**How to Access:**
- From Role Selection, tap "Delivery Staff"

**Main Features:**

1. **Dashboard**
   - Today's delivery summary
   - Active deliveries count
   - Delivery completion rate
   - Quick actions

2. **My Deliveries**
   - View assigned deliveries
   - Filter by status:
     - **Pending:** Not yet picked up
     - **Picked Up:** Collected from warehouse
     - **On the Way:** En route to destination
     - **Delivered:** Successfully completed
   - **Update Status:** Tap delivery card
     - Mark as "Picked Up"
     - Mark as "On the Way"
     - Mark as "Delivered"
   - View delivery address and contact

3. **Delivery Calendar**
   - Calendar view of delivery schedule
   - See all assigned deliveries
   - Plan your route

4. **Route View** (if Google Maps enabled)
   - Map showing delivery locations
   - Optimized route suggestions
   - Navigation integration

5. **Profile**
   - View driver information
   - Delivery statistics
   - Performance metrics

**Navigation:** Bottom navigation bar with Dashboard, Deliveries, Calendar, Profile

### Common Actions

**Search Products:**
- Tap search bar at top of Products page
- Type product name or category
- Results update in real-time

**View Product Details:**
- Tap any product card
- See full description, price, stock
- View larger image
- Add to cart directly

**Notifications:**
- Bell icon in app bar shows notifications
- Real-time updates for:
  - Order status changes
  - Delivery updates
  - Stock alerts (admin)
  - New orders (admin)

**Logout:**
- Tap profile icon
- Select "Logout" option
- Returns to products page

## 🎨 Design Features

- **Modern UI/UX** - Clean, professional interface with smooth animations
- **Color Scheme**:
  - Primary: Deep Blue (#0D47A1)
  - Accent: Amber (#FFC107) & Red (#D32F2F)
  - Background: Light Grey (#F5F6FA)
- **Gradient Effects** - Beautiful gradient overlays on key components
- **Smooth Animations** - Page transitions, fade effects, and slide animations
- **Status Indicators** - Color-coded chips for order and delivery status
- **Responsive Layout** - Adapts to different screen sizes
- **Card-based Design** - Elevated cards with shadows for depth
- **Bottom Navigation** - Easy navigation for mobile users
- **Background Slideshow** - Elegant welcome images on splash screen

## 📦 Packages Used

- `firebase_core` ^3.6.0 - Firebase initialization
- `firebase_auth` ^5.3.1 - Authentication
- `cloud_firestore` ^5.4.4 - Cloud database
- `go_router` ^14.2.0 - Advanced routing and navigation
- `provider` ^6.1.1 - State management
- `table_calendar` ^3.0.9 - Calendar widget for delivery scheduling
- `fl_chart` ^0.69.0 - Charts for reports and analytics
- `flutter_datetime_picker_plus` ^2.1.0 - Date and time picker
- `lottie` ^3.0.0 - Animated illustrations
- `animated_text_kit` ^4.2.2 - Text animations
- `dio` ^5.4.0 - HTTP client for API calls
- `google_maps_flutter` ^2.5.0 - Map integration for delivery routes
- `font_awesome_flutter` ^10.6.0 - Additional icons
- `intl` ^0.19.0 - Internationalization and date formatting

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with splash screen and routing
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── product_model.dart   # Product data structure
│   ├── order_model.dart     # Order data structure
│   ├── delivery_model.dart  # Delivery data structure
│   └── user_model.dart      # User data structure
├── screens/                  # UI screens
│   ├── admin/               # Admin role screens
│   │   ├── admin_dashboard.dart
│   │   ├── manage_products.dart
│   │   ├── manage_orders.dart
│   │   ├── delivery_calendar.dart
│   │   ├── reports.dart
│   │   └── inventory.dart
│   ├── branch/              # Branch role screens
│   │   ├── branch_dashboard.dart
│   │   ├── browse_products.dart
│   │   ├── my_orders.dart
│   │   ├── cart.dart
│   │   ├── schedule.dart
│   │   └── profile.dart
│   ├── driver/              # Driver role screens
│   │   ├── driver_dashboard.dart
│   │   ├── my_deliveries.dart
│   │   ├── driver_schedule.dart
│   │   └── driver_profile.dart
│   ├── customer/            # Public screens
│   │   ├── products_page.dart
│   │   └── product_details_page.dart
│   └── auth/                # Authentication screens
│       ├── login_page.dart
│       └── register_page.dart
├── services/                # Business logic
│   └── auth_service.dart   # Authentication service
├── widgets/                 # Reusable widgets
│   ├── custom_appbar.dart  # Custom app bar with gradient
│   ├── gradient_button.dart # Gradient styled buttons
│   ├── order_card.dart     # Order display card
│   ├── delivery_card.dart  # Delivery display card
│   ├── product_card.dart   # Product display card
│   ├── status_chip.dart    # Status indicator chip
│   ├── dashboard_card.dart # Dashboard quick action card
│   └── fhh_logo.dart       # Company logo widget
└── utils/                   # Utilities
    ├── theme.dart          # App theme and colors
    └── constants.dart      # App constants
```

## 🔄 Order Flow

1. **Branch** browses products catalog and adds items to cart
2. **Branch** reviews cart and proceeds to checkout
3. **Branch** places order with selected delivery date/time
4. **Admin** receives notification of new order
5. **Admin** reviews and approves the order
6. **Admin** assigns a driver to the delivery
7. **Driver** receives delivery assignment notification
8. **Driver** picks up order and marks as "Picked Up"
9. **Driver** travels to destination and marks "On the Way"
10. **Driver** delivers to branch and marks as "Delivered"
11. **Branch** receives delivery completion notification

## 🔧 Technical Details

### Database Structure (Firebase Firestore)

- **products** collection - Motor parts inventory
- **orders** collection - Customer orders
- **deliveries** collection - Delivery records
- **users** collection - User accounts and roles

### Authentication

- Firebase Authentication for user management
- Role-based access control (Admin, Branch, Driver)
- Secure login and registration

### State Management

- Provider pattern for state management
- Reactive UI updates
- Efficient data flow

## 📸 Screenshots

*Note: Add screenshots of key screens here:*
- Splash screen
- Role selection
- Admin dashboard
- Product browsing
- Shopping cart
- Order management
- Delivery tracking
- Calendar view

## 🚧 Troubleshooting

### APK Installation Issues

**Problem:** "App not installed" error
**Solution:**
- Ensure "Unknown Sources" is enabled
- Check available storage space (need 100MB)
- Try uninstalling any previous version first

**Problem:** App crashes on launch
**Solution:**
- Ensure Android version is 5.0 or higher
- Clear app data and cache
- Reinstall the app

### Firebase Connection Issues

**Problem:** Data not loading
**Solution:**
- Check internet connection
- Verify Firebase configuration
- Review Firebase console for service status

### Build Issues (Developers)

**Problem:** "pub get failed"
**Solution:**
```bash
flutter clean
flutter pub get
```

**Problem:** Build errors
**Solution:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
flutter build apk --release
```

## 🌟 Future Enhancements

- ✅ Real-time notifications using Firebase Cloud Messaging
- ✅ Google Maps live tracking
- ⏳ Payment gateway integration
- ⏳ Barcode scanning for products
- ⏳ Advanced analytics and reporting
- ⏳ Push notifications
- ⏳ Multi-language support
- ⏳ Dark mode theme
- ⏳ Customer reviews and ratings
- ⏳ In-app chat support

## 📤 Sharing Your Project

### GitHub Repository

1. **Create a new repository on GitHub:**
   ```bash
   # Initialize git (if not already done)
   git init
   
   # Add all files
   git add .
   
   # Commit
   git commit -m "Initial commit - MotorShop app"
   
   # Add remote repository
   git remote add origin https://github.com/yourusername/motorshop.git
   
   # Push to GitHub
   git push -u origin main
   ```

2. **Include these files in your repository:**
   - All source code in `lib/` folder
   - `pubspec.yaml` for dependencies
   - This `README.md`
   - APK file in `build/app/outputs/flutter-apk/app-release.apk`
   - Firebase setup documentation

3. **Your GitHub share link will be:**
   ```
   https://github.com/yourusername/motorshop
   ```

### Google Drive

1. **Create a compressed archive:**
   - Right-click the `motorshop` folder
   - Select "Send to" > "Compressed (zipped) folder"
   - Name it: `MotorShop-App-v1.0.zip`

2. **Upload to Google Drive:**
   - Go to drive.google.com
   - Click "New" > "File upload"
   - Select your ZIP file
   - Wait for upload to complete

3. **Get shareable link:**
   - Right-click the uploaded file
   - Select "Get link"
   - Change access to "Anyone with the link"
   - Copy the link

4. **Your Google Drive share link will look like:**
   ```
   https://drive.google.com/file/d/YOUR-FILE-ID/view?usp=sharing
   ```

### What to Include When Sharing

**Essential Files:**
- ✅ Complete source code (`lib/` folder)
- ✅ `pubspec.yaml` with all dependencies
- ✅ This comprehensive `README.md`
- ✅ APK file (`app-release.apk`)
- ✅ Firebase configuration files
- ✅ Assets folder with images and logos

**Optional but Recommended:**
- Screenshots of the app in action
- Demo video showing features
- Firebase setup guide
- Architecture documentation
- API documentation (if applicable)

## 📞 Support & Contact

For issues, questions, or contributions:
- Create an issue on GitHub repository
- Contact: [Your contact information]
- Email: [Your email]

## 📄 License

This project is for demonstration and educational purposes.

---

**Built with ❤️ using Flutter**

**Version:** 1.0.0  
**Last Updated:** November 2025  
**Flutter SDK:** 3.9.2+  
**Minimum Android:** 5.0 (API 21)

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with splash screen
├── models/                   # Data models
│   ├── product_model.dart
│   ├── order_model.dart
│   ├── delivery_model.dart
│   └── user_model.dart
├── screens/                  # UI screens
│   ├── admin/               # Admin role screens
│   │   ├── admin_dashboard.dart
│   │   ├── manage_products.dart
│   │   ├── manage_orders.dart
│   │   └── delivery_calendar.dart
│   ├── branch/              # Branch role screens
│   │   ├── branch_dashboard.dart
│   │   └── browse_products.dart
│   └── driver/              # Driver role screens
│       └── driver_dashboard.dart
├── widgets/                 # Reusable widgets
│   ├── custom_appbar.dart
│   ├── gradient_button.dart
│   ├── order_card.dart
│   ├── delivery_card.dart
│   ├── product_card.dart
│   ├── status_chip.dart
│   └── dashboard_card.dart
└── utils/                   # Utilities
    ├── theme.dart          # App theme and colors
    └── constants.dart      # Constants and helpers
```

## 🎭 User Roles

The app has a role selection screen where users can choose their role:

1. **Admin / Main Shop** - Full control over products, orders, and deliveries
2. **Branch / Partner Shop** - Can browse and order products
3. **Delivery Staff** - Can view and update delivery status

## 🎨 UI Components

### Custom Widgets
- `CustomAppBar` - Gradient app bar with optional search
- `GradientButton` - Buttons with gradient backgrounds
- `OrderCard` - Display order information
- `DeliveryCard` - Display delivery details
- `ProductCard` - Product display with add to cart
- `StatusChip` - Color-coded status indicators
- `DashboardCard` - Quick action cards

### Theme
- Consistent color scheme throughout the app
- Custom text styles using Poppins font
- Rounded corners and soft shadows
- Smooth transitions and animations

## 🔄 Order Flow

1. **Branch** browses products and adds to cart
2. **Branch** places order and selects delivery schedule
3. **Admin** receives and approves the order
4. **Admin** assigns a driver to the delivery
5. **Driver** picks up the order and updates status
6. **Driver** delivers to branch and marks as delivered
7. **Branch** receives notification of delivery

## 🚧 Future Enhancements

- Real-time notifications using Firebase
- Google Maps integration for live tracking
- Payment gateway integration
- Barcode scanning for products
- Advanced analytics and reporting
- Push notifications
- Multi-language support
- Dark mode theme

## 👨‍💻 Development

This app was built with:
- Flutter's Material Design 3
- Clean architecture principles
- Reusable widget components
- Dummy data for demonstration

## 📄 License

This project is for demonstration purposes.

---

**Built with ❤️ using Flutter**
