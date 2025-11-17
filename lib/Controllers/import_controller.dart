import 'package:romancewhs/Models/portfolio.dart';
import 'package:romancewhs/UX/DatabaseUX/portfolio_database.dart';

class ImportController {
  bool loading = false;
  bool error = false;
  String errorMessage = '';
  int importedCount = 0;
  List<Portfolio> importedItems = [];

  ImportController({
    this.loading = false,
    this.error = false,
    this.errorMessage = '',
    this.importedCount = 0,
    this.importedItems = const [],
  });

  ImportController copyWith({
    bool? loading,
    bool? error,
    String? errorMessage,
    int? importedCount,
    List<Portfolio>? importedItems,
  }) {
    return ImportController(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
      importedCount: importedCount ?? this.importedCount,
      importedItems: importedItems ?? this.importedItems,
    );
  }
}