class AppStrings {
  static const appTitle = 'Oil Change';
  static const headline = 'Oil Change';
  static const subtitle = 'Keep your engine smooth with a simple reminder.';
  static const settingsTitle = 'Settings';
  static const unitsTitle = 'Units';
  static const themeTitle = 'Theme';
  static const notificationsTitle = 'Notifications';
  static const notificationLeadTitle = 'Reminder threshold';
  static const historyTitle = 'History';
  static const historyEmpty = 'No oil changes yet.';
  static const historyIntervalPrefix = 'Oil changed after';
  static const historyIntervalUnknown = '--';
  static const clearHistory = 'Clear history';
  static const clearHistoryTitle = 'Clear history?';
  static const clearHistoryBody = 'This removes all saved oil change entries.';
  static const historyLocationUnknown = 'Location unknown';
  static const tourTitle = 'Tour Tracker';
  static const tourSubtitle = 'Track mileage and fuel stops per ride.';
  static const tourTitleLabel = 'Tour title';
  static const tourMileageTitle = 'Tour mileage';
  static const tourStartMileage = 'Start odometer';
  static const tourEndMileage = 'End odometer';
  static const tourDistanceLabel = 'Distance:';
  static const tourDistancePlaceholder = 'Distance: --';
  static const tourFuelStopsTitle = 'Fuel stops';
  static const tourFuelAmount = 'Amount (PKR)';
  static const tourFuelLiters = 'Fuel (liters)';
  static const tourAddFuelStop = 'Add fuel stop';
  static const tourNoStops = 'No fuel stops added yet.';
  static const tourComplete = 'Complete tour';
  static const tourSummaryHeader = 'Summary';
  static const tourSummaryMileage = 'Mileage:';
  static const tourSummaryAverage = 'Avg fuel:';
  static const tourSummaryFuel = 'Total fuel:';
  static const tourSummarySpend = 'Total spend:';
  static const tourSummaryError =
      'Enter start/end mileage to complete the tour.';
  static const tourReset = 'Start new tour';
  static const tourSaved = 'Tour saved.';
  static const tourListTitle = 'Past tours';
  static const tourListEmpty = 'No tours saved yet.';
  static const tourLoading = 'Loading tours...';
  static const tourMapTitle = 'Fuel stops map';
  static const tourMapEmpty = 'No map data available.';
  static const tourMapFullscreen = 'Full screen map';
  static const tourDelete = 'Delete';
  static const tourDeleteTitle = 'Delete this tour?';
  static const tourDeleteBody = 'This cannot be undone.';
  static const homeTab = 'Home';
  static const tourTab = 'Tour';
  static const tourFuelStopError = 'Enter both amount and liters.';
  static const tourFuelStopPositiveError =
      'Amount and liters must be greater than zero.';
  static const tourLocationUnknown = 'Location unknown';
  static const kilometers = 'Kilometers';
  static const miles = 'Miles';
  static const light = 'Light';
  static const dark = 'Dark';
  static const save = 'Save';
  static const oilChanged = 'Oil changed';
  static const oilChangedSaving = 'Saving...';
  static const reset = 'Reset';
  static const resetTitle = 'Reset all values?';
  static const resetBody = 'This clears mileage, interval, and reminder settings.';
  static const cancel = 'Cancel';
  static const confirmMileageTitle = 'Confirm mileage';
  static const confirmMileageLabel = 'Current mileage';
  static const confirmLastChangeLabel = 'Last change mileage';
  static const scanMileageTooltip = 'Scan mileage';
  static const scanValueTooltip = 'Scan value';
  static const settingsTooltip = 'Settings';
  static const resetTooltip = 'Reset';
  static const accountTitle = 'Account';
  static const accountAnonymous = 'Signed in anonymously';
  static const accountSignedIn = 'Signed in';
  static const signInWithGoogle = 'Sign in with Google';
  static const signOut = 'Sign out';
  static const syncNow = 'Sync now';
  static const syncComplete = 'Sync complete.';
  static const syncFailed = 'Sync failed:';
  static const syncing = 'Syncing...';
  static const syncStatusLabel = 'Last sync:';
  static const syncNever = 'Last sync: never';

  static const currentMileageLabel = 'Current mileage';
  static const yourMileageTitle = 'Your mileage';
  static const lastChangeLabel = 'Last change';
  static const intervalLabel = 'Oil interval';
  static const metricsLastChange = 'Last change';
  static const metricsNextDue = 'Next due';
  static const metricsRemaining = 'Remaining';
  static const placeholder = '--';
  static const statusDue = 'Due';
  static const statusSoon = 'Soon';
  static const statusOk = 'OK';
  static const dueMessage = 'Time for an oil change.';
  static const soonMessage = 'Oil change due soon.';
  static const okMessage = 'You are good to go.';

  static const notificationDueTitle = '🔴 Oil change due';
  static const notificationSoonTitle = '🟠 Oil change soon';
  static const notificationDueBody =
      'Your vehicle needs an oil change! It has ran past the oil interval';
  static const notificationSoonBody = 'About';
  static const notificationSoonSuffix = 'remaining.';

  static const notificationChannelId = 'oil_change_reminders';
  static const notificationChannelName = 'Oil Change Reminders';
  static const notificationChannelDescription =
      'Notifications for upcoming oil changes';
  static const oilChangeTaskName = 'oilChangeReminderTask';

  static const unitKmShort = 'km';
  static const unitMiShort = 'mi';
  static const unitMilesStorage = 'miles';

  static const androidNotificationIcon = '@mipmap/ic_launcher';

  static const firestoreUsersCollection = 'users';
  static const firestoreOilStateCollection = 'oilState';
  static const firestoreOilStateDoc = 'state';
}
