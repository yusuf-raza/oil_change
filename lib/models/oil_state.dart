class OilState {
  final int? currentMileage;
  final int? intervalKm;
  final int? lastChangeMileage;

  const OilState({
    this.currentMileage,
    this.intervalKm,
    this.lastChangeMileage,
  });

  OilState copyWith({
    int? currentMileage,
    int? intervalKm,
    int? lastChangeMileage,
  }) {
    return OilState(
      currentMileage: currentMileage ?? this.currentMileage,
      intervalKm: intervalKm ?? this.intervalKm,
      lastChangeMileage: lastChangeMileage ?? this.lastChangeMileage,
    );
  }
}
