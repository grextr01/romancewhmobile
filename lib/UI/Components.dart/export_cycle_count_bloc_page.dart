import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/cycle_count/cycle_count_cubit.dart';
import 'package:romancewhs/UI/Components.dart/export_cycle_count_page.dart';

class ExportCycleCountBlocPage extends StatelessWidget {
  const ExportCycleCountBlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CycleCountCubit>.value(
      value: context.read<CycleCountCubit>(),
      child: const ExportCycleCountPage(),
    );
  }
}