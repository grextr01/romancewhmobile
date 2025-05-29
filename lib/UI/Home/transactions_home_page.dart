// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:romancewhs/Bloc/Transactions_home_bloc/home_cubit.dart';
import 'package:romancewhs/Controllers/transactions_home_controller.dart';
import 'package:romancewhs/Models/legal_entity.dart';
import 'package:romancewhs/UI/Components.dart/custom_button.dart';
import 'package:romancewhs/UI/Home/Components/bottom_sheet_selector.dart';
import 'package:romancewhs/UI/Home/Components/field_container.dart';
import 'package:romancewhs/UI/Home/barcode_page.dart';
import 'package:romancewhs/UI/Transactions/transactions_page.dart';
import 'package:romancewhs/main.dart';
import '../../UX/Theme.dart';

class TransactionsHomePage extends StatelessWidget {
  const TransactionsHomePage({
    super.key,
    required this.legalEntities,
  });
  final List<LegalEntity> legalEntities;
  @override
  Widget build(BuildContext context) {
    final TextEditingController leController = TextEditingController();
    final TextEditingController transactionTypeController =
        TextEditingController();
    final TextEditingController fromDateController = TextEditingController();
    final TextEditingController toDateController = TextEditingController();
    context.read<TransactionsHomeCubit>().getTransactionsTypes();
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    fromDateController.text = currentDate;
    toDateController.text = currentDate;
    leController.text = legalEntities[0].leName;
    context
        .read<TransactionsHomeCubit>()
        .setSelectedEntity(legalEntities[0].leCode);
    context.read<TransactionsHomeCubit>().setFromDate(currentDate);
    context.read<TransactionsHomeCubit>().setToDate(currentDate);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: secondaryColor,
        shadowColor: const Color.fromRGBO(206, 206, 206, 100),
        title: const Text(
          'Home',
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionsHomeCubit, TransactionsHomeController>(
          builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              FieldContainer(
                  title: 'Select LE: ',
                  child: TextField(
                    controller: leController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Enter LE Code',
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) => BottomSheetSelector(
                              title: 'Select Legal Entity',
                              items: legalEntities
                                  .map((item) => {
                                        'Name': item.leName,
                                        'Value': item.leCode
                                      })
                                  .toList(),
                              onTap: (name, value) {
                                leController.text = name;
                                context
                                    .read<TransactionsHomeCubit>()
                                    .setSelectedEntity(value);
                                // leController.text = state.selectedEntity!;
                                Navigator.pop(context);
                              }));
                    },
                    onChanged: (value) {
                      //context.read<HomeCubit>().updateSelectedEntity(value);
                    },
                  )),
              Padding(padding: EdgeInsets.only(top: 20)),
              FieldContainer(
                  title: 'Transaction Type: ',
                  child: TextField(
                    controller: transactionTypeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Transaction Type..',
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) => BottomSheetSelector(
                              title: 'Select Transaction Type',
                              items: state.transactionTypes!
                                  .map((item) => {
                                        'Name': item.transactionName,
                                        'Value': item.transactionCode
                                      })
                                  .toList(),
                              onTap: (name, value) {
                                transactionTypeController.text = name;
                                context
                                    .read<TransactionsHomeCubit>()
                                    .setSelectedTransactionType(value);
                                Navigator.pop(context);
                              }));
                    },
                    onChanged: (value) {
                      //context.read<HomeCubit>().updateSelectedEntity(value);
                    },
                  )),
              Visibility(
                  visible:
                      state.selectedType != 'ITM' && state.selectedType != '',
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.only(top: 20)),
                      FieldContainer(
                          title: 'From Date: ',
                          child: TextField(
                            controller: fromDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'From Date..',
                            ),
                            onTap: () async {
                              DateTime? selectedDate = await context
                                  .read<TransactionsHomeCubit>()
                                  .selectDate(context);
                              if (selectedDate != null) {
                                context
                                    .read<TransactionsHomeCubit>()
                                    .setFromDate(DateFormat('dd/MM/yyyy')
                                        .format(selectedDate));
                                fromDateController.text =
                                    DateFormat('dd/MM/yyyy')
                                        .format(selectedDate);
                              }
                            },
                            onChanged: (value) {
                              //context.read<HomeCubit>().updateSelectedEntity(value);
                            },
                          )),
                      Padding(padding: EdgeInsets.only(top: 20)),
                      FieldContainer(
                          title: 'To Date: ',
                          child: TextField(
                            controller: toDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'To Date..',
                            ),
                            onTap: () async {
                              DateTime? selectedDate = await context
                                  .read<TransactionsHomeCubit>()
                                  .selectDate(context);
                              if (selectedDate != null) {
                                context.read<TransactionsHomeCubit>().setToDate(
                                    DateFormat('dd/MM/yyyy')
                                        .format(selectedDate));
                                toDateController.text = DateFormat('dd/MM/yyyy')
                                    .format(selectedDate);
                              }
                            },
                            onChanged: (value) {
                              //context.read<HomeCubit>().updateSelectedEntity(value);
                            },
                          )),
                    ],
                  )),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Visibility(
                        visible: state.error,
                        child: Text(
                          state.errorMessage,
                          style: TextStyle(color: erroColor, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    CustomMainButton(
                        text: 'Continue',
                        backgroundColor: secondaryColor,
                        height: 53,
                        textColor: Colors.white,
                        loading: state.loading,
                        onPressed: () async {
                          if (state.selectedType == 'ITM') {
                            mainNavigatorKey.currentState!.push(
                                MaterialPageRoute(
                                    builder: (_) => BarcodePage(
                                        leCode: state.selectedEntity)));
                            return;
                          }
                          List? transactions = await context
                              .read<TransactionsHomeCubit>()
                              .getTransactions();
                          if (transactions == null) {
                            return;
                          }
                          mainNavigatorKey.currentState!.push(MaterialPageRoute(
                              builder: (_) => TransactionsPage(
                                  transactions: transactions)));
                        }),
                  ],
                ),
              )),
            ],
          ),
        );
      }),
    );
  }
}
