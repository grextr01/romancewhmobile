import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/barcode_bloc/barcode_cubit.dart';
import 'package:romancewhs/Controllers/barcode_controller.dart';
import 'package:romancewhs/UI/Home/barcode_page.dart';

class BarcodeBlocPage extends StatelessWidget {
  const BarcodeBlocPage({super.key, required this.leCode});
  final String leCode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BarcodeCubit(BarcodeController()),
      child: BarcodePage(
        leCode: leCode,
      ),
    );
  }
}
