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
      content: Column(
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
                Navigator.of(context).pop(value.trim());
              }
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'This name will identify your cycle count session.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
            Navigator.of(context).pop(portfolio);
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