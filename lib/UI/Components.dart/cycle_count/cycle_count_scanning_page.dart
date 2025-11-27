import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/cycle_count/cycle_count_cubit.dart';
import 'package:romancewhs/Controllers/cycle_count_controller.dart';
import 'package:romancewhs/UX/Theme.dart';
import 'package:vibration/vibration.dart';

class CycleCountScanningPage extends StatefulWidget {
  const CycleCountScanningPage({
    super.key,
    required this.headerId,
    required this.portfolioName,
  });

  final int headerId;
  final String portfolioName;

  @override
  State<CycleCountScanningPage> createState() =>
      _CycleCountScanningPageState();
}

class _CycleCountScanningPageState extends State<CycleCountScanningPage> {
  late TextEditingController barcodeController;
  late TextEditingController quantityController;
  late TextEditingController descriptionController;
  late TextEditingController noteController;
  late FocusNode barcodeFocusNode;
  late FocusNode quantityFocusNode;
  late CycleCountCubit cubit;
  late ScrollController listScrollController;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();

    cubit = context.read<CycleCountCubit>();

    barcodeController = TextEditingController();
    quantityController = TextEditingController();
    descriptionController = TextEditingController();
    noteController = TextEditingController();
    barcodeFocusNode = FocusNode();
    quantityFocusNode = FocusNode();
    listScrollController = ScrollController();

    barcodeController.addListener(_onBarcodeChanged);
    cubit.loadPortfolioItems();

    Future.delayed(const Duration(milliseconds: 100), () {
      barcodeFocusNode.requestFocus();
      _hideKeyboard();
    });

