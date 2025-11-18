class CycleCountDetail {
  final int? detailId;
  final int headerId;
  final String barcode;
  final String itemCode;
  final String description;
  int quantity;
  final String? notes;
  final String? picture;
  final String timestamp;
  final bool isAutomatic;

  CycleCountDetail({
    this.detailId,
    required this.headerId,
    required this.barcode,
    required this.itemCode,
    required this.description,
    this.quantity = 0,
    this.notes,
    this.picture,
    required this.timestamp,
    required this.isAutomatic,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'detailId': detailId,
      'headerId': headerId,
      'barcode': barcode,
      'itemCode': itemCode,
      'description': description,
      'quantity': quantity,
      'notes': notes,
      'picture': picture,
      'timestamp': timestamp,
      'isAutomatic': isAutomatic ? 1 : 0,
    };
  }

  // Create from Map (database row)
  factory CycleCountDetail.fromMap(Map<String, dynamic> map) {
    return CycleCountDetail(
      detailId: map['detailId'] as int?,
      headerId: map['headerId'] as int,
      barcode: map['barcode'] as String,
      itemCode: map['itemCode'] as String,
      description: map['description'] as String,
      quantity: map['quantity'] as int? ?? 0,
      notes: map['notes'] as String?,
      picture: map['picture'] as String?,
      timestamp: map['timestamp'] as String,
      isAutomatic: (map['isAutomatic'] as int?) == 1,
    );
  }

  @override
  String toString() =>
      'CycleCountDetail(detailId: $detailId, barcode: $barcode, quantity: $quantity)';
}