import 'package:flutter_test/flutter_test.dart';
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

class FakeNotificationService extends NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> showReminderNotification({
    required String title,
    required String body,
    required int color,
  }) async {}
}

class FakeLocationService implements LocationServiceBase {
  FakeLocationService(this.location);

  final String? location;

  @override
  Future<String?> getLocationLabel() async => location;

  @override
  Future<LocationPoint?> getLocationPoint() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('adds an oil change history entry when marked changed', () async {
    final repository = FakeOilRepository({
      OilStorageKeys.currentMileage: 1200,
      OilStorageKeys.intervalKm: 500,
      OilStorageKeys.lastChangeMileage: 700,
    });
    final now = DateTime(2024, 6, 2, 11, 0);
    final viewModel = OilViewModel(
      FakeNotificationService(),
      repository,
      initialThemeMode: AppThemeMode.light,
      nowProvider: () => now,
      locationService: FakeLocationService('Austin, TX'),
    );

    await viewModel.load();
    await viewModel.markOilChanged();

    expect(viewModel.history, hasLength(1));
    expect(viewModel.history.first.mileage, 1200);
    expect(viewModel.history.first.date, now);
    expect(viewModel.history.first.location, 'Austin, TX');
  });

  test('history is sorted newest first when loading', () async {
    final repository = FakeOilRepository({
      OilStorageKeys.currentMileage: 1200,
      OilStorageKeys.intervalKm: 500,
      OilStorageKeys.lastChangeMileage: 700,
      OilStorageKeys.oilChangeHistory: [
        {
          'date': DateTime(2024, 5, 1, 9, 0).millisecondsSinceEpoch,
          'mileage': 1000,
        },
        {
          'date': DateTime(2024, 6, 1, 9, 0).millisecondsSinceEpoch,
          'mileage': 1200,
        },
      ],
    });
    final viewModel = OilViewModel(
      FakeNotificationService(),
      repository,
      initialThemeMode: AppThemeMode.light,
      nowProvider: () => DateTime(2024, 6, 2, 11, 0),
    );

    await viewModel.load();

    expect(viewModel.history.first.mileage, 1200);
    expect(viewModel.history.last.mileage, 1000);
  });
}