    barcodeFocusNode.addListener(_handleBarcodeNodeFocus);
  }

  @override
  void dispose() {
    barcodeController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    noteController.dispose();
    barcodeFocusNode.dispose();
    quantityFocusNode.dispose();
    listScrollController.dispose();
    super.dispose();
  }

  void _handleBarcodeNodeFocus() {
    if (barcodeFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 10), () {
        _hideKeyboard();
      });
    }
  }

  void _hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  bool _isKeyboardVisible() {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  void _onBarcodeChanged() {
    if (!_keyboardVisible && barcodeController.text.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (barcodeController.text.isNotEmpty && !_isKeyboardVisible()) {
          _handleBarcodeScanned(barcodeController.text.trim());
          barcodeController.clear();
        }
      });
    }
  }

  void _scrollToNewestItem() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (listScrollController.hasClients) {
        listScrollController.animateTo(
          listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _handleBarcodeScanned(String barcode) async {
    if (barcode.isEmpty) return;

    final results = await cubit.findItemByBarcode(barcode);
    final exactMatches = results.where((item) => item['barcode'] == barcode).toList();

    if (exactMatches.isEmpty) {
      _showManualDescriptionDialog(barcode);
      return;
    }

    if (exactMatches.length == 1) {
      final state = cubit.state;
      if (state.automaticQuantityMode) {
        bool success = await cubit.scanBarcode(
          barcode,
          isAutomatic: 'A',
        );

        if (success) {
          await Vibration.vibrate(duration: 100);
          barcodeController.clear();
          _scrollToNewestItem();
          barcodeFocusNode.requestFocus();
        }
      } else {
        _showQuantityPopup(barcode, exactMatches[0]);
      }
    } else {
      _showMultipleMatchDialog(barcode, exactMatches);
    }
  }

  void _showQuantityPopup(String barcode, Map<String, dynamic> item) {
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barcode: $barcode'),
            const SizedBox(height: 12),
            Text('Item: ${item['itemCode']}'),
            const SizedBox(height: 8),
            Text(item['description']),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              barcodeController.clear();
              barcodeFocusNode.requestFocus();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: () async {
              final qty = int.tryParse(qtyController.text) ?? 1;
              Navigator.pop(dialogContext);

              bool success = await cubit.scanBarcode(
                barcode,
                quantity: qty,
                isAutomatic: 'Q',
              );

              if (success) {
                await Vibration.vibrate(duration: 100);
                barcodeController.clear();
                quantityController.clear();
                _scrollToNewestItem();
                barcodeFocusNode.requestFocus();
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualDescriptionDialog(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Item Not Found'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Barcode: $barcode'),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Item description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Visibility(
                visible: !cubit.isQuantityAutomatic(),
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              barcodeController.clear();
              barcodeFocusNode.requestFocus();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: () async {
              final description = descriptionController.text.trim();
              final qty = int.tryParse(quantityController.text) ?? 1;

              if (description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a description')),
                );
                return;
              }

              Navigator.pop(dialogContext);

              bool success = await cubit.scanBarcode(
                barcode,
                manualDescription: description,
                quantity: qty,
                isAutomatic: cubit.isQuantityAutomatic() ? 'D' : 'QD',
              );

              if (success) {
                barcodeController.clear();
                descriptionController.clear();
                quantityController.clear();
                _scrollToNewestItem();
                barcodeFocusNode.requestFocus();
              }
            },
            child: const Text(
              'Add Item',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultipleMatchDialog(
      String barcode, List<Map<String, dynamic>> matches) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barcode: $barcode'),
            const SizedBox(height: 12),
            Text('Found ${matches.length} items with this barcode:'),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    matches.length,
                        (index) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            final state = cubit.state;
                            if (state.automaticQuantityMode) {
                              cubit.scanBarcode(barcode, isAutomatic: 'A');
                              barcodeController.clear();
                              _scrollToNewestItem();
                              barcodeFocusNode.requestFocus();
                            } else {
                              _showQuantityPopup(barcode, matches[index]);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Item ${index + 1}: ${matches[index]['itemCode']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  matches[index]['description'],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              barcodeController.clear();
              barcodeFocusNode.requestFocus();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CycleCountCubit, CycleCountController>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            backgroundColor: secondaryColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cycle Count - Scanning',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Location: ${widget.portfolioName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Mode Toggles - Side by Side
                Row(
                  children: [
                    // Automatic Quantity Toggle
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: state.automaticQuantityMode
                              ? secondaryColor.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          border: Border.all(
                            color: state.automaticQuantityMode
                                ? secondaryColor
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: state.automaticQuantityMode,
                                onChanged: (value) {
                                  cubit.toggleAutomaticQuantity(value ?? true);
                                },
                                activeColor: secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Auto Qty',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    state.automaticQuantityMode ? 'On' : 'Off',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Automatic Merge Toggle
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: state.automaticMergeMode
                              ? secondaryColor.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          border: Border.all(
                            color: state.automaticMergeMode
                                ? secondaryColor
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: state.automaticMergeMode,
                                onChanged: (value) {
                                  cubit.toggleAutomaticMerge(value ?? false);
                                },
                                activeColor: secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Auto Merge',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    state.automaticMergeMode ? 'On' : 'Off',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Barcode Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: barcodeFocusNode,
                        controller: barcodeController,
                        autofocus: true,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            _handleBarcodeScanned(value.trim());
                            barcodeController.clear();
                            barcodeFocusNode.requestFocus();
                            _hideKeyboard();
                          }
                        },
                        onTap: () {
                          _hideKeyboard();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _keyboardVisible = _isKeyboardVisible();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Scan barcode or type and press Enter...',
                          prefixIcon: const Icon(Icons.barcode_reader),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Error message
                if (state.error)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            cubit.clearError();
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Stats Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: secondaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Items Scanned',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.scannedItems.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: secondaryColor.withValues(alpha: 0.3),
                      ),
                      Column(
                        children: [
                          const Text(
                            'Total Qty',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.scannedItems.fold<int>(0, (sum, item) => sum + item.quantity)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Scanned Items List
                Expanded(
                  child: state.scannedItems.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No items scanned yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Scan an item to get started',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    reverse: true,
                    controller: listScrollController,
                    itemCount: state.scannedItems.length,
                    itemBuilder: (context, index) {
                      final item = state.scannedItems[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: index == 0 ? 4 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: index == 0
                              ? const BorderSide(
                            color: secondaryColor,
                            width: 2,
                          )
                              : BorderSide.none,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Barcode row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.grid_3x3,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Barcode: ${item.barcode ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Item code and quantity row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemCode,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Qty: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: secondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditQuantityDialog(item);
                                      } else if (value == 'delete') {
                                        cubit.removeItem(item.detailId!);
                                      } else if (value == 'note') {
                                        _showAddNoteDialog(item);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 16),
                                            SizedBox(width: 8),
                                            Text('Edit Qty'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 16, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'note',
                                        child: Row(
                                          children: [
                                            Icon(Icons.note, size: 16),
                                            SizedBox(width: 8),
                                            Text('Add Note'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Description row
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.description_outlined,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    if (item.isAutomatic != 'A')
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[100],
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Manual',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Note section
                              if (item.notes != null && item.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.sticky_note_2_outlined,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item.notes!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: state.scannedItems.isEmpty
                        ? null
                        : () async {
                      bool success = await cubit.submitSession();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Cycle count submitted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditQuantityDialog(dynamic item) {
    final qtyController = TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item: ${item.itemCode}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: () {
              final newQty = int.tryParse(qtyController.text) ?? 0;
              cubit.updateItemQuantity(item.detailId!, newQty);
              Navigator.pop(dialogContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(dynamic item) {
    final noteController = TextEditingController(text: item.notes ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Item: ${item.itemCode}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter note...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
            ),
            onPressed: () {
              final note = noteController.text.trim();
              cubit.addNoteToItem(item.detailId!, note);
              Navigator.pop(dialogContext);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }
}