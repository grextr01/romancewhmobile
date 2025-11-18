import 'package:romancewhs/Models/cycle_count_detail.dart';

class CycleCountController {
  final int? headerId;
  final String portfolioName;
  final List<CycleCountDetail> scannedItems;
  final List<Map<String, dynamic>> pendingPortfolioItems;
  final bool loading;
  final bool error;
  final String errorMessage;
  final String scannedBarcode;
  final int scannedQty;
  final bool automaticQuantityMode;
  final Map<String, dynamic>? selectedItem;

  CycleCountController({
    this.headerId,
    this.portfolioName = '',
    this.scannedItems = const [],
    this.pendingPortfolioItems = const [],
    this.loading = false,
    this.error = false,
    this.errorMessage = '',
    this.scannedBarcode = '',
    this.scannedQty = 0,
    this.automaticQuantityMode = true,
    this.selectedItem,
  });

  CycleCountController copyWith({
    int? headerId,
    String? portfolioName,
    List<CycleCountDetail>? scannedItems,
    List<Map<String, dynamic>>? pendingPortfolioItems,
    bool? loading,
    bool? error,
    String? errorMessage,
    String? scannedBarcode,
    int? scannedQty,
    bool? automaticQuantityMode,
    Map<String, dynamic>? selectedItem,
  }) {
    return CycleCountController(
      headerId: headerId ?? this.headerId,
      portfolioName: portfolioName ?? this.portfolioName,
      scannedItems: scannedItems ?? this.scannedItems,
      pendingPortfolioItems: pendingPortfolioItems ?? this.pendingPortfolioItems,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      scannedQty: scannedQty ?? this.scannedQty,
      automaticQuantityMode: automaticQuantityMode ?? this.automaticQuantityMode,
      selectedItem: selectedItem ?? this.selectedItem,
    );
  }

  // Helper methods
  int get totalScannedItems => scannedItems.length;

  int get totalScannedQuantity =>
      scannedItems.fold(0, (sum, item) => sum + item.quantity);

  bool get hasErrors => error;

  Map<String, int> getUniqueBarcodes() {
    Map<String, int> barcodes = {};
    for (var item in scannedItems) {
      barcodes.update(item.barcode, (value) => value + 1,
          ifAbsent: () => 1);
    }
    return barcodes;
  }
}