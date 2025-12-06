# Maintenance Services Platform (Ommal)

![Flutter](https://img.shields.io/badge/Flutter-3.7.0-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![Platform](https://img.shields.io/badge/Platform-iOS%20|%20Android%20|%20Web-lightgrey)
![License](https://img.shields.io/badge/License-University%20Project-blue)

A comprehensive mobile application connecting customers with professional maintenance technicians across multiple service categories. This platform streamlines the process of requesting, managing, and tracking home maintenance services with real-time updates and integrated rating systems.

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture & Technology Stack](#architecture--technology-stack)
- [User Roles](#user-roles)
- [Service Categories](#service-categories)
- [Installation & Setup](#installation--setup)
- [Firebase Configuration](#firebase-configuration)
- [Project Structure](#project-structure)
- [Application Screens](#application-screens)
- [Data Models](#data-models)
- [Future Enhancements](#future-enhancements)
- [Author](#author)

## 🎯 Overview

A Flutter-based maintenance services platform connecting customers with technicians. The app features three user roles (Customer, Technician, Administrator) with real-time order tracking, ratings system, and multi-service category support.

## ✨ Key Features

- **Multi-role system**: Customer, Technician, and Admin interfaces
- **Service requests**: Create and manage maintenance orders with images
- **Real-time tracking**: Order status updates and notifications
- **Rating system**: Review and rate completed services
- **User management**: Admin controls for blocking users and monitoring reviews
- **Profile management**: Complete profiles for technicians with specialties

## 🏗️ Technology Stack

- **Flutter 3.7.0** - Cross-platform framework
- **Firebase Auth** - User authentication
- **Cloud Firestore** - Database
- **Provider** - State management
- **Key packages**: `image_picker`, `flutter_rating_bar`, `google_fonts`, `lottie`, `rive`, `responsive_framework`

## 👥 User Roles

1. **Customer** - Request services, browse technicians, rate services
2. **Technician** - Accept orders, manage requests, update status
3. **Administrator** - Manage users, monitor reviews, access analytics

## 🛠️ Service Categories

Plumbing, Electrical, Air Conditioning, Cleaning, Carpentry, Pest Control

## 🚀 Installation & Setup

```bash
# Clone repository
git clone https://github.com/emm101011/ommal.git
cd ommal

# Install dependencies
flutter pub get

# Configure Firebase
flutterfire configure

# Run app
flutter run
```

## 🔥 Firebase Configuration

**Firestore Collections**: `users`, `orders`, `notifications`

**Authentication**: Email/Password enabled

See `firestore.rules` for security configuration.

## 📁 Project Structure

```
lib/
├── models/          # Data models (User, Order, Notification)
├── screens/         # 22 UI screens for all user roles
├── services/        # Business logic (Auth, Orders, Technicians)
├── widgets/         # Reusable components
└── theme/           # Styling and colors
```

## 🗃️ Data Models

- **UserModel**: Supports Customer, Technician, and Admin roles
- **OrderModel**: Tracks service requests with status (pending, inProgress, completed, cancelled)
- **NotificationModel**: Push notifications for order updates

## 🔮 Future Enhancements

- Real-time chat functionality
- In-app payment integration
- Push notifications (FCM)
- Multi-language support

## 👨‍💻 Author

**Tareq Jeri Al-Mutairi** (طارق جري المطيري)  
