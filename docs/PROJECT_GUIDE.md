# Oil Change App Guide

This document is for both developers and end users. It explains how the app works, how to set it up, and how offline-first sync behaves.

## End User Guide

### What this app does
- Track oil change mileage, interval, and next due distance.
- Get daily reminders at 10 AM once the threshold is exceeded.
- Scan mileage values with OCR from the camera.
- Track tours with fuel stops and see per-tour summaries.
- Work fully offline and sync when connectivity returns.

### Oil Change Screen
- Enter current mileage, last change mileage, and oil interval.
- Use the camera icon to scan mileage values.
- Tap "Oil Changed" to set last change to the current mileage.
- Tap "Save" to store values locally and sync when online.
- Notifications are enabled via the toggle and use your threshold.

### Tour Tracker Screen
- Add a tour title (optional), start and end mileage, and fuel stops.
- Each fuel stop records amount, liters, and time/location if available.
- Tap "Complete Tour" to save a finished tour.
- Drafts are auto-saved locally so you can close and continue later.
  - Drafts restore on app restart even if you never completed the tour.

## Tour Tracker (Detailed)

### Purpose
The Tour Tracker records per-trip fuel usage and calculates totals so you can compare rides.

### Steps
1) Enter a title (optional) and mileage values.
2) Add one or more fuel stops (amount and liters).
3) Review the summary totals (distance, liters, spend, average).
4) Tap "Complete Tour" to save the trip.

### Drafts and Offline
- The current tour is saved as a draft while you type.
- Drafts survive restarts and offline mode.
- The draft clears only when you complete the tour.

### Offline Use
- All data saves locally first.
- If you are offline, changes are queued locally and synced later.
- Manual sync is available in the drawer ("Sync now").

### Notifications
- Reminders are checked daily at 10 AM.
- Overdue reminders repeat daily until oil change is recorded.
- Android 13+ requires notification permission on first launch.

## Developer Guide

### Quick Start
1) Install dependencies
```
flutter pub get
```

2) Run build runner for Drift
```
dart run build_runner build --delete-conflicting-outputs
```

3) Run the app
```
flutter run
```

### Firebase Setup (Android)
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

### Architecture Overview
- Flutter + Provider (MVVM).
- Views in `lib/views/`, view models in `lib/viewmodels/`.
- Local storage uses Drift in `lib/data/local/`.
- Repositories are in `lib/services/`:
  - Remote repositories read/write Firestore.
  - Offline repositories compose local + remote.
- `OfflineSyncService` coordinates sync and status.

### Offline-First Data Flow
1) UI calls a ViewModel method.
2) ViewModel uses an OfflineRepository.
3) OfflineRepository writes to Drift immediately.
4) It attempts a remote Firestore update with a timeout.
5) A sync pass later reconciles local dirty rows.

Manual sync is exposed via the drawer. Sync status is shown in-app.

### Tour Draft Persistence
- Drafts are stored in Drift (`tour_draft_table`).
- Draft writes are debounced on text changes and when stops change.
- Draft is restored on tour screen load.
- Draft is cleared only after completing a tour.

### Notifications
- `OilViewModel` checks thresholds and schedules reminders.
- Background tasks run daily via `workmanager`.
- Notifications fire at 10 AM when thresholds are exceeded.

### Theming
- Dark mode is the default theme.
- Theme mode is stored locally.

### Project Structure (Summary)
- `lib/constants/` strings and colors
- `lib/models/` data models and enums
- `lib/data/local/` Drift database + local repositories
- `lib/services/` repositories, notifications, background, OCR, sync
- `lib/viewmodels/` app logic and state
- `lib/views/` UI screens and widgets

### Troubleshooting
- Drift "no such table" errors: fully restart the app. If needed, clear app data once to apply the new schema.
- Offline avatar load errors are handled by fallbacks in the drawer.
