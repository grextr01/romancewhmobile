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
import 'package:romancewhs/Bloc/Import_bloc/import_page_bloc.dart'; // ✅ ADD THIS
import '../../UX/Theme.dart';

class TransactionsHomePage extends StatefulWidget {
  const TransactionsHomePage({
    super.key,
    required this.legalEntities,
  });
  final List<LegalEntity> legalEntities;

  @override
  State<TransactionsHomePage> createState() => _TransactionsHomePageState();
}

class _TransactionsHomePageState extends State<TransactionsHomePage> {
  late TextEditingController leController;
  late TextEditingController transactionTypeController;
  late TextEditingController fromDateController;
  late TextEditingController toDateController;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    leController = TextEditingController();
    transactionTypeController = TextEditingController();
    fromDateController = TextEditingController();
    toDateController = TextEditingController();

    // ✅ Initialize only if legal entities exist
    if (widget.legalEntities.isNotEmpty) {
      String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      fromDateController.text = currentDate;
      toDateController.text = currentDate;
      leController.text = widget.legalEntities[0].leName;
      
      context
          .read<TransactionsHomeCubit>()
          .setSelectedEntity(widget.legalEntities[0].leCode);
      context.read<TransactionsHomeCubit>().setFromDate(currentDate);
      context.read<TransactionsHomeCubit>().setToDate(currentDate);
    }
    
    context.read<TransactionsHomeCubit>().getTransactionsTypes();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    leController.dispose();
    transactionTypeController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show friendly UI if no legal entities
    if (widget.legalEntities.isEmpty) {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center_outlined,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              const Text(
                'No Warehouse Access',
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
                  'Your account does not have access to warehouse management features.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Contact your administrator if you need warehouse access.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  mainNavigatorKey.currentState?.pop();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    // ✅ Normal warehouse management UI
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
        // ✅ ADD IMPORT BUTTON HERE
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import Portfolio',
            onPressed: () {
              mainNavigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => const ImportPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionsHomeCubit, TransactionsHomeController>(
          builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              FieldContainer(
                  title: 'Select LE: ',
                  child: TextField(
                    controller: leController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Enter LE Code',
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) => BottomSheetSelector(
                              title: 'Select Legal Entity',
                              items: widget.legalEntities
                                  .map((item) => {
                                        'Name': item.leName,
                                        'Value': item.leCode
                                      })
                                  .toList(),
                              onTap: (name, value, trxCode) {
                                leController.text = name;
                                context
                                    .read<TransactionsHomeCubit>()
                                    .setSelectedEntity(value);
                                Navigator.pop(context);
                              }));
                    },
                  )),
              const Padding(padding: EdgeInsets.only(top: 20)),
              FieldContainer(
                  title: 'Transaction Type: ',
                  child: TextField(
                    controller: transactionTypeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Transaction Type..',
                    ),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (ctx) => BottomSheetSelector(
                              title: 'Select Transaction Type',
                              items: state.transactionTypes != null
                                  ? state.transactionTypes!
                                      .map((item) => {
                                            'Name': item.transactionName,
                                            'Value': item.transactionCode,
                                            'TrxCode': item.trxCode
                                          })
                                      .toList()
                                  : [],
                              onTap: (name, value, trxCode) {
                                transactionTypeController.text = name;
                                context
                                    .read<TransactionsHomeCubit>()
                                    .setSelectedTransactionType(value, trxCode);
                                Navigator.pop(context);
                              }));
                    },
                  )),
              Visibility(
                  visible:
                      state.selectedType != 'ITM' && state.selectedType != '',
                  child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      FieldContainer(
                          title: 'From Date: ',
                          child: TextField(
                            controller: fromDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
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
                          )),
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      FieldContainer(
                          title: 'To Date: ',
                          child: TextField(
                            controller: toDateController,
                            readOnly: true,
                            decoration: const InputDecoration(
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
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Visibility(
                        visible: state.error,
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: erroColor, fontSize: 16),
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
                                    transactions: transactions,
                                    trxCode: state.selectedTrxCode,
                                  )));
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