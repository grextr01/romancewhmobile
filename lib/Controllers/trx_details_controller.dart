import 'package:flutter/material.dart';
import 'package:romancewhs/Models/transaction_detail.dart';

class TrxDetailsController {
  int headerId;
  List<TransactionDetail>? transactionDetails = [];
  List<TransactionDetail>? unfilteredDetails = [];
  bool error = false;
  bool loading = false;
  String errorMessage = '';
  String scannedBarcode = '';
  String scannedItemCode = '';
  String scannedItemName = '';
  int? scannedQty;
  bool showAll = false;
  bool setScannedQty = true;
  int? neededQty;
  int? leftQty;

  TextEditingController barcodeController = TextEditingController();
  TextEditingController scannedQtyController = TextEditingController();
  FocusNode? barcodeFocusNode = FocusNode();
  FocusNode scannedQtyFocusNode = FocusNode();

  TrxDetailsController(
      {required this.headerId,
      this.transactionDetails,
      this.unfilteredDetails,
      this.error = false,
      this.loading = false,
      this.errorMessage = '',
      this.scannedBarcode = '',
      this.scannedItemCode = '',
      this.scannedItemName = '',
      this.scannedQty,
      this.showAll = false,
      this.setScannedQty = true,
      this.neededQty,
      this.leftQty,
      this.barcodeFocusNode});

  TrxDetailsController copyWith({
    int? headerId,
    List<TransactionDetail>? transactionDetails,
    List<TransactionDetail>? unfilteredDetails,
    bool? error,
    bool? loading,
    String? errorMessage,
    String? scannedBarcode,
    String? scannedItemCode,
    String? scannedItemName,
    int? scannedQty,
    bool? showAll,
    bool? setScannedQty,
    int? neededQty,
    int? leftQty,
    FocusNode? barcodeFocusNode,
  }) {
    return TrxDetailsController(
      headerId: headerId ?? this.headerId,
      transactionDetails: transactionDetails ?? this.transactionDetails,
      unfilteredDetails: unfilteredDetails ?? this.unfilteredDetails,
      error: error ?? this.error,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      scannedBarcode: scannedBarcode ?? this.scannedBarcode,
      scannedItemCode: scannedItemCode ?? this.scannedItemCode,
      scannedItemName: scannedItemName ?? this.scannedItemName,
      scannedQty: scannedQty ?? this.scannedQty,
      showAll: showAll ?? this.showAll,
      setScannedQty: setScannedQty ?? this.setScannedQty,
      neededQty: neededQty ?? this.neededQty,
      leftQty: leftQty ?? this.leftQty,
      barcodeFocusNode: barcodeFocusNode ?? this.barcodeFocusNode,
    );
  }
}
