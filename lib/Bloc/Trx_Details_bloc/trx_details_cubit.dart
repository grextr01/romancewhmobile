// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Controllers/trx_details_controller.dart';
import 'package:romancewhs/Models/transaction_detail.dart';
import 'package:romancewhs/UX/Api.dart';

import '../../main.dart';

class TrxDetailsCubit extends Cubit<TrxDetailsController> {
  TrxDetailsCubit(super.initialState);

  API api = API();

  void init(int headerId) {
    emit(state.copyWith(headerId: headerId));
  }

  void setBarcodeFocusNode(FocusNode focusNode) {
    emit(state.copyWith(barcodeFocusNode: focusNode));
  }

  Future<void> getTransactionDetails(int headerId) async {
    emit(state.copyWith(loading: true));
    List<TransactionDetail> transactionDetails = [];
    var response = await api.getApiToMap(
        api.apiBaseUrl, '/Warehouse/romance/details/$headerId', 'get');
    if (response['statusCode'] == 200) {
      List data = response['data'];
      transactionDetails =
          data.map((item) => TransactionDetail.fromJson(item)).toList();
      emit(state.copyWith(
          transactionDetails: transactionDetails,
          unfilteredDetails: transactionDetails,
          loading: false,
          error: false));
    } else {
      emit(state.copyWith(
          error: true,
          errorMessage: 'Error fetching transaction details',
          loading: false));
      showDialog(
        context: mainNavigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Error fetching transaction details.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
  }

  bool scanItemBarcode(String barcode, BuildContext context,
      FocusNode focusNode, int scannedQty) {
    //barcode = "3616305181053";
    TransactionDetail item = state.transactionDetails!.firstWhere(
      (element) => element.barcode == barcode,
      orElse: () => TransactionDetail(
        lineId: 0,
        orgId: 0,
        orgCode: '',
        itemCode: '',
        description: '',
        quantity: 0,
        freeQty: 0,
        barcode: '',
      ),
    );
    if (state.transactionDetails != null) {
      for (var element in state.transactionDetails!) {
        if (element.barcode == barcode) {
          item = element;
          break;
        }
      }
    }
    emit(state.copyWith(
      scannedBarcode: barcode,
      scannedItemCode: item.itemCode,
      scannedItemName: item.description,
    ));
    emit(state.copyWith(error: false, errorMessage: ''));
    if (item.scannedQty + scannedQty > item.quantity + item.freeQty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
              'The scanned quantity exceeds the available quantity.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                focusNode.requestFocus();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      focusNode.requestFocus();
      return false;
    }
    item.scannedQty += scannedQty;
    emit(state.copyWith(
        transactionDetails: state.transactionDetails,
        neededQty: item.quantity + item.freeQty,
        scannedQty: item.scannedQty,
        leftQty: item.quantity + item.freeQty - item.scannedQty));
    return true;
  }

  bool findItemWithBarcode(String barcode, BuildContext context) {
    TransactionDetail? item;
    //barcode = "3616305181053";
    emit(state.copyWith(
      scannedBarcode: barcode,
      scannedItemCode: '',
      scannedItemName: '',
    ));
    if (state.transactionDetails != null) {
      for (var element in state.transactionDetails!) {
        if (element.barcode == barcode) {
          item = element;
          break;
        }
      }
    }
    if (item == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('The scanned item is not found in the list.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
    emit(state.copyWith(
      scannedBarcode: barcode,
      scannedItemCode: item.itemCode,
      scannedItemName: item.description,
    ));
    if ((item.quantity + item.freeQty) == item.scannedQty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('The item is already scanned.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  void setShowAll(bool showAll) {
    emit(state.copyWith(showAll: showAll));
  }

  void filterTransactionDetails(List<TransactionDetail> details) {
    List<TransactionDetail> updatedList;

    if (state.showAll) {
      // Include all, sorted with mismatches first
      updatedList = [...details];
      updatedList.sort((a, b) {
        bool aMismatch = a.scannedQty != (a.quantity + a.freeQty);
        bool bMismatch = b.scannedQty != (b.quantity + b.freeQty);
        if (aMismatch && !bMismatch) return -1;
        if (!aMismatch && bMismatch) return 1;
        return 0;
      });
    } else {
      // Only include items with mismatches
      updatedList = details
          .where((item) => item.scannedQty != (item.quantity + item.freeQty))
          .toList();
    }

    emit(state.copyWith(transactionDetails: updatedList));
  }

  void setScannedQty(bool scannedQty) {
    emit(state.copyWith(setScannedQty: scannedQty));
  }

  void setLoading(bool loading) {
    emit(state.copyWith(loading: loading));
  }

  bool get isButtonEnabled {
    for (int i = 0; i < state.transactionDetails!.length; i++) {
      if (state.transactionDetails![i].barcode == '') {
        continue;
      }
      if (state.transactionDetails![i].scannedQty !=
          (state.transactionDetails![i].quantity +
              state.transactionDetails![i].freeQty)) {
        return false;
      }
    }
    return true;
  }

  Future<bool> submitTransaction(String headerId, BuildContext context) async {
    emit(state.copyWith(loading: true));
    var response = await api.getApiToMap(
        api.apiBaseUrl, '/Warehouse/romance/update-erp/$headerId', 'post');
    if (response['statusCode'] == 200) {
      emit(state.copyWith(loading: false));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Transaction submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                mainNavigatorKey.currentState?.pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return true;
    } else {
      emit(state.copyWith(
          error: true,
          errorMessage: 'Error submitting transaction',
          loading: false));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
              'Error submitting transaction. Kindly Contact your IT.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }
}
