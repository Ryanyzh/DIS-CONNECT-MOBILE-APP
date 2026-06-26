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

---

## Overview

DisConnect Mobile is the scholar-facing interface of the DisConnect platform. Scholars can file support tickets for scholarship-related matters (reimbursements, internship forms, leave requests, etc.), track their status, communicate with assigned HR officers, and stay up-to-date with announcements — from their phone.

The app authenticates via **Firebase Authentication** and communicates with a **FastAPI** backend using a Firebase ID token as a Bearer token. File attachments are uploaded directly to **Firebase Storage**.

---

## Features

| Module             | Description                                                                                                           |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- |
| **Authentication** | Email/password sign-in via Firebase Auth                                                                              |
| **Home Dashboard** | Greeting card, ticket overview stats, recent tickets, quick actions, announcements banner                             |
| **Tickets**        | Full ticket lifecycle — browse, search, create (3-step form), view details, conversation thread, audit history        |
| **Announcements**  | Feed of notices from administrators with a full detail view                                                           |
| **Profile**        | View profile, edit display name, change password, help & support, sign out                                            |

### Ticket Creation — 3-step form

| Step                | Fields                                            |
| ------------------- | ------------------------------------------------- |
| 1 · Ticket Info     | Subject, Category (fetched from API), Priority (fetched from API) |
| 2 · Details         | Description, Requested Due Date                   |
| 3 · Review & Attach | File attachments (PDF / images / Office docs) + live preview before submitting |

Attachment upload flow: create ticket → upload each file directly to Firebase Storage at `tickets/{ticket_id}/{filename}` → POST metadata to the backend.

---

## Tech Stack

| Layer                | Technology                                             |
| -------------------- | ------------------------------------------------------ |
| Framework            | Flutter (Dart `^3.11.5`)                               |
| State Management     | Riverpod (`flutter_riverpod ^3.3.1`)                   |
| Navigation           | GoRouter (`^17.2.3`)                                   |
| Authentication       | Firebase Auth (`firebase_auth ^6.5.1`)                 |
| Database             | Cloud Firestore (`cloud_firestore ^6.4.1`)             |
| File Storage         | Firebase Storage (`firebase_storage ^12.x`)            |
| Backend API          | FastAPI (Python) — REST over HTTP                      |
| HTTP Client          | `http ^1.6.0` with Firebase ID token injection         |
| File Picker          | `file_picker ^11.x`                                    |
| Internationalisation | `intl ^0.20.2`                                         |

---

## Project Structure

```
lib/
├── app/
│   ├── app.dart                       # Root MaterialApp.router
│   └── router.dart                    # GoRouter — all named routes
│
├── core/
│   ├── network/
│   │   └── api_client.dart            # HTTP client (GET/POST + auth header)
│   └── theme/
│       ├── app_theme.dart             # ThemeData
│       └── design_system.dart         # AppColors, AppTypography, AppSpacing, AppBorderRadius
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
│   │   │   └── ticket_repository.dart  # getTickets, getTicket, createTicket,
│   │   │                               # createAttachment, getMessages, sendMessage,
│   │   │                               # getHistory, getCategories, getPriorities
│   │   ├── models/
│   │   │   └── ticket_model.dart
│   │   ├── presentation/
│   │   │   ├── ticket_list_screen.dart          # Live search + API-backed list
│   │   │   ├── create_ticket_screen.dart        # 3-step form with file attachments
│   │   │   ├── ticket_detail_screen.dart
│   │   │   ├── ticket_conversation_screen.dart
│   │   │   └── ticket_history_screen.dart
│   │   └── widgets/
│   │       ├── search_bar.dart
│   │       └── ticket_status_badge.dart
│   │
│   ├── announcements/
│   │   ├── data/
│   │   │   └── announcement_repository.dart
│   │   └── presentation/
│   │       ├── announcements_screen.dart
│   │       └── announcement_detail_screen.dart
│   │
│   └── profile/
│       └── presentation/
│           ├── profile_screen.dart
│           ├── edit_profile_screen.dart      # Updates Firebase Auth display name
│           ├── change_password_screen.dart   # Re-auth + updatePassword via Firebase Auth
│           └── help_support_screen.dart
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
| Firebase Project                                            | Authentication (email/password) + Firestore + Storage enabled |
| FastAPI Backend                                             | Running with `--host 0.0.0.0` (see Getting Started) |

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

Run the FastAPI backend with `--host 0.0.0.0` so it accepts connections from both the simulator and real devices on the same network:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

> **Simulator:** `127.0.0.1` works fine.
>
> **Real device:** The device must be on the same WiFi as your Mac. Update `baseUrl` in [`lib/core/network/api_client.dart`](lib/core/network/api_client.dart) to your Mac's local IP (e.g. `http://192.168.1.x:8000`). Find it with:
> ```bash
> ipconfig getifaddr en0
> ```

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

### File attachment flow

```
CreateTicketScreen._submit()
  ├─ POST /api/v1/tickets          →  get ticket_id
  ├─ FirebaseStorage.putData()     →  upload file to  tickets/{ticket_id}/{filename}
  └─ POST /api/v1/tickets/:id/attachments  →  record metadata on backend
```

### Navigation

All routes are defined in [`lib/app/router.dart`](lib/app/router.dart) using **GoRouter** with a `StatefulShellRoute.indexedStack` that drives the persistent bottom navigation bar.

---

## App Routes

| Path                          | Screen                        |
| ----------------------------- | ----------------------------- |
| `/login`                      | Login                         |
| `/home`                       | Home dashboard                |
| `/tickets`                    | Ticket list (searchable)      |
| `/tickets/create`             | Create ticket (3-step form)   |
| `/tickets/:id`                | Ticket detail                 |
| `/tickets/:id/conversation`   | Conversation & messages       |
| `/tickets/:id/history`        | Ticket audit history          |
| `/announcements`              | Announcements feed            |
| `/announcements/:id`          | Announcement detail           |
| `/profile`                    | Scholar profile               |
| `/profile/edit`               | Edit display name             |
| `/profile/change-password`    | Change password               |
| `/profile/help`               | Help & support                |
