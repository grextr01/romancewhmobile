import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Trx_Details_bloc/trx_details_cubit.dart';
import 'package:romancewhs/Controllers/trx_details_controller.dart';
import 'package:romancewhs/UI/Components.dart/custom_button.dart';
import 'package:romancewhs/UI/Transactions/Components/details_header_title.dart';
import 'package:romancewhs/UX/Theme.dart';
import 'package:vibration/vibration.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage(
      {super.key,
      required this.headerId,
      required this.trxHeader,
      required this.onSubmit});
  final int headerId;
  final Map trxHeader;
  final Function(String headerId) onSubmit;

  @override
  Widget build(BuildContext context) {
    // context.read<TrxDetailsCubit>().updateHeaderId(headerId);
    context.read<TrxDetailsCubit>().getTransactionDetails(headerId);
    context.read<TrxDetailsCubit>().init(headerId);
    TextEditingController barcodeController = TextEditingController();
    TextEditingController scannedQtyController = TextEditingController();
    FocusNode barcodeFocusNode = NoKeyboardFocusNode();
    FocusNode scannedQtyFocusNode = FocusNode();
    barcodeFocusNode.addListener(() {
      if (barcodeFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 10), () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });
      }
    });
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: secondaryColor,
          shadowColor: const Color.fromRGBO(206, 206, 206, 100),
          title: const Text(
            'Transaction Details',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<TrxDetailsCubit, TrxDetailsController>(
          builder: (context, state) {
            if (state.loading) {
              return Center(
                child: CircularProgressIndicator(
                  color: secondaryColor,
                ),
              );
            }
            if (state.error) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
            if (state.transactionDetails == null) {
              return Center(
                child: Text(
                  'No transaction details found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailsHeaderTitle(
                      title: 'Cons Billing Nb: ',
                      text: trxHeader['CONS_BILLING_NUMBER'].toString()),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  DetailsHeaderTitle(
                      title: 'Barcode: ', text: state.scannedBarcode),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  DetailsHeaderTitle(
                      title: 'Item Code: ', text: state.scannedItemCode),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  DetailsHeaderTitle(
                      title: 'Item Desc: ', text: state.scannedItemName),
                  Row(
                    children: [
                      Text('All'),
                      Checkbox(
                          value: state.showAll,
                          onChanged: (value) {
                            context
                                .read<TrxDetailsCubit>()
                                .setShowAll(value ?? false);
                            context
                                .read<TrxDetailsCubit>()
                                .filterTransactionDetails(
                                    state.unfilteredDetails!);
                          }),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      Text('Qty'),
                      Checkbox(
                          value: state.setScannedQty,
                          onChanged: (value) {
                            context
                                .read<TrxDetailsCubit>()
                                .setScannedQty(value ?? false);
                          }),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      Container(
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(state.leftQty == null
                              ? ''
                              : state.leftQty.toString())),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Container(
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(state.neededQty == null
                              ? ''
                              : state.neededQty.toString())),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Container(
                          alignment: Alignment.center,
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(state.scannedQty == null
                              ? ''
                              : state.scannedQty.toString())),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      SizedBox(
                        width: 50,
                        height: 30,
                        child: TextField(
                          controller: scannedQtyController,
                          focusNode: scannedQtyFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onTap: () {
                            barcodeFocusNode.requestFocus();
                          },
                          onSubmitted: (value) {
                            bool scanned = context
                                .read<TrxDetailsCubit>()
                                .scanItemBarcode(state.scannedBarcode, context,
                                    barcodeFocusNode, int.parse(value));
                            barcodeController.clear();
                            Future.delayed(Duration(milliseconds: 1000), () {
                              barcodeFocusNode.requestFocus();
                            });
                            // context.read()<TrxDetailsCubit>().scanItemBarcode(value);
                            if (!scanned) {
                              Vibration.vibrate(duration: 500);
                              return;
                            }
                            Vibration.vibrate(duration: 100);
                            context
                                .read<TrxDetailsCubit>()
                                .filterTransactionDetails(
                                    state.unfilteredDetails!);
                            barcodeFocusNode.requestFocus();
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[400],
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  TextField(
                    focusNode: barcodeFocusNode,
                    controller: barcodeController,
                    autofocus: true,
                    onChanged: (value) async {
                      Vibration.vibrate(duration: 100);
                      bool found = context
                          .read<TrxDetailsCubit>()
                          .findItemWithBarcode(value, context);
                      if (!found) {
                        Vibration.vibrate(duration: 500);
                        barcodeController.clear();
                        barcodeFocusNode.requestFocus();
                        return;
                      }
                      if (state.setScannedQty) {
                        scannedQtyController.text = '';
                        scannedQtyFocusNode.requestFocus();
                        return;
                      }
                      bool scanned = context
                          .read<TrxDetailsCubit>()
                          .scanItemBarcode(value, context, barcodeFocusNode, 1);
                      barcodeController.clear();
                      barcodeFocusNode.requestFocus();
                      // context.read()<TrxDetailsCubit>().scanItemBarcode(value);
                      if (!scanned) {
                        Vibration.vibrate(duration: 500);
                        return;
                      }
                      context
                          .read<TrxDetailsCubit>()
                          .filterTransactionDetails(state.unfilteredDetails!);
                      Vibration.vibrate(duration: 100);
                    },
                    onTap: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                    },
                    decoration: InputDecoration(
                      hintText: 'Barcode',
                      // border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.only(top: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Container(
                              padding: EdgeInsets.only(left: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: Text(
                                      'Description',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(width: 50, child: Text('Left')),
                                  SizedBox(width: 50, child: Text('Qty')),
                                  SizedBox(width: 60, child: Text('Scanned')),
                                  Padding(padding: EdgeInsets.only(left: 30)),
                                  SizedBox(width: 60, child: Text('Code')),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              height: 1,
                              width: 425,
                              color: Colors.grey[400],
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Container(
                                  padding: EdgeInsets.only(left: 0),
                                  child: Column(
                                    children: state.transactionDetails!
                                        .map((detail) => GestureDetector(
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    top: 10,
                                                    left: 8,
                                                    bottom: 10),
                                                decoration: BoxDecoration(
                                                    color: detail.barcode == ''
                                                        ? Colors.red[100]
                                                        : detail.scannedQty ==
                                                                (detail.freeQty +
                                                                    detail
                                                                        .quantity)
                                                            ? Colors.green[100]
                                                            : Colors
                                                                .transparent,
                                                    border: Border(
                                                        bottom: BorderSide(
                                                            color: Colors
                                                                .grey[400]!,
                                                            width: 1))),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                        width: 158,
                                                        child: Text(
                                                          detail.description
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 13),
                                                        )),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 6)),
                                                    SizedBox(
                                                      width: 50,
                                                      child: Text((detail
                                                                  .quantity +
                                                              detail.freeQty -
                                                              detail.scannedQty)
                                                          .toString()),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10)),
                                                    SizedBox(
                                                      width: 50,
                                                      child: Text((detail
                                                                  .quantity +
                                                              detail.freeQty)
                                                          .toString()),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10)),
                                                    SizedBox(
                                                      width: 60,
                                                      child: Text(detail
                                                          .scannedQty
                                                          .toString()),
                                                    ),
                                                    SizedBox(
                                                      width: 60,
                                                      child: Text(detail
                                                          .itemCode
                                                          .toString()),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10)),
                                                  ],
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: CustomMainButton(
                        text: 'Submit',
                        backgroundColor: secondaryColor,
                        height: 53,
                        textColor: Colors.white,
                        loading: state.loading,
                        enabled:
                            context.read<TrxDetailsCubit>().isButtonEnabled,
                        onPressed: () async {
                          bool submitted = await context
                              .read<TrxDetailsCubit>()
                              .submitTransaction(headerId.toString(), context);
                          if (!submitted) {
                            Vibration.vibrate(duration: 500);
                            return;
                          }
                          //mainNavigatorKey.currentState?.pop();
                          onSubmit(headerId.toString());
                        }),
                  )
                ],
              ),
            );
          },
        ));
  }
}

class NoKeyboardFocusNode extends FocusNode {
  // @override
  // bool consumeKeyboardToken() {
  //   return false;
  // }
}
