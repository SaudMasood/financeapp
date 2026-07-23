# Finance App

A personal finance tracking app built with Flutter. Track income and expenses,
set monthly budgets per category, view spending reports with charts, and log
in with a real Firebase account (plus optional biometric login).

## Screens

- Splash Screen
- Login Screen (Firebase email/password + biometric)
- Signup Screen (Firebase email/password account creation)
- Home / Dashboard (balance, income/expense summary, recent transactions)
- Transactions (search + filter by income/expense)
- Add Transaction (income or expense, category, date, note)
- Budget Tracking (per-category monthly limits with progress bars)
- Reports (bar chart, pie chart, and rule-based spending insights)
- Settings (dark mode toggle, notifications toggle, logout)

## State Management

Plain `StatefulWidget` + `setState()`. No external state management package.
Each screen loads its own data in `initState()` and re-loads after any change.

## Data Layer (local-first + cloud backup)

- **Local (source of truth, works fully offline):** `sqflite`, via
  `lib/database/database_helper.dart`. Two tables: `transactions` and `budgets`.
  Every screen reads/writes here first, so the app works with no internet.
- **Cloud (Firebase, bonus feature):** `lib/services/firebase_service.dart`
  handles:
  - Firebase Auth: sign up, sign in, sign out, current user.
  - Firestore: a best-effort copy of each new transaction/budget is pushed to
    `users/{uid}/transactions` and `users/{uid}/budgets`. If there's no
    internet, this silently fails/queues and the local sqflite save is
    unaffected — the user never loses data or sees an error for this part.

## Folder Structure

```
lib/
  main.dart
  firebase_options.dart        (placeholder — see Firebase Setup below)
  models/
    transaction_model.dart
    budget_model.dart
  database/
    database_helper.dart
  services/
    firebase_service.dart
  screens/
    splash_screen.dart
    login_screen.dart
    signup_screen.dart
    home_screen.dart           (bottom nav container + dashboard body)
    add_transaction_screen.dart
    transaction_screen.dart
    budget_screen.dart
    report_screen.dart
    settings_screen.dart
```

## Packages Used

| Package | Purpose |
|---|---|
| sqflite | Local SQLite database (offline storage) |
| path | Building the database file path |
| shared_preferences | Saving app settings (dark mode, notifications) |
| intl | Date formatting |
| fl_chart | Bar chart and pie chart in Reports |
| local_auth | Biometric (fingerprint / Face ID) login |
| firebase_core | Firebase initialization |
| firebase_auth | Email/password sign up, login, logout |
| cloud_firestore | Cloud backup/sync of transactions and budgets |

## Bonus Features

- Offline mode: fully implemented — sqflite is the source of truth, so all
  core features work with no internet connection.
- Firebase integration: implemented — real email/password auth (sign up +
  login) and Firestore sync, layered on top of the offline-first local data.
- Biometric login: implemented via `local_auth` (requires a prior successful
  email/password login on the device, since it reuses the Firebase session).
- AI-powered spending insights: implemented as a rule-based, on-device insight
  generator in `report_screen.dart` (checks savings rate and top spending
  category — no API key or internet required).
- Push notifications: not implemented in this build due to the time limit.
  `firebase_service.dart` already establishes the per-user Firestore
  structure, so adding Firebase Cloud Messaging or a local
  `flutter_local_notifications` budget-limit alert would attach cleanly here.

## Firebase Setup (required before running)

The app will not build/run against a real backend until you connect it to
your own Firebase project:

1. Create a project at https://console.firebase.google.com
2. In the project, enable **Authentication → Sign-in method → Email/Password**.
3. Create a **Firestore Database** (start in test mode for development).
4. Install the FlutterFire CLI and run it from the project root:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This replaces the placeholder `lib/firebase_options.dart` in this repo
   with your real project's config and registers your Android/iOS apps.
5. `flutter pub get`
6. `flutter run`

Until step 4 is done, `lib/firebase_options.dart` contains placeholder values
and Firebase calls will fail — the app is otherwise fully functional offline
except for login/signup, which require Firebase Auth to be configured.

## Setup / Installation

1. Install Flutter (stable channel).
2. Clone this repository.
3. Complete the **Firebase Setup** steps above.
4. Run:
   ```
   flutter pub get
   flutter run
   ```
5. Build a release APK:
   ```
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

## Notes

- Currency is shown as `Rs.` — change this in the screens for a different
  currency symbol.
- Passwords must be 6+ characters (Firebase Auth's minimum).
