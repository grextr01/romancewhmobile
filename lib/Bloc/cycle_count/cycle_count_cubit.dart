import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:romancewhs/Controllers/cycle_count_controller.dart';
import 'package:romancewhs/Models/cycle_count_detail.dart';
import 'package:romancewhs/Models/cycle_count_header.dart';
import 'package:romancewhs/UX/cycle_count_database.dart';
import 'package:romancewhs/UX/DatabaseUX/portfolio_database.dart';
import 'package:romancewhs/Models/Boxes/boxes.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CycleCountCubit extends Cubit<CycleCountController> {
  final CycleCountDatabase cycleCountDb = CycleCountDatabase();
  final PortfolioDatabase portfolioDb = PortfolioDatabase();

  CycleCountCubit(super.initialState);

  /// Load all existing cycle count sessions from database
  Future<void> loadAllSessions() async {
    try {
      emit(state.copyWith(loading: true, error: false));

      final headersMaps = await cycleCountDb.getAllHeaders();
      final sessions = headersMaps
          .map((map) => CycleCountHeader.fromMap(map))
          .toList();

      // Sort by timestamp (newest first)
      sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(state.copyWith(
        existingSessions: sessions,
        loading: false,
        error: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: true,
        errorMessage: 'Error loading sessions: ${e.toString()}',
      ));
    }
  }

  /// Initialize a new cycle count session
  Future<int> initializeSession(String portfolioName) async {
    try {
      emit(state.copyWith(loading: true, error: false));

      final user = userBox.get('activeUser');
      if (user == null) {
        emit(state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'User not found',
        ));
        return -1;
      }

      final timestamp = DateTime.now().toIso8601String();

      final headerMap = {
        'portfolio': portfolioName,
        'timestamp': timestamp,
        'userId': user.userId,
        'totalItems': 0,
        'scannedItems': 0,
      };

      final headerId = await cycleCountDb.insertHeader(headerMap);

      emit(state.copyWith(
        headerId: headerId,
        portfolioName: portfolioName,
        loading: false,
        error: false,
        scannedItems: [],
      ));

      return headerId;
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: true,
        errorMessage: 'Error initializing session: ${e.toString()}',
      ));
      return -1;
    }
  }

  /// Load portfolio items from local database
  Future<void> loadPortfolioItems() async {
    try {
      emit(state.copyWith(loading: true, error: false));

      final portfolios = await portfolioDb.getAllPortfolios();
      final items = portfolios
          .map((p) => {
                'barcode': p.barcode,
                'itemCode': p.itemCode,
                'description': p.description,
              })
          .toList();

      emit(state.copyWith(
        pendingPortfolioItems: items,
        loading: false,
        error: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: true,
        errorMessage: 'Error loading portfolio: ${e.toString()}',
      ));
    }
  }

  /// Find item in portfolio by barcode
  Future<List<Map<String, dynamic>>> findItemByBarcode(String barcode) async {
    try {
      final results = await portfolioDb.searchByBarcode(barcode);
      return results
          .map((p) => {
                'barcode': p.barcode,
                'itemCode': p.itemCode,
                'description': p.description,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Scan a barcode and add to the session
  Future<bool> scanBarcode(
    String barcode, {
    String? manualDescription,
    bool isAutomatic = true,
  }) async {
    try {
      if (state.headerId == null) {
        emit(state.copyWith(
          error: true,
          errorMessage: 'No active session',
        ));
        return false;
      }

      // Search in portfolio
      final results = await findItemByBarcode(barcode);

      if (results.isEmpty && manualDescription == null) {
        // Item not found and no manual description provided
        emit(state.copyWith(
          error: true,
          errorMessage: 'Barcode not found in portfolio. Please enter description.',
          scannedBarcode: barcode,
        ));
        return false;
      }

      // Prepare the detail
      final itemCode = results.isNotEmpty ? results.first['itemCode'] : '';
      final description =
          results.isNotEmpty ? results.first['description'] : manualDescription ?? '';

      final timestamp = DateTime.now().toIso8601String();

      final detailMap = {
        'headerId': state.headerId,
        'barcode': barcode,
        'itemCode': itemCode,
        'description': description,
        'quantity': state.automaticQuantityMode ? 1 : state.scannedQty,
        'timestamp': timestamp,
        'isAutomatic': isAutomatic ? 1 : 0,
      };

      final detailId = await cycleCountDb.insertDetail(detailMap);

      if (detailId > 0) {
        // Create CycleCountDetail object
        final detail = CycleCountDetail(
          detailId: detailId,
          headerId: state.headerId!,
          barcode: barcode,
          itemCode: itemCode,
          description: description,
          quantity: state.automaticQuantityMode ? 1 : state.scannedQty,
          timestamp: timestamp,
          isAutomatic: isAutomatic,
        );

        // Update header scanned count
        final currentHeader = await cycleCountDb.getHeader(state.headerId!);
        if (currentHeader != null) {
          await cycleCountDb.updateHeader(state.headerId!, {
            'scannedItems': (currentHeader['scannedItems'] as int? ?? 0) + 1,
          });
        }

        // Update state
        final updatedItems = [...state.scannedItems, detail];
        emit(state.copyWith(
          scannedItems: updatedItems,
          scannedBarcode: barcode,
          error: false,
          errorMessage: '',
        ));

        return true;
      }

      return false;
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Error scanning barcode: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Update quantity for a scanned item
  Future<void> updateItemQuantity(int detailId, int newQuantity) async {
    try {
      await cycleCountDb.updateDetail(detailId, {'quantity': newQuantity});

      // Update local state
      final updatedItems = state.scannedItems.map((item) {
        if (item.detailId == detailId) {
          item.quantity = newQuantity;
        }
        return item;
      }).toList();

      emit(state.copyWith(scannedItems: updatedItems));
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Error updating quantity: ${e.toString()}',
      ));
    }
  }

  /// Add note to an item
  Future<void> addNoteToItem(int detailId, String note) async {
    try {
      await cycleCountDb.updateDetail(detailId, {'notes': note});

      final updatedItems = state.scannedItems.map((item) {
        if (item.detailId == detailId) {
          // Create new item with updated note (CycleCountDetail doesn't have mutable notes)
          return CycleCountDetail(
            detailId: item.detailId,
            headerId: item.headerId,
            barcode: item.barcode,
            itemCode: item.itemCode,
            description: item.description,
            quantity: item.quantity,
            notes: note,
            picture: item.picture,
            timestamp: item.timestamp,
            isAutomatic: item.isAutomatic,
          );
        }
        return item;
      }).toList();

      emit(state.copyWith(scannedItems: updatedItems));
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Error adding note: ${e.toString()}',
      ));
    }
  }

  /// Remove an item from the session
  Future<void> removeItem(int detailId) async {
    try {
      await cycleCountDb.deleteDetail(detailId);

      final updatedItems = state.scannedItems
          .where((item) => item.detailId != detailId)
          .toList();

      emit(state.copyWith(scannedItems: updatedItems));
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Error removing item: ${e.toString()}',
      ));
    }
  }

  /// Toggle automatic quantity mode
  void toggleAutomaticQuantity(bool value) {
    emit(state.copyWith(automaticQuantityMode: value));
  }

  /// Set scanned quantity for manual mode
  void setScannedQuantity(int quantity) {
    emit(state.copyWith(scannedQty: quantity));
  }

  /// Load existing session
  Future<bool> loadSession(int headerId) async {
    try {
      emit(state.copyWith(loading: true));

      final header = await cycleCountDb.getHeader(headerId);
      if (header == null) {
        emit(state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'Session not found',
        ));
        return false;
      }

      final detailsMaps = await cycleCountDb.getDetailsByHeader(headerId);
      final details = detailsMaps
          .map((map) => CycleCountDetail.fromMap(map))
          .toList();

      emit(state.copyWith(
        headerId: headerId,
        portfolioName: header['portfolio'] as String,
        scannedItems: details,
        loading: false,
        error: false,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: true,
        errorMessage: 'Error loading session: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Get session summary
  Future<Map<String, dynamic>> getSessionSummary() async {
    try {
      if (state.headerId == null) {
        return {};
      }

      final summary = await cycleCountDb.getHeaderSummary(state.headerId!);
      return {
        'uniqueBarcodes': summary['uniqueBarcodes'],
        'totalQuantity': summary['totalQuantity'],
        'totalLines': summary['totalLines'],
        'portfolioName': state.portfolioName,
      };
    } catch (e) {
      return {};
    }
  }

  /// End and submit cycle count session
  Future<bool> submitSession() async {
    try {
      if (state.headerId == null) {
        return false;
      }

      // Update header with final counts
      final summary = await cycleCountDb.getHeaderSummary(state.headerId!);
      await cycleCountDb.updateHeader(state.headerId!, {
        'totalItems': summary['totalLines'],
      });

      emit(state.copyWith(error: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Error submitting session: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Export cycle count to Excel file
  Future<bool> exportCycleCountToExcel(int headerId, String portfolioName) async {
    try {
      emit(state.copyWith(loading: true, error: false));

      // Fetch all details for this header
      final detailsMaps = await cycleCountDb.getDetailsByHeader(headerId);

      if (detailsMaps.isEmpty) {
        emit(state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'No items found to export for this cycle count',
        ));
        return false;
      }

      // Create new Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // Define column headers in exact order as specified
      const List<String> headers = [
        'Barcode',
        'ItemCode', 
        'Description',
        'Quantity',
        'Notes',
        'Timestamp',
        'IsAutomatic'
      ];

      // Add headers to first row
      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
            .value = TextCellValue(headers[colIndex]);
      }

      // Add data rows
      for (int rowIndex = 0; rowIndex < detailsMaps.length; rowIndex++) {
        final detail = detailsMaps[rowIndex];
        final dataRowIndex = rowIndex + 1;

        // Column 0: Barcode
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: dataRowIndex,
            ))
            .value = TextCellValue(detail['barcode']?.toString() ?? '');

        // Column 1: ItemCode
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 1,
              rowIndex: dataRowIndex,
            ))
            .value = TextCellValue(detail['itemCode']?.toString() ?? '');

        // Column 2: Description
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 2,
              rowIndex: dataRowIndex,
            ))
            .value = TextCellValue(detail['description']?.toString() ?? '');

        // Column 3: Quantity
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 3,
              rowIndex: dataRowIndex,
            ))
            .value = TextCellValue((detail['quantity'] ?? 0).toString());

        // Column 4: Notes
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 4,
              rowIndex: dataRowIndex,
            ))
            .value = TextCellValue(detail['notes']?.toString() ?? '');

        // Column 5: Timestamp
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 5,
              rowIndex: dataRowIndex,
            ))
            .value = TextCellValue(detail['timestamp']?.toString() ?? '');

        // Column 6: IsAutomatic (convert 1/0 to Yes/No)
        final isAutomaticValue = detail['isAutomatic'] == 1 ? 'Yes' : 'No';
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 6,
              rowIndex: dataRowIndex,
            ))
            .value = TextCellValue(isAutomaticValue);
      }

      // ✅ FIX: Use getExternalStorageDirectory instead of getApplicationDocumentsDirectory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Cannot access external storage. Please check permissions.');
      }

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final safePortfolioName = portfolioName.replaceAll(RegExp(r'[^\w\s-]'), '');
      final fileName = '${safePortfolioName}_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';

      // Encode and save the Excel file
      final excelBytes = excel.encode();
      if (excelBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(excelBytes);

        // Verify file was created
        if (!await file.exists()) {
          throw Exception('File was not created successfully');
        }
      } else {
        throw Exception('Failed to encode Excel file');
      }

      // Success - emit state with confirmation message
      emit(state.copyWith(
        loading: false,
        error: false,
        errorMessage: 'File saved successfully to Downloads',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: true,
        errorMessage: 'Error exporting to Excel: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(error: false, errorMessage: ''));
  }
}