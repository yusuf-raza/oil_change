# Oil Change Reminder

A Flutter Android app that tracks motorcycle oil changes and tour fuel usage. Enter current mileage, last change, and oil interval to compute the next due mileage and remaining distance. The app sends local notifications in the background (including killed state), supports OCR-based mileage scanning, and stores everything offline-first with sync to Firebase Firestore.

## Features
- Manual entry for current mileage, last change, and oil interval
- Remaining distance and next due calculation
- Daily local reminders at 10 AM once the selected threshold is reached, plus overdue alerts
- Background checks via WorkManager
- OCR scan of dashboard mileage using ML Kit
- Unit switch (km/mi) and notification toggle
- Reminder threshold selection (50/100/150)
- Tour tracker with fuel stops, totals, and per-tour summaries
- Offline-first data via Drift with manual sync control
- MVVM architecture with Provider
- Firestore persistence + Google sign-in
- Dark mode is the default theme

## Tech Stack
- Flutter + Provider (MVVM)
- Firebase Auth (Google sign-in) + Cloud Firestore
- flutter_local_notifications for local notifications
- workmanager for background execution
- google_mlkit_text_recognition + image_picker for OCR
- Drift (local database)

## Project Structure
- `lib/constants/` shared strings and colors
- `lib/models/` data model + enums
- `lib/data/local/` Drift database + local repositories
- `lib/services/` storage, notifications, background, OCR, repositories, sync
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
    match /users/{uid}/tours/{tourId} {
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
- Background notifications are scheduled daily.
- Choose a reminder threshold (50/100/150) in Settings.
- Reminders repeat daily at 10 AM once the threshold is reached, until reset or oil change.
- Toggle notifications in Settings to disable reminders.

## OCR Mileage Scan
- Tap the camera icon on the current mileage field.
- Capture the dashboard, confirm the detected mileage, then save.

## Offline Sync
- All data is written locally first and synced to Firestore when online.
- Use the manual "Sync now" action in the drawer to force a push/pull.
- Tour drafts are saved locally so in-progress entries survive restarts.

## Tour Tracker
The Tour Tracker helps log fuel usage per ride and summarizes each trip.

### How to use
- Enter a tour title (optional), start mileage, and end mileage.
- Add fuel stops with amount and liters; location is captured when available.
- Review totals (distance, fuel, spend, average).
- Tap "Complete Tour" to save and archive the tour.

### Draft behavior
- Drafts auto-save locally as you type.
- Closing or restarting the app keeps the draft.
- Draft clears only after completing the tour.

## Troubleshooting
- If you see a Drift "no such table" error after an update, fully restart the app. If it persists, clear app data once so the latest schema applies.
- If you are offline and profile images fail to load, the drawer will fall back to a placeholder avatar automatically.

## Notes
- Use the "Oil changed" button to set the last change mileage to the current value.
- Use Settings to reset, switch units, change theme, or adjust reminder threshold.
