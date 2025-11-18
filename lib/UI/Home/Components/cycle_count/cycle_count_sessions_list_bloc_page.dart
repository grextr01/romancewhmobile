import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/cycle_count/cycle_count_cubit.dart';
import 'package:romancewhs/UI/Home/Components/cycle_count/cycle_count_sessions_list_page.dart';

class CycleCountSessionsListBlocPage extends StatelessWidget {
  const CycleCountSessionsListBlocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CycleCountCubit>.value(
      value: context.read<CycleCountCubit>(),
      child: const CycleCountSessionsListPage(),
    );
  }
}