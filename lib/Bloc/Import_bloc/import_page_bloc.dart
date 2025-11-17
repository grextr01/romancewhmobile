import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'import_cubit.dart';
import '../../Controllers/import_controller.dart';
import 'package:romancewhs/Models/portfolio.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color.fromRGBO(37, 91, 181, 1),
        title: const Text(
          'Import Portfolio',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ImportCubit, ImportController>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Import Button
                ElevatedButton.icon(
                  onPressed: state.loading
                      ? null
                      : () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['xlsx', 'xls'],
                            allowCompression: false,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            File excelFile = File(result.files.single.path!);
                            bool success = await context
                                .read<ImportCubit>()
                                .importFromExcel(excelFile);

                            if (!context.mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Successfully imported ${state.importedCount} items'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select Excel File to Import'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor:
                        const Color.fromRGBO(37, 91, 181, 1),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Status Section
                if (state.error)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (state.importedCount > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✓ ${state.importedCount} items imported successfully',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                const SizedBox(height: 20),

                // Clear Button
                if (state.importedCount > 0)
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Portfolio'),
                          content: const Text(
                              'Are you sure you want to delete all imported items?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<ImportCubit>().clearAllPortfolios();
                                Navigator.pop(context);
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Clear All Items',
                        style: TextStyle(color: Colors.white)),
                  ),
                const SizedBox(height: 20),

                // Imported Items List
                if (state.importedItems.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Imported Items (${state.importedItems.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.importedItems.length,
                            itemBuilder: (context, index) {
                              Portfolio item = state.importedItems[index];
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.inventory),
                                  title: Text(item.itemCode),
                                  subtitle: Text(
                                    '${item.description}\nBarcode: ${item.barcode}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}