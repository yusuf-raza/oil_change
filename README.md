# Oil Change Reminder

A Flutter Android app that tracks motorcycle oil changes. Enter current mileage, oil interval, and last change to compute the next due mileage and remaining distance. The app sends local notifications in the background (including killed state) and supports OCR-based mileage scanning.

## Features
- Manual entry for current mileage, last change, and oil interval
- Remaining distance and next due calculation
- Local notifications at 150/100/50 remaining and when overdue
- Background checks via WorkManager
- OCR scan of dashboard mileage using ML Kit
- Unit switch (km/mi) and theme toggle
- MVVM architecture with Provider

## Tech Stack
- Flutter + Provider (MVVM)
- Firebase Auth (anonymous) + Firestore for persistence
- flutter_local_notifications for local notifications
- workmanager for background execution
- google_mlkit_text_recognition + image_picker for OCR

## Project Structure
- `lib/constants/` shared strings and colors
- `lib/models/` data model
- `lib/services/` storage, notifications, background, OCR
- `lib/viewmodels/` state and logic
- `lib/views/` UI

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
- Toggle notifications in Settings to disable reminders.

## OCR Mileage Scan
- Tap the camera icon on the current mileage field.
- Capture the dashboard, confirm the detected mileage, then save.

## Notes
- Use the "Oil changed" button to set the last change mileage to the current value.
- Use Settings to reset, switch units, or change theme.
