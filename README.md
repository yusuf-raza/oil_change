# Oil Change Reminder

A Flutter Android app that tracks motorcycle oil changes. Enter current mileage, last change, and oil interval to compute the next due mileage and remaining distance. The app sends local notifications in the background (including killed state) and supports OCR-based mileage scanning. Data is stored in Firebase Firestore with Google sign-in and offline persistence.

## Features
- Manual entry for current mileage, last change, and oil interval
- Remaining distance and next due calculation
- Daily local reminders once the selected threshold is reached, plus overdue alerts
- Background checks via WorkManager
- OCR scan of dashboard mileage using ML Kit
- Unit switch (km/mi), theme toggle, and notification toggle
- Reminder threshold selection (50/100/150)
- MVVM architecture with Provider
- Firestore persistence with offline cache + Google sign-in
- Theme preference is stored locally (not in Firestore)

## Tech Stack
- Flutter + Provider (MVVM)
- Firebase Auth (Google sign-in) + Cloud Firestore
- flutter_local_notifications for local notifications
- workmanager for background execution
- google_mlkit_text_recognition + image_picker for OCR

## Project Structure
- `lib/constants/` shared strings and colors
- `lib/models/` data model + enums
- `lib/services/` storage, notifications, background, OCR, Firestore repository
- `lib/viewmodels/` state and logic
- `lib/views/` UI

## Firebase Setup (Android)
1) Create a Firebase project
2) Add Android app with package name `com.oil.change`
3) Download `google-services.json` and place it at `android/app/google-services.json`
4) Enable **Authentication** → **Google**
5) Enable **Firestore** and set rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/oilState/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

## Setup
1) Install dependencies
```
flutter pub get
```

2) Run on Android
```
flutter run
```

## Notifications
- Android 13+ requires notification permission on first launch.
- Background notifications are scheduled every 12 hours.
- Choose a reminder threshold (50/100/150) in Settings.
- Reminders repeat daily once the threshold is reached, until reset or oil change.
- Toggle notifications in Settings to disable reminders.

## OCR Mileage Scan
- Tap the camera icon on the current mileage field.
- Capture the dashboard, confirm the detected mileage, then save.

## Notes
- Use the "Oil changed" button to set the last change mileage to the current value.
- Use Settings to reset, switch units, change theme, or adjust reminder threshold.
