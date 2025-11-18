class CycleCountHeader {
  final int? id;
  final String portfolio;
  final String timestamp;
  final String userId;
  final int totalItems;
  final int scannedItems;

  CycleCountHeader({
    this.id,
    required this.portfolio,
    required this.timestamp,
    required this.userId,
    this.totalItems = 0,
    this.scannedItems = 0,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'portfolio': portfolio,
      'timestamp': timestamp,
      'userId': userId,
      'totalItems': totalItems,
      'scannedItems': scannedItems,
    };
  }

  // Create from Map (database row)
  factory CycleCountHeader.fromMap(Map<String, dynamic> map) {
    return CycleCountHeader(
      id: map['id'] as int?,
      portfolio: map['portfolio'] as String,
      timestamp: map['timestamp'] as String,
      userId: map['userId'] as String,
      totalItems: map['totalItems'] as int? ?? 0,
      scannedItems: map['scannedItems'] as int? ?? 0,
    );
  }

  @override
  String toString() =>
      'CycleCountHeader(id: $id, portfolio: $portfolio, timestamp: $timestamp)';
}