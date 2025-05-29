import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:romancewhs/Controllers/transactions_home_controller.dart';
import 'package:romancewhs/Models/transaction_type.dart';
import 'package:romancewhs/UX/Api.dart';

class TransactionsHomeCubit extends Cubit<TransactionsHomeController> {
  API api = API();
  TransactionsHomeCubit(super.initialState);

  void setSelectedEntity(String selectedEntity) {
    emit(state.copyWith(selectedEntity: selectedEntity));
  }

  void setSelectedTransactionType(String transactionType) {
    emit(state.copyWith(selectedType: transactionType));
  }

  void setFromDate(String fromDate) {
    emit(state.copyWith(fromDate: fromDate));
  }

  void setToDate(String toDate) {
    emit(state.copyWith(toDate: toDate));
  }

  void setLoading(bool loading, String selectedEntity, String selectedType) {
    emit(state.copyWith(
        loading: loading,
        selectedEntity: selectedEntity,
        selectedType: selectedType));
  }

  Future<void> getTransactionsTypes() async {
    var response =
        await api.getApiToMap(api.apiBaseUrl, '/TransactionType', 'get');
    if (response['statusCode'] == 200) {
      List types = response['data'];
      // state.transactionTypes = types
      //     .map((type) => TransactionType(
      //         transactionCode: type['Transaction_Code'],
      //         transactionName: type['Transaction_Name'],
      //         action: type['Action']))
      //     .toList();
      emit(state.copyWith(
          transactionTypes: types
              .map((type) => TransactionType(
                  transactionCode: type['Transaction_Code'],
                  transactionName: type['Transaction_Name'],
                  action: type['Action']))
              .toList(),
          loading: false,
          error: false));
    } else {
      // Handle error
    }
    //emit(state.copyWith(transactionTypes: state.transactionTypes));
  }

  Future<List<Map>?> getTransactions() async {
    emit(state.copyWith(loading: true, error: false, errorMessage: ''));
    String dateFrom = DateFormat('yyyy-MM-dd')
        .format(DateFormat('dd/MM/yyyy').parse(state.fromDate));
    String dateTo = DateFormat('yyyy-MM-dd')
        .format(DateFormat('dd/MM/yyyy').parse(state.toDate));
    var response = await api.getApiToMap(
        api.apiBaseUrl,
        '/Warehouse/romance/header?legalEntityId=${state.selectedEntity}&dateFrom=$dateFrom&dateTo=$dateTo&trxType=${state.selectedType}',
        'get');
    if (response['statusCode'] == 200) {
      List transactions = response['data'];
      // return [
      //   {
      //     'TRX_HEADER_ID': 1231,
      //     'CONS_BILLING_NUMBER': '123456',
      //     'CUSTOMER_NUMBER': '123123',
      //     'CUSTOMER_NAME': 'Customer Name',
      //     'CURRENCY_CODE': 'USD',
      //     'TOTAL_AMOUNT': 1000.0,
      //   }
      // ];
      emit(state.copyWith(loading: false, error: false));
      return transactions
          .map((transaction) => {
                'TRX_HEADER_ID': transaction['TRX_HEADER_ID'],
                'CONS_BILLING_NUMBER': transaction['CONS_BILLING_NUMBER'],
                'CUSTOMER_NUMBER': transaction['CUSTOMER_NUMBER'],
                'CUSTOMER_NAME': transaction['CUSTOMER_NAME'],
                'CURRENCY_CODE': transaction['CURRENCY_CODE'],
                'TOTAL_AMOUNT': transaction['TOTAL_AMOUNT'],
              })
          .toList();
    } else {
      emit(state.copyWith(
          error: true,
          loading: false,
          errorMessage: 'Failed to load transactions'));
      return null;
    }
  }

  Future<DateTime?> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    return picked;
  }
}
