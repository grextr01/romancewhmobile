import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/cycle_count/cycle_count_cubit.dart';
import 'package:romancewhs/UI/Components.dart/cycle_count/cycle_count_scanning_page.dart';
import 'package:romancewhs/UI/Components.dart/cycle_count/portfolio_selection_dialog.dart';

class CycleCountBlocPage extends StatelessWidget {
  const CycleCountBlocPage({
    super.key,
    required this.cycleType,
  });

  final String cycleType;

  @override
  Widget build(BuildContext context) {
    // Show dialog after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPortfolioDialog(context);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Initializing Cycle Count...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _showPortfolioDialog(BuildContext context) async {
    try {
      final portfolioName = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const PortfolioSelectionDialog(),
      );

      if (portfolioName == null || !context.mounted) {
        Navigator.of(context).pop();
        return;
      }

      // Get cubit from main.dart
      final cubit = context.read<CycleCountCubit>();

      // Initialize session
      final headerId = await cubit.initializeSession(portfolioName);

      if (headerId <= 0 || !context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error initializing cycle count'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      if (!context.mounted) return;

      // Navigate with provider
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider<CycleCountCubit>.value(
            value: cubit,
            child: CycleCountScanningPage(
              headerId: headerId,
              portfolioName: portfolioName,
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}