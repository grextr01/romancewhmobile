import 'package:flutter/material.dart';
import 'package:romancewhs/UX/Theme.dart';

class PortfolioSelectionDialog extends StatefulWidget {
  const PortfolioSelectionDialog({super.key});

  @override
  State<PortfolioSelectionDialog> createState() =>
      _PortfolioSelectionDialogState();
}

class _PortfolioSelectionDialogState extends State<PortfolioSelectionDialog> {
  late TextEditingController portfolioController;
  final FocusNode portfolioFocusNode = FocusNode();
  bool automaticQuantity = true;
  bool automaticMerge = false;

  @override
  void initState() {
    super.initState();
    portfolioController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 100), () {
      portfolioFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    portfolioController.dispose();
    portfolioFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Start Cycle Count',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: secondaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Location/Portfolio Name:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: portfolioController,
              focusNode: portfolioFocusNode,
              decoration: InputDecoration(
                hintText: 'e.g., Warehouse A, Shelf 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.of(context).pop({
                    'portfolioName': value.trim(),
                    'automaticQuantity': automaticQuantity,
                    'automaticMerge': automaticMerge,
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Scanning Modes
            const Text(
              'Scanning Modes:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            // Mode toggles in a row
            Row(
              children: [
                // Automatic Quantity Toggle
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: automaticQuantity
                          ? secondaryColor.withValues(alpha: 0.1)
                          : Colors.grey[100],
                      border: Border.all(
                        color: automaticQuantity
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
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: automaticQuantity,
                            onChanged: (value) {
                              setState(() {
                                automaticQuantity = value ?? true;
                              });
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                automaticQuantity ? 'On' : 'Off',
                                style: TextStyle(
                                  fontSize: 9,
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
                const SizedBox(width: 10),
                // Automatic Merge Toggle
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: automaticMerge
                          ? secondaryColor.withValues(alpha: 0.1)
                          : Colors.grey[100],
                      border: Border.all(
                        color: automaticMerge
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
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: automaticMerge,
                            onChanged: (value) {
                              setState(() {
                                automaticMerge = value ?? false;
                              });
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                automaticMerge ? 'On' : 'Off',
                                style: TextStyle(
                                  fontSize: 9,
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
            const SizedBox(height: 12),
            // Info text
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto Qty: Adds 1 item per scan',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Auto Merge: Merges same items & asks quantity',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondaryColor,
          ),
          onPressed: () {
            final portfolio = portfolioController.text.trim();
            if (portfolio.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a portfolio name'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            Navigator.of(context).pop({
              'portfolioName': portfolio,
              'automaticQuantity': automaticQuantity,
              'automaticMerge': automaticMerge,
            });
          },
          child: const Text(
            'Start',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}