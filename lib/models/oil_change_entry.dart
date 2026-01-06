class OilChangeEntry {
  const OilChangeEntry({
    required this.date,
    required this.mileage,
    this.location,
  });

  final DateTime date;
  final int mileage;
  final String? location;

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'mileage': mileage,
      if (location != null) 'location': location,
    };
  }

  static OilChangeEntry? fromMap(Map<String, dynamic> data) {
    final dateValue = data['date'];
    final mileageValue = data['mileage'];
    final locationValue = data['location'];
    if (dateValue is! int || mileageValue is! int) {
      return null;
    }
    return OilChangeEntry(
      date: DateTime.fromMillisecondsSinceEpoch(dateValue),
      mileage: mileageValue,
      location: locationValue is String && locationValue.isNotEmpty
          ? locationValue
          : null,
    );
  }
}
