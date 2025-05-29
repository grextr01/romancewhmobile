class TransactionDetail {
  int lineId;
  int orgId;
  String orgCode;
  String itemCode;
  String description;
  int quantity;
  int freeQty;
  String barcode;
  int scannedQty = 0;

  TransactionDetail({
    required this.lineId,
    required this.orgId,
    required this.orgCode,
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.freeQty,
    required this.barcode,
  });

  factory TransactionDetail.fromJson(Map map) {
    return TransactionDetail(
        barcode: map['BARCODE'] ?? '',
        description: map['DESCRIPTION'],
        freeQty: map['FREE_QUANTITY'] ?? 0,
        itemCode: map['ITEM_CODE'],
        lineId: map['TRX_LINE_ID'],
        orgCode: map['ORGANIZATION_CODE'],
        orgId: map['ORGANIZATION_ID'],
        quantity: map['QUANTITY']);
  }
}
