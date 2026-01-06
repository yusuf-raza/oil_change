import 'package:flutter_test/flutter_test.dart';
import 'package:oil_change/constants/app_colors.dart';
import 'package:oil_change/constants/app_strings.dart';
import 'package:oil_change/models/enums.dart';
import 'package:oil_change/services/location_service.dart';
import 'package:oil_change/services/notification_service.dart';
import 'package:oil_change/services/oil_repository.dart';
import 'package:oil_change/services/oil_storage.dart';
import 'package:oil_change/viewmodels/oil_view_model.dart';

class FakeOilRepository implements OilRepositoryBase {
  FakeOilRepository(this.data);

  Map<String, dynamic>? data;
  Map<String, dynamic>? lastSaved;

  @override
  Future<Map<String, dynamic>?> fetchState() async => data;

  @override
  Future<void> saveState(Map<String, dynamic> data) async {
    lastSaved = data;
  }

  @override
  Future<void> clearState() async {
    data = null;
  }
}

class NotificationCall {
  NotificationCall(this.title, this.body, this.color);

  final String title;
  final String body;
  final int color;
}

class FakeNotificationService extends NotificationService {
  final List<NotificationCall> calls = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showReminderNotification({required String title, required String body, required int color}) async {
    calls.add(NotificationCall(title, body, color));
  }
}

class FakeLocationService implements LocationServiceBase {
  @override
  Future<String?> getLocationLabel() async => null;

  @override
  Future<LocationPoint?> getLocationPoint() async => null;
}

Future<OilViewModel> _buildViewModel({
  required Map<String, dynamic> data,
  required FakeNotificationService notifications,
  DateTime Function()? nowProvider,
}) async {
  final repository = FakeOilRepository(data);
  final viewModel = OilViewModel(
    notifications,
    repository,
    initialThemeMode: AppThemeMode.light,
    nowProvider: nowProvider,
    locationService: FakeLocationService(),
  );
  await viewModel.load();
  return viewModel;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fires soon notification at the selected threshold', () async {
    final notifications = FakeNotificationService();
    final viewModel = await _buildViewModel(
      notifications: notifications,
      data: {
        OilStorageKeys.currentMileage: 1400,
        OilStorageKeys.intervalKm: 500,
        OilStorageKeys.lastChangeMileage: 1000,
        OilStorageKeys.notificationLeadKm: 100,
        OilStorageKeys.notificationsEnabled: true,
      },
      nowProvider: () => DateTime(2024, 6, 1, 11, 0),
    );

    await viewModel.updateCurrentMileage(1410);

    expect(notifications.calls, hasLength(1));
    final call = notifications.calls.single;
    expect(call.title, AppStrings.notificationSoonTitle);
    expect(call.body, 'Remaining: 90 km.');
    expect(call.color, AppColors.warning);
  });

  test('fires due notification when remaining is zero or less', () async {
    final notifications = FakeNotificationService();
    final viewModel = await _buildViewModel(
      notifications: notifications,
      data: {
        OilStorageKeys.currentMileage: 1400,
        OilStorageKeys.intervalKm: 500,
        OilStorageKeys.lastChangeMileage: 1000,
        OilStorageKeys.notificationLeadKm: 100,
        OilStorageKeys.notificationsEnabled: true,
      },
      nowProvider: () => DateTime(2024, 6, 1, 11, 0),
    );

    await viewModel.updateCurrentMileage(1500);

    expect(notifications.calls, hasLength(1));
    final call = notifications.calls.single;
    expect(call.title, AppStrings.notificationDueTitle);
    expect(call.body, 'Remaining: 0 km.');
    expect(call.color, AppColors.danger);
  });

  test('does not notify when remaining is above the threshold', () async {
    final notifications = FakeNotificationService();
    final viewModel = await _buildViewModel(
      notifications: notifications,
      data: {
        OilStorageKeys.currentMileage: 1300,
        OilStorageKeys.intervalKm: 500,
        OilStorageKeys.lastChangeMileage: 1000,
        OilStorageKeys.notificationLeadKm: 100,
        OilStorageKeys.notificationsEnabled: true,
      },
      nowProvider: () => DateTime(2024, 6, 1, 11, 0),
    );

    await viewModel.updateCurrentMileage(1330);

    expect(notifications.calls, isEmpty);
  });

  test('does not notify when notifications are disabled', () async {
    final notifications = FakeNotificationService();
    final viewModel = await _buildViewModel(
      notifications: notifications,
      data: {
        OilStorageKeys.currentMileage: 1400,
        OilStorageKeys.intervalKm: 500,
        OilStorageKeys.lastChangeMileage: 1000,
        OilStorageKeys.notificationLeadKm: 100,
        OilStorageKeys.notificationsEnabled: false,
      },
      nowProvider: () => DateTime(2024, 6, 1, 11, 0),
    );

    await viewModel.updateCurrentMileage(1410);

    expect(notifications.calls, isEmpty);
  });

  test('does not repeat the same threshold notification on the same day', () async {
    final notifications = FakeNotificationService();
    final viewModel = await _buildViewModel(
      notifications: notifications,
      data: {
        OilStorageKeys.currentMileage: 1400,
        OilStorageKeys.intervalKm: 500,
        OilStorageKeys.lastChangeMileage: 1000,
        OilStorageKeys.notificationLeadKm: 100,
        OilStorageKeys.notificationsEnabled: true,
      },
      nowProvider: () => DateTime(2024, 6, 1, 11, 0),
    );

    await viewModel.updateCurrentMileage(1410);
    await viewModel.updateCurrentMileage(1420);

    expect(notifications.calls, hasLength(1));
  });

  test('does not notify outside of 11am', () async {
    final notifications = FakeNotificationService();
    final viewModel = await _buildViewModel(
      notifications: notifications,
      data: {
        OilStorageKeys.currentMileage: 1400,
        OilStorageKeys.intervalKm: 500,
        OilStorageKeys.lastChangeMileage: 1000,
        OilStorageKeys.notificationLeadKm: 100,
        OilStorageKeys.notificationsEnabled: true,
      },
      nowProvider: () => DateTime(2024, 6, 1, 10, 0),
    );

    await viewModel.updateCurrentMileage(1410);

    expect(notifications.calls, isEmpty);
  });
}
