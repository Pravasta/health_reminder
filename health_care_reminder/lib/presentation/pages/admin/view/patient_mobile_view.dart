import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/components/custom_dialog.dart';
import 'package:health_care_reminder/core/helper/assets/assets.gen.dart';

import '../../../../core/enum/infusion_status_enum.dart';
import '../../../../core/routes/app_transition.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entity/patient_entity.dart';
import '../../../bloc/patient_new/patient_bloc.dart';
import '../../treatment/add_treatment_page.dart';
import '../components/patient_component.dart';

class PatientMobileView extends StatelessWidget {
  const PatientMobileView({super.key, required this.patients});

  final List<PatientEntity> patients;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        final isRunning = patient.status == InfusionStatusEnum.running;

        if (isRunning) {
          return _RunningPatientCard(patient: patient);
        }

        return _DefaultPatientCard(patient: patient);
      },
    );
  }
}

// ─── Default Card (non-running) ───────────────────────────────────────────────

class _DefaultPatientCard extends StatelessWidget {
  final PatientEntity patient;
  const _DefaultPatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppTransition.pushTransition(
          context,
          AddTreatmentPage(patient: patient),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          color: AppColors.whiteColor,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Code Pasien: ${patient.patientCode}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (patient.status != null)
                  StatusBadge(status: patient.status!),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      Text('Nama: ${patient.name}', style: AppTextStyles.body),
                      const SizedBox(height: 4.0),
                      Text(
                        'Jenis Kelamin: ${patient.gender.name[0].toUpperCase()}${patient.gender.name.substring(1)}',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    CustomDialog.showConfirmationRemoveDialog(
                      context: context,
                      title: 'Hapus Pasien',
                      message: 'Apakah Anda yakin ingin menghapus pasien ini?',
                      onConfirmed: () {
                        context.read<PatientBloc>().deletePatient(
                          patient.id ?? 0,
                        );
                      },
                    );
                  },
                  child: Assets.svg.svgTrash.svg(
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      AppColors.redColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Running Card with Live Timer ─────────────────────────────────────────────

class _RunningPatientCard extends StatefulWidget {
  final PatientEntity patient;
  const _RunningPatientCard({required this.patient});

  @override
  State<_RunningPatientCard> createState() => _RunningPatientCardState();
}

class _RunningPatientCardState extends State<_RunningPatientCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  @override
  void didUpdateWidget(covariant _RunningPatientCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate jika endTime berubah (misal data di-refresh)
    if (oldWidget.patient.endTime != widget.patient.endTime) {
      _calculateRemaining();
    }
  }

  void _calculateRemaining() {
    if (widget.patient.endTime != null) {
      final diff = widget.patient.endTime!.difference(DateTime.now());
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });

      if (_remaining == Duration.zero) {
        _timer?.cancel();
        context
            .read<PatientBloc>()
            .fetchAllPatients(); // Refresh data saat infus selesai
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return GestureDetector(
      onTap: () {
        AppTransition.pushTransition(
          context,
          AddTreatmentPage(patient: patient),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppColors.greenColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.greenColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          color: AppColors.whiteColor,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kode Pasien: ${patient.patientCode}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(status: InfusionStatusEnum.running),
              ],
            ),
            const SizedBox(height: 8.0),
            Text('Nama: ${patient.name}', style: AppTextStyles.body),
            const SizedBox(height: 4.0),
            Text(
              'Jenis Kelamin: ${patient.gender.name[0].toUpperCase()}${patient.gender.name.substring(1)}',
              style: AppTextStyles.body,
            ),

            // Timer section
            const SizedBox(height: 12.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.greenColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: AppColors.greenColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    'Sisa Durasi:',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    _formatDuration(_remaining),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: _remaining.inMinutes <= 5
                          ? AppColors.redColor
                          : AppColors.greenColor,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const Spacer(),
                  if (patient.tpm != null)
                    Text(
                      '${patient.tpm} TPM',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
