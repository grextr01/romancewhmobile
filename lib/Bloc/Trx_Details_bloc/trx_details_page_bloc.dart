import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Trx_Details_bloc/trx_details_cubit.dart';
import 'package:romancewhs/Controllers/trx_details_controller.dart';
import 'package:romancewhs/UI/Transactions/details_page.dart';

class TrxDetailsBlocPage extends StatelessWidget {
  const TrxDetailsBlocPage(
      {super.key,
      required this.headerId,
      required this.trxHeader,
      required this.onSubmit});
  final int headerId;
  final Map trxHeader;
  final Function(String headerId) onSubmit;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrxDetailsCubit(
        TrxDetailsController(headerId: 0),
      ),
      child: DetailsPage(
        headerId: headerId,
        trxHeader: trxHeader,
        onSubmit: onSubmit,
      ),
    );
  }
}
