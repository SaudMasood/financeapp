# 💰 Finance App

A modern, clean **personal finance tracking mobile application** built with **Flutter**. Track income and expenses, set monthly budgets by category, view visual spending reports, and manage everything with a secure, offline-first architecture backed by  **Firebase**.

---

## 👤 Author

**Developed by: Saud Masood**
This project, including all source code, design decisions, and documentation, is the original work of **Saud Masood**.

---

## 📱 Overview

Finance App is a full-featured personal finance tracker designed with a **local-first, cloud-backed** architecture — meaning the app is **fully usable offline**, while still keeping a secure backup of your data in the cloud whenever you're connected.

---

## 🧩 Core Screens

| Screen | Description |
|---|---|
| **Splash Screen** | Branded loading screen that checks login/session state and routes the user accordingly. |
| **Login Screen** | Firebase email/password authentication with optional biometric quick-login. |
| **Signup Screen** | New account creation via Firebase Authentication. |
| **Home / Dashboard** | At-a-glance balance, income vs. expense summary, and recent transactions. |
| **Transactions Log** | Full transaction history with **search** and **income/expense filters**. |
| **Budget Tracking** | Set and monitor monthly spending limits per category with progress indicators. |
| **Reports / Analytics** | Visual bar chart and pie chart breakdowns, plus rule-based spending insights. |
| **Settings** | Dark mode toggle, notification preferences, and secure logout. |

---

## ✨ Key Features

- ✅ **Add Income** — log incoming money entries with category and notes.
- ✅ **Add Expenses** — log expenditures with category, date, and notes.
- ✅ **Categories** — organize every entry into distinct spending/earning groups.
- ✅ **Charts** — visual bar chart and pie chart breakdowns of income vs. expenses using `fl_chart`.
- ✅ **Search & Filters** — instantly find transactions by text, or filter by Income/Expense.

---

## 🎁 Bonus Features

| Feature | Status |
|---|---|
| **Firebase Integration** | ✅ Implemented — real Firebase Authentication (sign up, login, logout) and Firestore cloud sync. |
| **Offline Mode** | ✅ Fully implemented — `sqflite` is the single source of truth, so the app works with **zero internet connection**. |
| **Biometric Login** | ✅ Implemented via `local_auth` — Face ID / Fingerprint quick unlock after an initial Firebase login. |
| **AI-Powered Spending Insights** | ✅ Implemented — an on-device, rule-based insight engine analyzes savings rate and top spending categories (no API key or internet required). |
| **Push Notifications** | 🔜 Not yet implemented — planned for a future release using Firebase Cloud Messaging. |

---

## 🏗️ Architecture & State Management

- **State Management:** Plain `StatefulWidget` + `setState()`. Each screen owns and reloads its own state, keeping the codebase lightweight and easy to reason about.
- **Data Layer — Local-first, cloud-backed:**
  - **Local (source of truth):** `sqflite`, managed through `lib/database/database_helper.dart`. Two core tables: `transactions` and `budgets`. Every screen reads and writes here **first**, so the app is always usable offline.
  - **Cloud (best-effort backup):** `lib/services/firebase_service.dart` mirrors new transactions and budgets to Firestore under `users/{uid}/transactions` and `users/{uid}/budgets`. If there's no internet, this sync silently queues/fails without affecting the local save — the user never loses data.

### 📂 Folder Structure

```
lib/
├── main.dart                        # App entry point, Firebase init, DB setup
├── firebase_options.dart            # Firebase project configuration
├── models/
│   ├── transaction_model.dart
│   └── budget_model.dart
├── database/
│   └── database_helper.dart         # sqflite setup & queries
├── services/
│   ├── firebase_service.dart        # Auth + Firestore sync
│   └── biometric_service.dart       # Face ID / fingerprint auth
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── signup_screen.dart
    ├── lock_screen.dart
    ├── home_screen.dart             # Bottom nav container + dashboard
    ├── transaction_screen.dart
    ├── add_transaction_screen.dart
    ├── budget_screen.dart
    ├── report_screen.dart
    └── settings_screen.dart
```

---

## 📦 Packages & Technologies Used

| Package | Purpose |
|---|---|
| `sqflite` | Local SQLite database for offline-first storage |
| `path` | Building the local database file path |
| `shared_preferences` | Persisting app settings (dark mode, notifications) |
| `intl` | Date formatting |
| `fl_chart` | Bar chart and pie chart visualizations |
| `local_auth` | Biometric (fingerprint / Face ID) login |
| `firebase_core` | Firebase SDK initialization |
| `firebase_auth` | Email/password sign up, login, logout |
| `cloud_firestore` | Cloud backup and sync of transactions and budgets |

---

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK (stable channel)
- A Firebase project (free tier is sufficient)

### Steps

1. **Clone the repository**
   ```bash
   git clone <your-repository-url>
   cd finance_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Authentication → Sign-in method → Email/Password**
   - Create a **Firestore Database** (start in test mode for development)
   - Install the FlutterFire CLI and run it from the project root:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
     This replaces the placeholder `lib/firebase_options.dart` with your project's real configuration.

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build a release APK**
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

> ⚠️ **Note:** Until Firebase is configured (Step 3), the app remains fully functional offline, but Login/Signup and cloud sync will not work.

---

## 🔐 Security Notes

- Passwords must be **6+ characters** (Firebase Authentication's minimum requirement).
- Firestore access is scoped per-user via `users/{uid}/...` — production deployments should enforce this with proper **Firestore Security Rules** requiring `request.auth.uid == userId`.

---

## 🎨 Currency

Currency is displayed as `Rs.` by default — this can be changed in the relevant screen files for a different currency symbol.

---

## 📄 License & Copyright

**© 2026 Saud Masood. All rights reserved.**

This project, including its source code, architecture, and documentation, is the **original and exclusive work of Saud Masood**. Unauthorized copying, redistribution, or use of this project, in whole or in part, without explicit written permission from the author is strictly prohibited.

---

## 🙋 Contact

For questions, feedback, or collaboration inquiries regarding this project, please reach out to **Saud Masood** directly.
Email: saudmasood974@gmail.com

