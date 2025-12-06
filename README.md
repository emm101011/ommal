
## 🎯 Overview

The Maintenance Services Platform is a multi-role application designed to revolutionize how customers access home maintenance services. The platform supports three distinct user roles - Customers, Technicians, and Administrators - each with tailored interfaces and functionalities.

### Problem Statement
Finding reliable maintenance technicians for home services is often challenging, time-consuming, and lacks transparency in pricing and quality. This platform addresses these pain points by providing a centralized, trusted marketplace.

### Solution
A feature-rich mobile application that:
- Connects verified technicians with customers in need
- Provides transparent ratings and reviews
- Enables real-time order tracking and notifications
- Offers multi-category service management
- Includes admin oversight for quality control

## ✨ Key Features

### For Customers
- **Service Discovery**: Browse technicians by specialty with ratings and reviews
- **Easy Request Submission**: Create maintenance requests with descriptions and images
- **Order Tracking**: Real-time status updates (Pending → In Progress → Completed)
- **Rating & Reviews**: Rate completed services to help other customers
- **Order History**: View all past and current service requests
- **Profile Management**: Update personal information and preferences
- **Notifications**: Receive updates on order status changes

### For Technicians
- **Professional Profile**: Showcase specialties, bio, and qualifications
- **Order Management**: Accept and manage service requests
- **Status Updates**: Update order progress in real-time
- **Reviews Dashboard**: Monitor customer feedback and ratings
- **Earnings Tracking**: Track completed orders and performance metrics

### For Administrators
- **User Management**: View and manage all users (customers and technicians)
- **User Blocking**: Block/unblock users for policy violations
- **Reviews Monitoring**: Oversee all platform reviews and ratings
- **System Statistics**: Access platform-wide analytics
- **Quality Control**: Ensure service quality and user satisfaction

## 🏗️ Architecture & Technology Stack

### Frontend Framework
- **Flutter 3.7.0**: Cross-platform UI framework
- **Dart**: Programming language
- **Material Design 3**: Modern UI components

### Backend & Services
- **Firebase Authentication**: Secure user authentication and email verification
- **Cloud Firestore**: NoSQL database for real-time data synchronization
- **Firebase Storage**: Image and media storage (planned)

### State Management & Navigation
- **Provider**: State management solution
- **Custom Navigation**: Route-based navigation with fade transitions

### Key Packages & Libraries

#### UI & Design
- `google_fonts` - Custom typography
- `flutter_animate` - Smooth animations
- `lottie` & `rive` - Advanced animations
- `responsive_framework` - Responsive layouts
- `cached_network_image` - Optimized image loading
- `shimmer` - Loading placeholders

#### Functionality
- `image_picker` - Upload service request images
- `flutter_rating_bar` - Interactive rating component
- `smooth_page_indicator` - Onboarding indicators
- `modal_bottom_sheet` - Bottom sheet modals
- `flutter_slidable` - Swipe actions
- `phosphor_flutter` - Icon library

#### Localization
- `flutter_localizations` - RTL support for Arabic interface

## 👥 User Roles

### 1. Customer (العميل)
Primary user who requests maintenance services
- Create and track service requests
- Browse and select technicians
- Rate completed services
- Manage personal profile

### 2. Technician (الفني)
Service provider registered on the platform
- Must complete profile setup before accepting orders
- Accept and manage customer requests
- Update order status
- Build reputation through ratings

### 3. Administrator (المدير)
Platform overseer with full system access
- Monitor all users and activities
- Manage user accounts (block/unblock)
- Review platform analytics
- Ensure quality standards

## 🛠️ Service Categories

The platform supports the following maintenance service types:

1. **Plumbing** (سباكة) - Pipe repairs, installations, leak fixes
2. **Electrical** (كهرباء) - Wiring, fixtures, electrical repairs
3. **Air Conditioning** (تكييف) - AC installation, maintenance, repairs
4. **Cleaning** (تنظيف) - Deep cleaning, regular maintenance
5. **Carpentry** (نجارة) - Furniture repair, custom woodwork
6. **Pest Control** (مكافحة حشرات) - Insect and pest management

Technicians can specialize in one or multiple categories.

## 🚀 Installation & Setup

### Prerequisites
- Flutter SDK 3.7.0 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account
- Git

### Step 1: Clone the Repository
```bash
git clone https://github.com/emm101011/ommal.git
cd ommal
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Firebase Setup
1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Firebase Authentication (Email/Password)
3. Create a Cloud Firestore database
4. Download configuration files:
   - `google-services.json` for Android → Place in `android/app/`
   - `GoogleService-Info.plist` for iOS → Place in `ios/Runner/`

### Step 4: Configure Firebase Options
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

### Step 5: Run the Application
```bash
# For development
flutter run

# For specific platform
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS (macOS only)
```

### Step 6: Build for Production
```bash
# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

## 🔥 Firebase Configuration

### Firestore Collections Structure

#### Users Collection (`users`)
```javascript
{
  id: string,
  email: string,
  name: string,
  phone: string,
  address: string,
  role: 'customer' | 'technician' | 'admin',
  isProfileComplete: boolean,
  createdAt: timestamp,
  // Technician-specific fields
  specialties: string[],
  bio: string,
  rating: number,
  totalOrders: number,
  isVerified: boolean,
  profileImage: string,
  isBlocked: boolean
}
```

#### Orders Collection (`orders`)
```javascript
{
  id: string,
  userId: string,
  technicianId: string,
  serviceType: string,
  address: string,
  description: string,
  status: 'pending' | 'inProgress' | 'completed' | 'cancelled',
  images: string[],
  createdAt: timestamp,
  updatedAt: timestamp,
  rating: number,
  review: string,
  isDeleted: boolean,
  cancelledBy: string
}
```

