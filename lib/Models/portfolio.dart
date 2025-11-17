class Portfolio {
  final int? id;
  final String barcode;
  final String itemCode;
  final String description;
  final DateTime? createdAt;

  Portfolio({
    this.id,
    required this.barcode,
    required this.itemCode,
    required this.description,
    this.createdAt,
  });

  // Convert Portfolio to JSON for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'itemCode': itemCode,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create Portfolio from database row
  factory Portfolio.fromMap(Map<String, dynamic> map) {
    return Portfolio(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      itemCode: map['itemCode'] as String,
      description: map['description'] as String,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String) 
          : null,
    );
  }

  @override
  String toString() => 'Portfolio(barcode: $barcode, itemCode: $itemCode, description: $description)';
}