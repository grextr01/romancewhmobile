class BarcodeController {
  bool loading = false;
  String scannedBarcode = '';
  String errorMessage = '';
  bool error = false;
  List<Map<String, dynamic>> items = [];
  String leCode;

  BarcodeController({
    this.loading = false,
    this.scannedBarcode = '',
    this.errorMessage = '',
    this.error = false,
    this.items = const [],
    this.leCode = '',
  });

  BarcodeController copyWith({
    bool? loading,
    String? scannedBarcode,
    String? errorMessage,
    bool? error,
    List<Map<String, dynamic>>? items,
    String? leCode,
  }) {
    return BarcodeController(
      loading: loading ?? this.loading,
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      errorMessage: errorMessage ?? this.errorMessage,
      error: error ?? this.error,
      items: items ?? this.items,
      leCode: leCode ?? this.leCode,
    );
  }
}
