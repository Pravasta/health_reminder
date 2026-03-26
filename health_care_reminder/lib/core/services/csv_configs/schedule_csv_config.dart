// Author: Pravasta Rama - 2026

import 'package:health_care_reminder/core/services/csv_export_service.dart';
import 'package:health_care_reminder/domain/entity/schedule_entity.dart';
import 'package:intl/intl.dart';

/// [ScheduleCsvConfig] Predefined CSV export configurations for schedule data.
///
/// Provides ready-to-use [CsvExportConfig] for exporting treatment history
/// and schedule data. Supports multiple export formats.
class ScheduleCsvConfig {
  ScheduleCsvConfig._();

  /// Full treatment history export with all details.
  static CsvExportConfig<ScheduleEntity> treatmentHistory({
    required String patientName,
  }) {
    final safeName = patientName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());

    return CsvExportConfig<ScheduleEntity>(
      fileName: 'treatment_history_${safeName}_$dateStr',
      columns: [
        CsvColumn(
          header: 'No',
          value: (item) => '', // will be filled by index
        ),
        CsvColumn(
          header: 'Patient Name',
          value: (item) => item.patient?.name ?? '-',
        ),
        CsvColumn(
          header: 'Treatment',
          value: (item) =>
              item.treatment?.name ?? 'Treatment #${item.treatmentID}',
        ),
        CsvColumn(
          header: 'Date',
          value: (item) => DateFormat('dd MMM yyyy').format(item.startTime),
        ),
        CsvColumn(
          header: 'Start Time',
          value: (item) => DateFormat('HH:mm').format(item.startTime),
        ),
        CsvColumn(
          header: 'End Time',
          value: (item) => DateFormat('HH:mm').format(item.endTime),
        ),
        CsvColumn(
          header: 'Duration',
          value: (item) =>
              _formatDuration(item.endTime.difference(item.startTime)),
        ),
        CsvColumn(
          header: 'Status',
          value: (item) => _formatStatus(item.status.name),
        ),
        CsvColumn(
          header: 'Description',
          value: (item) => item.treatment?.description ?? '-',
        ),
      ],
    );
  }

  /// Compact export with minimal columns.
  static CsvExportConfig<ScheduleEntity> compact({
    required String patientName,
  }) {
    final safeName = patientName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());

    return CsvExportConfig<ScheduleEntity>(
      fileName: 'treatment_compact_${safeName}_$dateStr',
      columns: [
        CsvColumn(
          header: 'Treatment',
          value: (item) =>
              item.treatment?.name ?? 'Treatment #${item.treatmentID}',
        ),
        CsvColumn(
          header: 'Date',
          value: (item) => DateFormat('dd/MM/yyyy').format(item.startTime),
        ),
        CsvColumn(
          header: 'Duration',
          value: (item) =>
              _formatDuration(item.endTime.difference(item.startTime)),
        ),
        CsvColumn(
          header: 'Status',
          value: (item) => _formatStatus(item.status.name),
        ),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hr $minutes min';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$minutes min';
    }
  }

  static String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }
}
