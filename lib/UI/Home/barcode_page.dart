import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/barcode_bloc/barcode_cubit.dart';
import 'package:romancewhs/Controllers/barcode_controller.dart';
import 'package:romancewhs/UI/Home/Components/item_card.dart';
import 'package:romancewhs/UX/Theme.dart';
import 'package:vibration/vibration.dart';

class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key, required this.leCode});
  final String leCode;
  @override
  Widget build(BuildContext context) {
    TextEditingController barcodeController = TextEditingController();
    FocusNode barcodeFocusNode = FocusNode();
    context.read<BarcodeCubit>().setLeCode(leCode);
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
            'Items Checker',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<BarcodeCubit, BarcodeController>(
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(TextSpan(
                      text: 'Barcode: ',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                            text: state.scannedBarcode,
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ])),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[400],
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  TextField(
                    focusNode: barcodeFocusNode,
                    onTap: () {
                      Future.delayed(Duration(milliseconds: 10), () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      });
                    },
                    controller: barcodeController,
                    autofocus: true,
                    onChanged: (value) async {
                      bool scanned = await context
                          .read<BarcodeCubit>()
                          .scannBarcode(value);
                      Future.delayed(Duration(milliseconds: 1000), () {
                        barcodeController.clear();
                        barcodeFocusNode.requestFocus();
                      });
                      // context.read()<TrxDetailsCubit>().scanItemBarcode(value);
                      if (!scanned) {
                        Vibration.vibrate(duration: 500);
                        return;
                      }
                      Vibration.vibrate(duration: 100);
                    },
                    decoration: InputDecoration(
                      hintText: 'Barcode',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  // Container(
                  //   decoration: BoxDecoration(
                  //       border: Border.all(color: Colors.grey[400]!),
                  //       borderRadius: BorderRadius.circular(5)),
                  //   padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         'Result',
                  //         style: TextStyle(
                  //             fontSize: 18, fontWeight: FontWeight.w600),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   height: 1,
                  //   width: double.infinity,
                  //   color: Colors.grey[400],
                  // ),
                  if (state.items.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: state.items
                            .map((detail) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: ItemCard(item: detail),
                                ))
                            .toList(),
                      ),
                    ),
                  if (state.items.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'No Items Found',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                ],
              ),
            );
          },
        ));
  }
}
