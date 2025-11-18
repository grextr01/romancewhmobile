import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:romancewhs/Bloc/cycle_count/cycle_count_cubit.dart';
import 'package:romancewhs/Models/cycle_count_header.dart';
import 'package:romancewhs/UI/Components.dart/cycle_count/cycle_count_scanning_page.dart';
import 'package:romancewhs/UX/Theme.dart';
import 'package:romancewhs/Controllers/cycle_count_controller.dart';

class CycleCountSessionsListPage extends StatefulWidget {
  const CycleCountSessionsListPage({super.key});

  @override
  State<CycleCountSessionsListPage> createState() =>
      _CycleCountSessionsListPageState();
}

class _CycleCountSessionsListPageState
    extends State<CycleCountSessionsListPage> {
  @override
  void initState() {
    super.initState();
    // Load all existing cycle count sessions when page initializes
    Future.microtask(() {
      context.read<CycleCountCubit>().loadAllSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: secondaryColor,
        shadowColor: const Color.fromRGBO(206, 206, 206, 100),
        title: const Text(
          'Continue Cycle Count',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<CycleCountCubit, CycleCountController>(
        builder: (context, state) {
          // Loading state
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }

          // Error state
          if (state.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CycleCountCubit>().loadAllSessions();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // No sessions
          if (state.existingSessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Cycle Count Sessions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'You haven\'t started any cycle counts yet. Go back to the menu to start a new one.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          // List of sessions
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: state.existingSessions.length,
            itemBuilder: (context, index) {
              final session = state.existingSessions[index];
              return _buildSessionCard(context, session);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(
      BuildContext context, CycleCountHeader session) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    final sessionDate = DateTime.parse(session.timestamp);
    final formattedDate = dateFormat.format(sessionDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _resumeSession(context, session),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with portfolio name and scanned count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.portfolio,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                       
                      ],
                    ),
                  ),
                  // Scanned items badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: secondaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${session.scannedItems}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: secondaryColor,
                          ),
                        ),
                        Text(
                          'Items',
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
              const SizedBox(height: 12),
              // Divider
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 12),
              // Details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date and time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Started',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                
                  // Resume button
                  ElevatedButton.icon(
                    onPressed: () => _resumeSession(context, session),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Resume'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resumeSession(
      BuildContext context, CycleCountHeader session) async {
    if (session.id == null) return;

    // Load the session
    final cubit = context.read<CycleCountCubit>();
    final success = await cubit.loadSession(session.id!);

    if (!success) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading session: ${cubit.state.errorMessage}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!context.mounted) return;

    // Navigate to the scanning page with the loaded session
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider<CycleCountCubit>.value(
          value: cubit,
          child: CycleCountScanningPage(
            headerId: session.id!,
            portfolioName: session.portfolio,
          ),
        ),
      ),
    );
  }
}