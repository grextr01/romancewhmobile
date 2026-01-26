import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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
import 'package:sqflite/sqflite.dart';

import '../../UX/Database.dart';

class CycleCountCubit extends Cubit<CycleCountController> {
  final dbConn cycleCountDb = dbConn();
  final dbConn portfolioDb = dbConn();

  /// Cache for manually entered descriptions (barcode -> description)
  final Map<String, String> _manualDescriptionCache = {};

  CycleCountCubit(super.initialState);

  bool isQuantityAutomatic() {
    return state.automaticQuantityMode;
  }

  bool isMergeAutomatic() {
    return state.automaticMergeMode;
  }

  /// Set automatic quantity mode
  void setAutomaticQuantityMode(bool value) {
    emit(state.copyWith(automaticQuantityMode: value));
  }

  /// Set automatic merge mode
  void setAutomaticMergeMode(bool value) {
    emit(state.copyWith(automaticMergeMode: value));
  }

  /// Toggle automatic quantity mode
  void toggleAutomaticQuantity(bool value) {
    emit(state.copyWith(automaticQuantityMode: value));
  }

  /// Toggle automatic merge mode
  void toggleAutomaticMerge(bool value) {
    emit(state.copyWith(automaticMergeMode: value));
  }

  /// Set allow manual descriptions mode
  void setAllowManualDescriptions(bool value) {
    emit(state.copyWith(allowManualDescriptions: value));
  }

  /// Toggle allow manual descriptions mode
  void toggleAllowManualDescriptions(bool value) {
    emit(state.copyWith(allowManualDescriptions: value));
  }

  /// Get previously entered description for a barcode (from cache)
  String? getCachedDescription(String barcode) {
    return _manualDescriptionCache[barcode];
  }

  /// Store manually entered description in cache
  void cacheDescription(String barcode, String description) {
    _manualDescriptionCache[barcode] = description;
  }

  /// Clear the cache (useful when starting new session)
  void clearDescriptionCache() {
    _manualDescriptionCache.clear();
  }

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

      // Clear cache when starting new session
      clearDescriptionCache();

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

  /// Check if barcode has a cached (manually entered) description
  String? getDescriptionFromCache(String barcode) {
    return _manualDescriptionCache[barcode];
  }

