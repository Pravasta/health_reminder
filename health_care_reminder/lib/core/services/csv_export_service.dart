// Author: Pravasta Rama - 2026

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// [CsvColumn] Defines a single column in the CSV export.
///
/// [T] is the type of the data object being exported.
/// [header] is the column name shown in the CSV header row.
/// [value] is a function that extracts the value for this column from the data object.
class CsvColumn<T> {
  final String header;
  final String Function(T item) value;

  const CsvColumn({required this.header, required this.value});
}

/// [CsvExportConfig] Configuration for a CSV export operation.
///
/// [T] is the type of the data objects being exported.
/// [fileName] is the name of the CSV file (without extension).
/// [columns] defines the columns and how to extract data.
/// [headerInfo] optional info rows before the data table.
/// [footerInfo] optional summary rows after the data table.
class CsvExportConfig<T> {
  final String fileName;
  final List<CsvColumn<T>> columns;
  final List<String>? headerInfo;
  final List<String> Function(List<T> data)? footerInfo;

  const CsvExportConfig({
    required this.fileName,
    required this.columns,
    this.headerInfo,
    this.footerInfo,
  });
}

/// [CsvExportResult] Result of a CSV export operation.
class CsvExportResult {
  final bool success;
  final String? filePath;
  final String? error;

  const CsvExportResult._({required this.success, this.filePath, this.error});

  factory CsvExportResult.success(String filePath) =>
      CsvExportResult._(success: true, filePath: filePath);

  factory CsvExportResult.failure(String error) =>
      CsvExportResult._(success: false, error: error);
}

/// [CsvExportService] A reusable service for exporting data to CSV files.
///
/// This service handles the full CSV export pipeline:
/// 1. Convert data to CSV format
/// 2. Write to file
/// 3. Share via system share sheet
///
/// Example:
/// ```dart
/// final service = CsvExportService();
///
/// final config = CsvExportConfig<MyModel>(
///   fileName: 'my_data',
///   columns: [
///     CsvColumn(header: 'Name', value: (item) => item.name),
///     CsvColumn(header: 'Age', value: (item) => item.age.toString()),
///   ],
/// );
///
/// final result = await service.export(data: myList, config: config);
/// ```
class CsvExportService {
  CsvExportService._internal();

  static final CsvExportService _instance = CsvExportService._internal();

  factory CsvExportService() => _instance;

  /// Exports data to CSV and returns the file path.
  Future<CsvExportResult> export<T>({
    required List<T> data,
    required CsvExportConfig<T> config,
  }) async {
    try {
      // 1. Build CSV rows
      final csvData = _buildCsvData(data, config);

      // 2. Convert to CSV string
      const converter = ListToCsvConverter();
      final csvString = converter.convert(csvData);

      // 3. Write to file
      final filePath = await _writeToFile(csvString, config.fileName);

      return CsvExportResult.success(filePath);
    } catch (e) {
      return CsvExportResult.failure('Failed to export CSV: $e');
    }
  }

  /// Exports data to CSV and opens the system share sheet.
  Future<CsvExportResult> exportAndShare<T>({
    required List<T> data,
    required CsvExportConfig<T> config,
  }) async {
    final result = await export(data: data, config: config);

    if (result.success && result.filePath != null) {
      await _shareFile(result.filePath!);
    }

    return result;
  }

  /// Builds the CSV data rows from the config and data.
  List<List<String>> _buildCsvData<T>(List<T> data, CsvExportConfig<T> config) {
    final rows = <List<String>>[];

    // Header info rows (each as a single-cell row)
    if (config.headerInfo != null) {
      for (final line in config.headerInfo!) {
        rows.add([line]);
      }
    }

    // Column header row
    final headers = config.columns.map((col) => col.header).toList();
    rows.add(headers);

    // Data rows with auto-numbering for 'No' column
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final row = config.columns.map((col) {
        if (col.header == 'No') return '${i + 1}';
        return col.value(item);
      }).toList();
      rows.add(row);
    }

    // Footer info rows
    if (config.footerInfo != null) {
      for (final line in config.footerInfo!(data)) {
        rows.add([line]);
      }
    }

    return rows;
  }

  /// Writes CSV string to a file in the app's temporary directory.
  Future<String> _writeToFile(String csvString, String fileName) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/${fileName}_$timestamp.csv';
    final file = File(filePath);

    await file.writeAsString(csvString);

    return filePath;
  }

  /// Shares the file using the system share sheet.
  Future<void> _shareFile(String filePath) async {
    final xFile = XFile(filePath);
    await SharePlus.instance.share(ShareParams(files: [xFile]));
  }
}
