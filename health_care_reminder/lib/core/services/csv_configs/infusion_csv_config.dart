import 'package:health_care_reminder/core/services/csv_export_service.dart';
import 'package:health_care_reminder/domain/entity/infusion_entity.dart';
import 'package:intl/intl.dart';

/// [InfusionCsvConfig] Predefined CSV export configurations for infusion data.
class InfusionCsvConfig {
  InfusionCsvConfig._();

  /// Full treatment history export with all details.
  static CsvExportConfig<InfusionEntity> treatmentHistory({
    required String patientName,
    required String patientCode,
  }) {
    final safeName = patientName
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '_');
    final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());

    return CsvExportConfig<InfusionEntity>(
      fileName: 'treatment_history_${safeName}_$dateStr',
      headerInfo: [
        'Treatment History Report',
        'Patient Name: $patientName',
        'Patient Code: $patientCode',
        'Exported: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}',
        '', // blank row separator
      ],
      columns: [
        CsvColumn(
          header: 'No',
          value: (item) => '', // filled by index
        ),
        CsvColumn(header: 'Infusion Name', value: (item) => item.infusionName),
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
      ],
      footerInfo: (data) {
        final total = data.length;
        final running = data.where((e) => e.status.name == 'running').length;
        final completed = data
            .where((e) => e.status.name == 'completed')
            .length;
        final stopped = data.where((e) => e.status.name == 'stopped').length;

        return [
          '', // blank row separator
          'Summary',
          'Total Infusions: $total',
          'Running: $running',
          'Completed: $completed',
          'Stopped: $stopped',
        ];
      },
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
