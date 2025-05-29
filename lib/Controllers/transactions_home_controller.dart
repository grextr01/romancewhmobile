import '../Models/transaction_type.dart';

class TransactionsHomeController {
  String selectedEntity;
  final String selectedType;
  final String fromDate;
  final String toDate;
  final List<TransactionType>? transactionTypes;
  final bool loading;
  final bool error;
  final String errorMessage;

  TransactionsHomeController({
    this.fromDate = '',
    this.toDate = '',
    this.selectedEntity = '',
    this.selectedType = '',
    this.transactionTypes,
    this.loading = false,
    this.error = false,
    this.errorMessage = '',
  });

  TransactionsHomeController copyWith({
    String? selectedEntity,
    List<TransactionType>? transactionTypes,
    String? selectedType,
    bool? error,
    bool? loading,
    String? errorMessage,
    String? fromDate,
    String? toDate,
  }) {
    return TransactionsHomeController(
      selectedEntity: selectedEntity ?? this.selectedEntity,
      transactionTypes: transactionTypes ?? this.transactionTypes,
      selectedType: selectedType ?? this.selectedType,
      error: error ?? this.error,
      loading: loading ?? this.loading,
      errorMessage: errorMessage ?? this.errorMessage,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
