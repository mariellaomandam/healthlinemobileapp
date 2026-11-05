# HealthLine PH

**A Flutter-Based Healthcare Appointment and Clinic Management Application**

## Project Overview

HealthLine PH is a mobile application developed using Flutter to support communication between patients and healthcare providers. The application is designed to help patients discover healthcare services, view doctors, manage appointments, and communicate with clinics.

Healthcare providers can use the clinic interface to manage their clinic profiles, provide doctor information, publish available schedules, and handle appointment requests.

## Objectives

- Provide patients with access to clinic and healthcare service information.
- Allow patients to view doctors and their specialties.
- Support appointment scheduling and appointment request management.
- Provide messaging functionality between patients and clinics.
- Allow clinics to manage their profiles and doctor information.
- Provide a consistent user interface for patient and clinic workflows.

## Key Features

### Patient Features
- Patient login interface.
- Patient dashboard.
- Popular healthcare service categories.
- Clinic directory and clinic information.
- Doctor listing and availability viewing.
- Appointment management.
- Messaging interface.
- Profile and settings screen.

### Clinic Features
- Clinic login interface.
- Clinic dashboard.
- Clinic profile management.
- Doctor information management.
- Schedule and availability management.
- Appointment request management.
- Messaging interface.

*Feature availability depends on the implemented screen functionality and Firebase configuration in the current project version.*

## Technologies Used

- **Flutter** — cross-platform application development.
- **Dart** — primary programming language.
- **Firebase Core** — Firebase initialization.
- **Cloud Firestore** — cloud database for application data, where configured.
- **Firebase Authentication** — user authentication, where configured.
- **Riverpod** — state management and provider access.
- **Material Design 3** — user interface design.

## Application Architecture

The project separates its application entry point, screens, and supporting services into different files.

- `main.dart` initializes Firebase, registers Riverpod's `ProviderScope`, configures the application theme, and defines named routes.
- `screens/` contains the patient and clinic user interfaces.
- `services/` contains supporting service logic, including Firestore operations.
- `models/` contains data models.
- `repositories/` provides an abstraction for accessing application data.
- `providers/` contains Riverpod providers used to expose data and application state.

The exact architecture and available features depend on the files included in the current repository version.

## Installation and Setup

### Prerequisites

Install the following tools before running the project:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or another supported Flutter development environment
- A Firebase project configured for the application

### 1. Clone the repository

```bash
git clone https://github.com/UIC-CCS-MOBILE-DEVELOPMENT-2026-2027/HealthLinePH-Undangan-Pavo.git
```

### 2. Open the project directory

```bash
cd HealthLinePH-Undangan-Pavo
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Ensure the project has the correct Firebase configuration files, including `firebase_options.dart`, and that the Android application is registered in the intended Firebase project.

Enable the Firebase services required by the implemented features and configure the appropriate Firestore security rules.

Do not commit private credentials or sensitive configuration files to a public repository.

### 5. Run the application

```bash
flutter run
```

## Build an Android APK

To build a release APK, run:

```bash
flutter build apk --release
```

The generated APK is normally available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Testing and Code Analysis

Run Flutter's static analyzer:

```bash
flutter analyze
```

Run the project's available automated tests:

```bash
flutter test
```

Successful compilation does not necessarily mean that every feature or Firebase workflow has been fully tested.

## Privacy and Security

The application may process user account information, clinic details, appointment data, and messages, depending on the implemented features.

- Configure Firestore security rules to restrict access to authorized users.
- Avoid exposing sensitive user information in logs or public repositories.
- Protect Firebase configuration and any private credentials.
- Test authentication and data access permissions before deployment.

## AI Assistance Disclosure

AI tool, ChatGPT have been used during development to assist with code explanations, documentation, debugging, and implementation suggestions. The specific tools and extent of assistance should be described in the accompanying `AI_DISCLOSURE.md` file.

## Project Status

This repository contains the HealthLine PH application source code. Feature completeness, compatibility, and deployment readiness should be assessed against the current codebase and tested application build.

## License

No license is specified in this README.

## Members:

Pavo, M.
Undangan, V.S.

This is a school project deliverable.

