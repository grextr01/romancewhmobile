import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/barcode_bloc/barcode_cubit.dart';
import 'package:romancewhs/Controllers/barcode_controller.dart';
import 'package:romancewhs/UI/Home/Components/item_card.dart';
import 'package:romancewhs/UX/Theme.dart';
import 'package:vibration/vibration.dart';

class BarcodePage extends StatefulWidget {
  const BarcodePage({super.key, required this.leCode});
  final String leCode;

  @override
  State<BarcodePage> createState() => _BarcodePageState();
}

class _BarcodePageState extends State<BarcodePage> {
  late TextEditingController barcodeController;
  late FocusNode barcodeFocusNode;

  @override
  void initState() {
    super.initState();
    // FIX: Initialize controllers and focus nodes in initState
    barcodeController = TextEditingController();
    barcodeFocusNode = FocusNode();
    context.read<BarcodeCubit>().setLeCode(widget.leCode);
    
    // FIX: Add listener properly
    barcodeFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    // FIX: Dispose controllers and focus nodes to prevent memory leaks
    barcodeController.dispose();
    barcodeFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (barcodeFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 10), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                            style: const TextStyle(fontWeight: FontWeight.normal))
                      ])),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[400],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  TextField(
                    focusNode: barcodeFocusNode,
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 10), () {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      });
                    },
                    controller: barcodeController,
                    autofocus: true,
                    onChanged: (value) async {
                      bool scanned = await context
                          .read<BarcodeCubit>()
                          .scannBarcode(value);
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        barcodeController.clear();
                        barcodeFocusNode.requestFocus();
                      });
                      if (!scanned) {
                        await Vibration.vibrate(duration: 500);
                        return;
                      }
                      await Vibration.vibrate(duration: 100);
                    },
                    decoration: InputDecoration(
                      hintText: 'Barcode',
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  if (state.items.isNotEmpty)
                    Expanded(
                      child: ListView(
                        children: state.items
                            .map((detail) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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