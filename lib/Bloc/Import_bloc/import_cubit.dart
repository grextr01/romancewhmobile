// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:romancewhs/Controllers/import_controller.dart';
import 'package:romancewhs/Models/portfolio.dart';
import 'package:romancewhs/UX/DatabaseUX/portfolio_database.dart';

// Top-level function for background processing
List<Portfolio> _parseExcelInBackground(List<int> bytes) {
  var excel = Excel.decodeBytes(bytes);
  List<Portfolio> importedItems = [];

  for (var table in excel.tables.keys) {
    var sheet = excel.tables[table];
    if (sheet == null || sheet.maxRows < 2) continue; // Must have header and at least one data row

    var headerRow = sheet.row(0);
    
    // Map header names to column indices
    Map<String, int> headerMap = {};
    for (int i = 0; i < headerRow.length; i++) {
        var cellValue = headerRow[i]?.value;
        if (cellValue != null) {
            headerMap[cellValue.toString().toLowerCase().trim()] = i;
        }
    }

    // Find indices for required columns
    int? barcodeIndex = headerMap['barcode'];
    int? itemCodeIndex = headerMap['item code'] ?? headerMap['itemcode'];
    int? descriptionIndex = headerMap['description'];

    // Skip sheet if any required column is not found
    if (barcodeIndex == null || itemCodeIndex == null || descriptionIndex == null) {
      continue;
    }

    // Process data rows
    for (int i = 1; i < sheet.maxRows; i++) {
      var row = sheet.row(i);
      
      // Basic validation for row
      if (row.isEmpty || row.length <= barcodeIndex || row[barcodeIndex]?.value == null) {
        continue;
      }

      try {
        final barcode = row[barcodeIndex]?.value?.toString() ?? '';
        final itemCode = row[itemCodeIndex]?.value?.toString() ?? '';
        final description = row[descriptionIndex]?.value?.toString() ?? '';

        if (barcode.isNotEmpty && itemCode.isNotEmpty && description.isNotEmpty) {
          importedItems.add(Portfolio(
            barcode: barcode,
            itemCode: itemCode,
            description: description,
            createdAt: DateTime.now(),
          ));
        }
      } catch (e) {
        // In case of any parsing error for a row, just skip it.
        continue;
      }
    }
  }
  return importedItems;
}

class ImportCubit extends Cubit<ImportController> {
  ImportCubit(super.initialState);

  final portfolioDb = PortfolioDatabase();

  /// Import portfolios from Excel file
  Future<bool> importFromExcel(File excelFile) async {
    try {
      emit(state.copyWith(loading: true, error: false, errorMessage: ''));

      // Read file bytes asynchronously
      var bytes = await excelFile.readAsBytes();

      // Process excel in a background isolate to prevent UI freezing
      List<Portfolio> importedItems = await compute(_parseExcelInBackground, bytes);

      if (importedItems.isEmpty) {
        emit(state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'No valid items found in Excel file. Please check the column headers (barcode, item code, description).',
        ));
        return false;
      }

      // Save to database
      await portfolioDb.insertMultiplePortfolios(importedItems);

      emit(state.copyWith(
        loading: false,
        error: false,
        importedCount: importedItems.length,
        importedItems: importedItems,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: true,
        errorMessage: 'Error importing file: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Clear all portfolios
  Future<void> clearAllPortfolios() async {
    emit(state.copyWith(loading: true));
    await portfolioDb.deleteAllPortfolios();
    emit(state.copyWith(
      loading: false,
      importedCount: 0,
      importedItems: [],
    ));
  }

  /// Get all portfolios from database
  Future<void> loadPortfolios() async {
    emit(state.copyWith(loading: true));
    try {
      final items = await portfolioDb.getAllPortfolios();
      emit(state.copyWith(
        loading: false,
        importedItems: items,
        importedCount: items.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: true,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Search portfolios
  Future<void> searchPortfolios(String query,
      {String searchType = 'barcode'}) async {
    try {
      List<Portfolio> results = [];

      if (searchType == 'barcode') {
        results = await portfolioDb.searchByBarcode(query);
      } else if (searchType == 'itemCode') {
        results = await portfolioDb.searchByItemCode(query);
      }

      emit(state.copyWith(importedItems: results));
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: e.toString(),
      ));
    }
  }
}
