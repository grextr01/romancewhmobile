import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Transactions_home_bloc/home_cubit.dart';
import 'package:romancewhs/Models/legal_entity.dart';
import 'package:romancewhs/UI/Home/transactions_home_page.dart';

import '../../Controllers/transactions_home_controller.dart';

class TransactionsHomePageBloc extends StatelessWidget {
  const TransactionsHomePageBloc({super.key, required this.legalEntities});
  final List<LegalEntity> legalEntities;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionsHomeCubit(
        TransactionsHomeController(selectedEntity: '', selectedType: ''),
      ),
      child: TransactionsHomePage(
        legalEntities: legalEntities,
      ),
    );
  }
}