  /// Scan a barcode and add to the session (with merge and cache support)
  Future<bool> scanBarcode(
      String barcode, {
        String? manualDescription,
        String isAutomatic = 'A',
        int quantity = 1,
      }) async {
    try {
      if (state.headerId == null) {
        emit(state.copyWith(
          error: true,
          errorMessage: 'No active session',
        ));
        return false;
      }

      if (state.automaticMergeMode) {
        final existingItem = state.findExistingItem(barcode);
        if (existingItem != null) {
          final newQuantity = existingItem.quantity + quantity;
          await updateItemQuantity(existingItem.detailId!, newQuantity);

          // Reorder: Move merged item to top
          final updatedItems = state.scannedItems
              .where((item) => item.detailId != existingItem.detailId)
              .toList();

          // Update the existing item with new quantity
          existingItem.quantity = newQuantity;

          // Add it to the beginning of the list (TOP)
          updatedItems.insert(0, existingItem);

          emit(state.copyWith(
            scannedItems: updatedItems,
            scannedBarcode: barcode,
            error: false,
            errorMessage: '',
          ));
          return true;
        }
      }

      // Search in portfolio
      final results = await findItemByBarcode(barcode);

      if (results.isEmpty && manualDescription == null) {
        // Check if we have a cached description for this barcode
        final cachedDescription = getDescriptionFromCache(barcode);

        if (cachedDescription != null) {
          // We have a cached description! Use it automatically
          return await _addItemWithDescription(
            barcode: barcode,
            itemCode: '',
            description: cachedDescription,
            quantity: quantity,
            isAutomatic: isAutomatic,
          );
        }

        // If manual descriptions are disabled, add item without description
        if (!state.allowManualDescriptions) {
          return await _addItemWithDescription(
            barcode: barcode,
            itemCode: '',
            description: '', // Empty description
            quantity: quantity,
            isAutomatic: isAutomatic,
          );
        }

        // If manual descriptions are enabled, ask user to enter it
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

      // Cache the description if it was manually entered
      if (manualDescription != null) {
        cacheDescription(barcode, manualDescription);
      }

      return await _addItemWithDescription(
        barcode: barcode,
        itemCode: itemCode,
        description: description,
        quantity: quantity,
        isAutomatic: isAutomatic,
      );
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Error scanning barcode: ${e.toString()}',
      ));
      return false;
    }
  }

  /// Helper method to add item with description
  Future<bool> _addItemWithDescription({
    required String barcode,
    required String itemCode,
    required String description,
    required int quantity,
    required String isAutomatic,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();

      final detailMap = {
        'headerId': state.headerId,
        'barcode': barcode,
        'itemCode': itemCode,
        'description': description,
        'quantity': quantity,
        'timestamp': timestamp,
        'isAutomatic': isAutomatic,
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
          quantity: quantity,
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
        final updatedItems = [detail, ...state.scannedItems];
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
        errorMessage: 'Error adding item: ${e.toString()}',
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

  /// Set scanned quantity for manual mode
  void setScannedQuantity(int quantity) {
    emit(state.copyWith(scannedQty: quantity));
  }

  /// Load existing session
  Future<bool> loadSession(int headerId) async {
    try {
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

      // Rebuild cache from loaded items (for descriptions entered this session)
      for (var detail in details) {
        if (detail.barcode.isNotEmpty && detail.description.isNotEmpty) {
          cacheDescription(detail.barcode, detail.description);
        }
      }

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

      // Clear cache after session ends
      clearDescriptionCache();

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

  /// Delete a cycle count session
  Future<void> deleteSession(int headerId) async {
    try {
      await cycleCountDb.deleteHeader(headerId);

      // Remove from existingSessions list
      final updatedSessions = state.existingSessions
          .where((session) => session.id != headerId)
          .toList();

      emit(state.copyWith(
        existingSessions: updatedSessions,
        error: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Error deleting session: ${e.toString()}',
      ));
    }
  }

  /// Export cycle count to Excel file
  Future<bool> exportCycleCountToExcel(int headerId, String portfolioName) async {
    try {
      emit(state.copyWith(loading: true, error: false));

      final detailsMaps = await cycleCountDb.getDetailsByHeader(headerId);

      if (detailsMaps.isEmpty) {
        emit(state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'No items found to export for this cycle count',
        ));
        return false;
      }

      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      const List<String> headers = [
        'Barcode',
        'ItemCode',
        'Description',
        'Quantity',
        'Notes',
        'Timestamp',
        'IsAutomatic'
      ];

      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: 0))
            .value = TextCellValue(headers[colIndex]);
      }

      for (int rowIndex = 0; rowIndex < detailsMaps.length; rowIndex++) {
        final detail = detailsMaps[rowIndex];
        final dataRowIndex = rowIndex + 1;

        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: 0,
          rowIndex: dataRowIndex,
        ))
            .value = TextCellValue(detail['barcode']?.toString() ?? '');

        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: 1,
          rowIndex: dataRowIndex,
        ))
            .value = TextCellValue(detail['itemCode']?.toString() ?? '');

        // Description with allowManualDescriptions check
        final description = detail['description']?.toString() ?? '';
        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: dataRowIndex,
        ))
            .value = TextCellValue(
          description.isEmpty && !state.allowManualDescriptions
              ? '-'
              : description,
        );

        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: 3,
          rowIndex: dataRowIndex,
        ))
            .value = TextCellValue((detail['quantity'] ?? 0).toString());

        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: 4,
          rowIndex: dataRowIndex,
        ))
            .value = TextCellValue(detail['notes']?.toString() ?? '');

        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: 5,
          rowIndex: dataRowIndex,
        ))
            .value = TextCellValue(detail['timestamp']?.toString() ?? '');

        final isAutomaticValue = detail['isAutomatic']?.toString() ?? 'A';
        sheet
            .cell(CellIndex.indexByColumnRow(
          columnIndex: 6,
          rowIndex: dataRowIndex,
        ))
            .value = TextCellValue(isAutomaticValue);
      }

      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('Cannot access external storage. Please check permissions.');
      }

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final safePortfolioName = portfolioName.replaceAll(RegExp(r'[^\w\s-]'), '');
      final fileName = '${safePortfolioName}_$timestamp.xlsx';

      try {
        final excelBytes = excel.encode();
        final excelBytest = Uint8List.fromList(excelBytes!);
        final path = await FilePicker.platform.saveFile(
          dialogTitle: 'Save your file',
          fileName: fileName,
          bytes: excelBytest,
        );

        if (path == null) {
          emit(state.copyWith(
            loading: false,
            error: true,
            errorMessage: 'File save cancelled',
          ));
          return false;
        }

        emit(state.copyWith(
          loading: false,
          error: false,
          errorMessage: 'File saved successfully',
        ));

        return true;
      } catch (e) {
        throw Exception("error saving file: $e");
      }
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