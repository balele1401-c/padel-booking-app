# 🎾 Padel Court Booking App — Modern Flutter & Firebase Ecosystem

[![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%26%20Auth-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Provider](https://img.shields.io/badge/State_Management-Provider-42A5F5?style=for-the-badge)](https://pub.dev/packages/provider)
[![Midtrans](https://img.shields.io/badge/Payment_Gateway-Midtrans_Snap-0052CC?style=for-the-badge)](https://midtrans.com)
[![License](https://img.shields.io/badge/License-MIT-green.style=for-the-badge)](#license)

A state-of-the-art, publication-grade **Padel Court Booking & Management Platform** built with **Flutter**, **Firebase (Firestore & Auth)**, and **Midtrans Payment Gateway**. Designed with a modern, high-contrast Midnight Teal & Emerald Green aesthetic, real-time double-booking prevention, AI Chatbot Assistant, and a comprehensive Admin Analytics Dashboard.

---

## 🌟 Key Features

### 👤 Customer Application
- **Interactive Court Listing**: Real-time court availability, pricing per hour, operating hours, and photo galleries.
- **Visual Slot Selector**: Highlighting occupied slots (`DIBOOKING` in Rose), blocked maintenance slots (`DIBLOKIR 🔒` in Slate), and available slots in Teal. Supports 1-hour or 2-hour durations.
- **Midtrans Payment Gateway**: Seamless integration with Midtrans Snap Sandbox supporting QRIS (GoPay, OVO, Dana, ShopeePay) and Bank Virtual Accounts (BCA, Mandiri, BNI, BRI).
- **Booking History & Cancellation**: View active and historical bookings with auto-generated receipt modal. Supports **H-1 (24-hour) cancellation policy**.
- **Smart AI Chatbot Assistant**: Real-time Firestore-backed AI assistant answering court pricing, slot availability, operating hours, payment instructions, and padel rules with out-of-scope redirection.
- **User Profile Management**: Edit profile details and view verified member status.

### 🛡️ Admin Panel & Management
- **Analytics Dashboard**: 2-column metrics summary grid (Today, Week, Month Bookings & Total Confirmed Revenue) paired with a daily court occupancy bar chart built with `fl_chart`.
- **Court CRUD Operations**: Full management of courts (Add, Edit, Soft Delete, and Price adjustments).
- **Booking Management & Date Filter**: Filter incoming bookings by Date Picker and Status chips (`All`, `Pending`, `Confirmed`, `Cancelled`, `Blocked`).
- **Maintenance Slot Blocking**: Create maintenance entries (`status: 'blocked'`) to automatically prevent customers from selecting specific court slots.
- **Manual Payment Verification**: Manually confirm or reject offline/cash bookings.
- **Transaction History**: Comprehensive ledger of all payment records in `payments` collection with status filters.

---

## 🏗️ Architecture & Folder Structure

```
padel_booking_app/
├── android/                   # Android native configuration
├── docs/                      # Technical Documentation & Guides
│   ├── PRD_Lengkap_Padel_Booking_App.md
│   ├── Firestore_Security_Rules_Guide.md
│   ├── Cloud_Function_Setup_Guide.md
│   └── Manual_Testing_Checklist.md
├── firestore.rules            # Production-grade Firestore Security Rules
├── functions/                 # Firebase Cloud Functions (Node.js Proxy)
├── ios/                       # iOS native configuration
├── lib/
│   ├── core/                  # Core design tokens, theme, & constants
│   │   ├── constants/         # AppColors, AppTextStyles
│   │   ├── theme/             # AppTheme (Material 3)
│   │   └── config/            # Midtrans Configuration
│   ├── features/              # Feature modules (Clean Architecture)
│   │   ├── admin/             # Admin Dashboard, Courts, Bookings, & Payments
│   │   ├── auth/              # Login & Registration screens
│   │   └── customer/          # Home, Detail, Slot, Payment, History, Chatbot, & Profile
│   ├── models/                # Data models (CourtModel, BookingModel, PaymentModel, UserModel)
│   ├── providers/             # State Management (AuthProvider, BookingProvider, CourtProvider, PaymentProvider)
│   ├── services/              # Firebase & Midtrans Services (BookingService, CourtService, PaymentService, ChatbotService)
│   └── shared/                # Shared reusable UI widgets
└── pubspec.yaml               # Flutter dependencies manifest
```

---

## 🛠️ Tech Stack

- **Frontend**: Flutter Web & Mobile (Dart 3.x)
- **Design System**: Material 3 with Custom Theme Palette (Midnight Teal `#0D5C5B` & Emerald `#00A86B`)
- **Backend & Database**: Firebase Cloud Firestore & Firebase Authentication
- **State Management**: Provider Architecture
- **Payment Processor**: Midtrans Snap Gateway
- **Data Visualization**: `fl_chart` (Bar Chart Occupancy)
- **Security**: Firestore Security Rules (Role-Based Access Control)

---

## 🚀 Installation & Setup Guide

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.27.0`)
- [Node.js](https://nodejs.org/) (`>=18.0.0`) & [Firebase CLI](https://firebase.google.com/docs/cli)
- Google Chrome Browser (for web testing)

### 1. Clone Repository
```bash
git clone https://github.com/balele1401-c/padel-booking-app.git
cd padel_booking_app
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase Project Configuration
Create your `firebase_options.dart` and `google-services.json` using FlutterFire CLI:
```bash
flutterfire configure
```

### 4. Run Application locally
```bash
# Run on Web (Chrome)
flutter run -d chrome

# Run on Mobile (Android Emulator / Device)
flutter run
```

---

## 🛡️ Firestore Security Rules Deployment

Deploy the included production security rules to protect your database:

```bash
firebase deploy --only firestore:rules
```

*Or copy the contents of [`firestore.rules`](file:///d:/PENYIMPANAN%20TUGAS/Flutter/padel_booking_app/firestore.rules) into your Firebase Console Rules tab.*

---

## 💼 High-Value Interview & Demo Highlights

When presenting this project during job interviews or thesis defense, highlight these technical achievements:

1. **Deterministic Double-Booking Prevention**:
   - Uses deterministic document IDs (`${courtId}_${yyyy-MM-dd}_${startTime}`) and atomic Firestore operations to guarantee zero double-bookings under concurrent client requests.
2. **Role-Based Access Control (RBAC)**:
   - Strict separation between `customer` and `admin` roles, secured at both UI layer and Firestore Security Rules layer (`isAdmin()` & `isOwner()` rule guards).
3. **Midtrans Sandbox Integration**:
   - Web-compatible payment processing flow with automatic status updates (`pending` ➔ `confirmed` & `paid`).
4. **Smart AI Assistant Engine**:
   - Real-time Firestore context injection for live slot checking and out-of-scope question filtering.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
