class TourExpense {
  const TourExpense({
    required this.title,
    required this.amountPkr,
    required this.createdAt,
    this.category,
    this.subcategory,
    this.notes,
  });

  final String title;
  final double amountPkr;
  final DateTime createdAt;
  final String? category;
  final String? subcategory;
  final String? notes;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount_pkr': amountPkr,
      'created_at': createdAt.millisecondsSinceEpoch,
      if (category != null) 'category': category,
      if (subcategory != null) 'subcategory': subcategory,
      if (notes != null) 'notes': notes,
    };
  }

  static TourExpense? fromMap(Map<String, dynamic> data) {
    final title = data['title'];
    final amount = data['amount_pkr'];
    final createdAt = data['created_at'];
    final category = data['category'];
    final subcategory = data['subcategory'];
    final notes = data['notes'];
    if (title is! String || title.trim().isEmpty || amount is! num) {
      return null;
    }
    return TourExpense(
      title: title.trim(),
      amountPkr: amount.toDouble(),
      createdAt: createdAt is int
          ? DateTime.fromMillisecondsSinceEpoch(createdAt)
          : DateTime.now(),
      category: category is String && category.trim().isNotEmpty
          ? category.trim()
          : null,
      subcategory: subcategory is String && subcategory.trim().isNotEmpty
          ? subcategory.trim()
          : null,
      notes: notes is String && notes.trim().isNotEmpty ? notes.trim() : null,
    );
  }
}
