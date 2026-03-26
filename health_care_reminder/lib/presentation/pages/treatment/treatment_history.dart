import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/components/custom_button.dart';
import 'package:health_care_reminder/core/components/custom_dialog.dart';
import 'package:health_care_reminder/core/helper/app_snackbar.dart';
import 'package:health_care_reminder/core/routes/app_transition.dart';
import 'package:health_care_reminder/core/services/csv_configs/infusion_csv_config.dart';
import 'package:health_care_reminder/core/services/csv_export_service.dart';
import 'package:health_care_reminder/domain/entity/patient_entity.dart';
import 'package:health_care_reminder/presentation/bloc/infusion_history/infusion_history_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/enum/infusion_status_enum.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entity/infusion_entity.dart';

class TreatmentHistory extends StatefulWidget {
  const TreatmentHistory({super.key, required this.patient});

  final PatientEntity patient;

  @override
  State<TreatmentHistory> createState() => _TreatmentHistoryState();
}

class _TreatmentHistoryState extends State<TreatmentHistory> {
  List<InfusionEntity> _infusions = [];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    context.read<InfusionHistoryBloc>().getInfusionsByPatientId(
      patientId: widget.patient.id!,
    );
  }

  Future<void> _exportToCsv() async {
    if (_infusions.isEmpty) {
      CustomDialog.showCustomDialog(
        context: context,
        dialogType: DialogEnum.info,
        title: 'Tidak Ada Data',
        message: 'Tidak ada riwayat perawatan yang tersedia untuk diekspor.',
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final config = InfusionCsvConfig.treatmentHistory(
        patientName: widget.patient.name,
        patientCode: widget.patient.patientCode,
      );

      final result = await CsvExportService().exportAndShare(
        data: _infusions,
        config: config,
      );

      if (mounted) {
        if (result.success) {
          AppSnackbar.showCustomSnackbar(
            context: context,
            title: 'Berhasil',
            message: 'File berhasil di Ekspor ke ${result.filePath}',
          );
        } else {
          AppSnackbar.showCustomSnackbar(
            context: context,
            title: 'Terjadi Kesalahan',
            message: 'Gagal melakukan ekspor Data',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightToscaColor,
      appBar: AppBar(
        leading: BackButton(
          color: AppColors.blackColor,
          onPressed: () {
            AppTransition.popTransition<bool>(context, result: true);
          },
        ),
        backgroundColor: AppColors.whiteColor,
        title: Text('Riwayat Perawatan', style: AppTextStyles.subtitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Nama Pasien: ${widget.patient.name}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kode Pasien: ${widget.patient.patientCode}',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _isExporting ? () {} : _exportToCsv,
                fontSize: 16,
                title: _isExporting ? 'Mengekspor...' : 'Ekspor ke CSV',
                buttonType: ButtonType.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<InfusionHistoryBloc, InfusionHistoryState>(
                builder: (context, state) {
                  if (state.status == InfusionHistoryStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == InfusionHistoryStatus.error) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodyLarge,
                      ),
                    );
                  }

                  if (state.status == InfusionHistoryStatus.success) {
                    // Store infusions for CSV export
                    _infusions = state.infusions;

                    if (state.infusions.isEmpty) {
                      return Center(
                        child: Text(
                          state.message,
                          style: AppTextStyles.bodyLarge,
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.infusions.length,
                      itemBuilder: (context, index) {
                        final infusion = state.infusions[index];

                        return _buildScheduleCard(infusion);
                      },
                    );
                  }

                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(InfusionEntity infusion) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final duration = infusion.endTime.difference(infusion.startTime);
    final isActive = infusion.status == InfusionStatusEnum.running;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppColors.greenColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppColors.greenColor.withOpacity(0.15)
                : AppColors.blackColor.withOpacity(0.06),
            blurRadius: isActive ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header dengan status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(infusion.status).withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(infusion.status),
                  color: _getStatusColor(infusion.status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infusion.infusionName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _buildStatusBadge(infusion.status),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Tanggal',
                  value: dateFormatter.format(infusion.startTime),
                ),
                const SizedBox(height: 10),
                // Time
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Waktu',
                  value:
                      '${timeFormatter.format(infusion.startTime)} - ${timeFormatter.format(infusion.endTime)}',
                ),
                const SizedBox(height: 10),
                // Duration
                _buildInfoRow(
                  icon: Icons.timer_outlined,
                  label: 'Durasi',
                  value: _formatDuration(duration),
                ),

                // Remaining time (hanya untuk active)
                if (isActive) ...[
                  const SizedBox(height: 10),
                  Builder(
                    builder: (_) {
                      final remaining = infusion.endTime.difference(
                        DateTime.now(),
                      );
                      return _buildInfoRow(
                        icon: Icons.hourglass_bottom,
                        label: 'Sisa Waktu',
                        value: remaining.isNegative
                            ? 'Waktu habis'
                            : _formatDuration(remaining),
                        valueColor: remaining.isNegative
                            ? AppColors.redColor
                            : AppColors.greenColor,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Animated pulse indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.greenColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.greenColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sedang Berjalan',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.greenColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.blackColor.withOpacity(0.4)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.blackColor.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(InfusionStatusEnum status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getStatusLabel(status),
        style: AppTextStyles.caption.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getStatusColor(InfusionStatusEnum status) {
    switch (status) {
      case InfusionStatusEnum.running:
        return AppColors.greenColor;
      case InfusionStatusEnum.completed:
        return Colors.blue;
      case InfusionStatusEnum.scheduled:
        return Colors.orange;
      case InfusionStatusEnum.stopped:
        return AppColors.redColor;
    }
  }

  IconData _getStatusIcon(InfusionStatusEnum status) {
    switch (status) {
      case InfusionStatusEnum.running:
        return Icons.play_circle_outline;
      case InfusionStatusEnum.completed:
        return Icons.check_circle_outline;
      case InfusionStatusEnum.scheduled:
        return Icons.warning_amber_rounded;
      case InfusionStatusEnum.stopped:
        return Icons.cancel_outlined;
    }
  }

  String _getStatusLabel(InfusionStatusEnum status) {
    switch (status) {
      case InfusionStatusEnum.running:
        return 'Sedang Berjalan';
      case InfusionStatusEnum.completed:
        return 'Selesai';
      case InfusionStatusEnum.scheduled:
        return 'Dijadwalkan';
      case InfusionStatusEnum.stopped:
        return 'Dihentikan';
    }
  }

  String _formatDuration(Duration duration) {
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
}
