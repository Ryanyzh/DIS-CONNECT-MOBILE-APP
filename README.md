# DisConnect Mobile

A Flutter mobile application for scholars to manage support tickets, view announcements, and communicate with scholarship administrators — all in one place.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [App Routes](#app-routes)
- [Design System](#design-system)

---

## Overview

DisConnect Mobile is the scholar-facing interface of the DisConnect platform. Scholars can file support tickets for scholarship-related matters (reimbursements, internship forms, leave requests, etc.), track their status, communicate with assigned HR officers, and stay up-to-date with announcements — from their phone.

The app authenticates via **Firebase Authentication** and communicates with a **FastAPI** backend using a Firebase ID token as a Bearer token.

---

## Features

| Module             | Description                                                                                                           |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- |
| **Authentication** | Email/password sign-in via Firebase Auth                                                                              |
| **Home Dashboard** | Greeting card, ticket overview stats, recent tickets, quick actions, announcements banner                             |
| **Tickets**        | Full ticket lifecycle — browse, filter/search, create (3-step form), view details, conversation thread, audit history |
| **Announcements**  | Read-only feed of notices from administrators                                                                         |
| **Profile**        | Scholar profile view and sign-out                                                                                     |

### Ticket Creation — 3-step form

| Step                | Fields                                            |
| ------------------- | ------------------------------------------------- |
| 1 · Ticket Info     | Subject, Category, Priority                       |
| 2 · Details         | Description, Requested Due Date                   |
| 3 · Review & Attach | File attachments + live preview before submitting |

---

## Tech Stack

| Layer                | Technology                                     |
| -------------------- | ---------------------------------------------- |
| Framework            | Flutter (Dart `^3.11.5`)                       |
| State Management     | Riverpod (`flutter_riverpod ^3.3.1`)           |
| Navigation           | GoRouter (`^17.2.3`)                           |
| Authentication       | Firebase Auth (`firebase_auth ^6.5.1`)         |
| Database             | Cloud Firestore (`cloud_firestore ^6.4.1`)     |
| Backend API          | FastAPI (Python) — REST over HTTP              |
| HTTP Client          | `http ^1.6.0` with Firebase ID token injection |
| Internationalisation | `intl ^0.20.2`                                 |

---

## Project Structure

```
lib/
├── app/
│   ├── app.dart                       # Root MaterialApp.router
│   └── router.dart                    # GoRouter — all named routes
│
├── core/
│   ├── constants/                     # App-wide constants
│   ├── network/
│   │   └── api_client.dart            # HTTP client (GET/POST + auth header)
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData
│   │   └── design_system.dart         # AppColors, AppTypography, AppSpacing, AppBorderRadius
│   └── widgets/
│       └── app_button.dart            # Shared button component
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   └── presentation/
│   │       └── login_screen.dart
│   │
│   ├── home/
│   │   ├── presentation/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── greeting_header.dart
│   │       ├── overview_stats_card.dart
│   │       ├── quick_actions_section.dart
│   │       ├── recent_tickets_section.dart
│   │       └── announcement_banner.dart
│   │
│   ├── tickets/
│   │   ├── data/
│   │   │   └── ticket_repository.dart
│   │   ├── models/
│   │   │   └── ticket_model.dart
│   │   ├── presentation/
│   │   │   ├── ticket_list_screen.dart
│   │   │   ├── create_ticket_screen.dart      # 3-step form
│   │   │   ├── ticket_detail_screen.dart
│   │   │   ├── ticket_conversation_screen.dart
│   │   │   └── ticket_history_screen.dart
│   │   └── widgets/
│   │       ├── search_bar.dart
│   │       └── ticket_status_badge.dart
│   │
│   ├── announcements/
│   │   └── presentation/
│   │       └── announcements_screen.dart
│   │
│   └── profile/
│       └── presentation/
│           └── profile_screen.dart
│
├── shared/
│   └── widgets/
│       └── main_shell.dart            # Bottom nav shell (Home | Tickets | Announcements | Profile)
│
├── firebase_options.dart              # Generated by FlutterFire CLI
└── main.dart                          # Entry point — Firebase init + runApp
```

---

## Prerequisites

Ensure the following are installed before running the project.

| Requirement                                                 | Notes                                               |
| ----------------------------------------------------------- | --------------------------------------------------- |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | Stable channel, Dart `^3.11.5`                      |
| [Xcode](https://developer.apple.com/xcode/)                 | iOS 17+ SDK (for iOS simulator / device)            |
| [Android Studio](https://developer.android.com/studio)      | With Android SDK (for Android emulator / device)    |
| [CocoaPods](https://cocoapods.org/)                         | `sudo gem install cocoapods`                        |
| Firebase Project                                            | Authentication (email/password) + Firestore enabled |
| FastAPI Backend                                             | Python backend running at `http://127.0.0.1:8000`   |

Verify your Flutter environment is healthy before proceeding:

```bash
flutter doctor
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd disconnect_mobile
```

### 2. Configure Firebase

The native Firebase config files are **not committed to version control** and must be added manually.

**Android — `google-services.json`**

1. Open the [Firebase Console](https://console.firebase.google.com/) → your project → Project Settings → Android app
2. Download `google-services.json`
3. Place it at `android/app/google-services.json`

**iOS — `GoogleService-Info.plist`**

1. Firebase Console → Project Settings → iOS app
2. Download `GoogleService-Info.plist`
3. Place it at `ios/Runner/GoogleService-Info.plist`

> If you need to regenerate `firebase_options.dart`, install the FlutterFire CLI and run `flutterfire configure`:
>
> ```bash
> dart pub global activate flutterfire_cli
> flutterfire configure
> ```

### 3. Install Flutter dependencies

```bash
flutter pub get
```

### 4. Install iOS CocoaPods dependencies

```bash
cd ios && pod install && cd ..
```

### 5. Start the backend

The app expects the FastAPI backend to be running locally. From the backend repository:

```bash
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

> The base URL is set in [`lib/core/network/api_client.dart`](lib/core/network/api_client.dart). Update it to point to a staging or production server when deploying.

### 6. Run the app

```bash
# See all connected devices and simulators
flutter devices

# Run on a specific device
flutter run -d <device-id>

# Common shorthands
flutter run -d ios       # iOS Simulator
flutter run -d android   # Android Emulator
```

### 7. Build for release (optional)

```bash
# Android — APK
flutter build apk --release

# Android — App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires a valid provisioning profile)
flutter build ios --release
```

---

## Architecture

The project follows a **feature-first** folder structure. Each product feature owns its own `data/`, `models/`, `presentation/`, and `widgets/` layers, keeping concerns isolated and easy to navigate.

### Authentication flow

```
App launch
  └─ Firebase.initializeApp()
       └─ GoRouter auth redirect
            ├─ No signed-in user  →  /login
            └─ Signed-in user     →  /home
```

### API request flow

```
Screen / Widget
  └─ Repository method call
       └─ ApiClient.get() / .post()
            └─ Attaches Firebase ID token as  Authorization: Bearer <token>
                 └─ FastAPI backend verifies token  →  returns data
```

### Navigation

All routes are defined in [`lib/app/router.dart`](lib/app/router.dart) using **GoRouter** with a `StatefulShellRoute.indexedStack` that drives the persistent bottom navigation bar.

---

## App Routes

| Path                        | Screen                      |
| --------------------------- | --------------------------- |
| `/login`                    | Login                       |
| `/home`                     | Home dashboard              |
| `/tickets`                  | Ticket list                 |
| `/tickets/create`           | Create ticket (3-step form) |
| `/tickets/:id`              | Ticket detail               |
| `/tickets/:id/conversation` | Conversation & messages     |
| `/tickets/:id/history`      | Ticket audit history        |
| `/announcements`            | Announcements feed          |
| `/profile`                  | Scholar profile             |