#### Notifications Collection (`notifications`)
```javascript
{
  id: string,
  userId: string,
  title: string,
  message: string,
  type: string,
  isRead: boolean,
  createdAt: timestamp,
  relatedOrderId: string
}
```

### Firestore Security Rules
Update your `firestore.rules` file to include proper security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📁 Project Structure

```
ommal/
├── lib/
│   ├── main.dart                      # Application entry point
│   ├── firebase_options.dart          # Firebase configuration
│   │
│   ├── models/                        # Data models
│   │   ├── user_model.dart           # User entity
│   │   ├── order_model.dart          # Service order entity
│   │   └── notification_model.dart   # Notification entity
│   │
│   ├── screens/                       # UI screens
│   │   ├── splash_screen.dart        # Initial loading screen
│   │   ├── login_screen.dart         # User authentication
│   │   ├── register_screen.dart      # New user registration
│   │   │
│   │   ├── home_screen.dart          # Customer dashboard
│   │   ├── technicians_list_screen.dart
│   │   ├── technician_details_screen.dart
│   │   ├── new_request_screen.dart   # Create service request
│   │   ├── my_orders_screen.dart     # Customer order history
│   │   ├── order_details_screen.dart
│   │   ├── rating_screen.dart        # Rate completed service
│   │   │
│   │   ├── technician_home_screen.dart
│   │   ├── technician_setup_screen.dart
│   │   ├── technician_orders_screen.dart
│   │   ├── technician_order_details_screen.dart
│   │   ├── technician_reviews_screen.dart
│   │   │
│   │   ├── admin_home_screen.dart
│   │   ├── admin_user_details_screen.dart
│   │   ├── admin_reviews_screen.dart
│   │   │
│   │   ├── profile_screen.dart       # User profile
│   │   ├── edit_profile_screen.dart
│   │   ├── settings_screen.dart
│   │   └── notifications_screen.dart
│   │
│   ├── services/                      # Business logic layer
│   │   ├── auth_service.dart         # Authentication operations
│   │   ├── orders_service.dart       # Order management
│   │   ├── technicians_service.dart  # Technician operations
│   │   ├── notifications_service.dart
│   │   └── dummy_data_service.dart   # Test data initialization
│   │
│   ├── widgets/                       # Reusable UI components
│   │   └── service_card.dart
│   │
│   ├── theme/                         # Design system
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_styles.dart
│   │   └── app_strings.dart
│   │
│   └── utils/                         # Helper utilities
│
├── android/                           # Android platform files
├── ios/                              # iOS platform files
├── web/                              # Web platform files
├── test/                             # Unit and widget tests
│
├── pubspec.yaml                      # Project dependencies
├── analysis_options.yaml             # Linting rules
├── firebase.json                     # Firebase configuration
├── firestore.rules                   # Database security rules
└── firestore.indexes.json            # Database indexes
```

## 📱 Application Screens

### Authentication Flow
1. **Splash Screen**: Auto-login check and app initialization
2. **Login Screen**: Email/password authentication
3. **Register Screen**: New user creation with role selection

### Customer Journey
1. **Home Screen**: Service categories and quick actions
2. **Technicians List**: Browse available technicians by specialty
3. **Technician Details**: View profile, ratings, and book service
4. **New Request**: Submit service request with details and images
5. **My Orders**: Track all service requests
6. **Order Details**: View order status and updates
7. **Rating Screen**: Provide feedback on completed service

### Technician Journey
1. **Technician Home**: Dashboard with pending requests
2. **Setup Profile**: Complete professional profile (required)
3. **Orders Management**: Accept and track assigned orders
4. **Order Details**: Update order status and communicate
5. **Reviews Dashboard**: Monitor customer feedback

### Admin Panel
1. **Admin Home**: Platform statistics and overview
2. **User Management**: View all users with filtering
3. **User Details**: User profile with block/unblock actions
4. **Reviews Monitor**: All platform reviews and ratings

## 🗃️ Data Models

### UserModel
Core user entity supporting multiple roles
```dart
enum UserRole { customer, technician, admin }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final bool isProfileComplete;
  final List<String> specialties; // Technician only
  final double rating;            // Technician only
  final bool isBlocked;           // Admin action
}
```

### OrderModel
Service request entity with lifecycle management
```dart
enum OrderStatus { pending, inProgress, completed, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final String technicianId;
  final String serviceType;
  final OrderStatus status;
  final double rating;
  final String review;
}
```

## 🔮 Future Enhancements

### Planned Features
- [ ] Real-time chat between customers and technicians
- [ ] In-app payment integration
- [ ] Service pricing and quotes
- [ ] Technician availability calendar
- [ ] Advanced search and filtering
- [ ] Push notifications (FCM)
- [ ] Multi-language support (English/Arabic)
- [ ] Service request scheduling
- [ ] Technician verification badges
- [ ] Promotional offers and discounts
- [ ] Analytics dashboard for technicians
- [ ] Customer loyalty program
- [ ] Dispute resolution system

### Technical Improvements
- [ ] Offline mode support
- [ ] Performance optimization
- [ ] Comprehensive unit and integration tests
- [ ] CI/CD pipeline setup
- [ ] Error tracking and monitoring
- [ ] A/B testing framework

## 📄 License


Tareq Jeri Al-Mutairi (طارق جري المطيري)


## 👨‍💻 Author

**Tareq Jeri Al-Mutairi**  
طارق جري المطيري


