import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/components/custom_dialog.dart';
import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';
import 'package:health_care_reminder/core/helper/app_shimmer.dart';
import 'package:health_care_reminder/core/helper/assets/assets.gen.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';
import 'package:health_care_reminder/domain/entity/patient_entity.dart';
import 'package:health_care_reminder/presentation/pages/admin/components/patient_component.dart';

import '../../../../../../bloc/patient_new/patient_bloc.dart';

class PatientDashboardView extends StatefulWidget {
  const PatientDashboardView({super.key});

  @override
  State<PatientDashboardView> createState() => _PatientDashboardViewState();
}

class _PatientDashboardViewState extends State<PatientDashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().fetchAllPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Daftar Pasien',
            style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola dan pantau semua pasien terdaftar',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Table
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state.status == PatientStatus.loading) {
                  return ListView.separated(
                    itemCount: 5,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        AppShimmer(height: 30, width: double.infinity),
                  );
                }

                if (state.status == PatientStatus.error) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan: ${state.message}',
                      style: AppTextStyles.body,
                    ),
                  );
                }

                if (state.patients.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada pasien ditemukan.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return _PatientTable(patients: state.patients);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Patient Table ────────────────────────────────────────────────────────────

class _PatientTable extends StatelessWidget {
  final List<PatientEntity> patients;
  const _PatientTable({required this.patients});

  String _formatLastTreatment(DateTime? endTime) {
    if (endTime == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(endTime);

    if (diff.inMinutes < 1) return 'Sekarang';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return '1 hari yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    if (diff.inDays < 14) return '1 minggu yang lalu';
    if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} minggu yang lalu';
    }
    return '${(diff.inDays / 30).floor()} bulan yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.greyColor.withOpacity(0.08),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.greyColor.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _headerCell('Pasien', flex: 3),
                  _headerCell('Pasien ID', flex: 2),
                  _headerCell('Jenis Kelamin', flex: 2),
                  _headerCell('Perawatan Terakhir', flex: 2),
                  _headerCell('Status', flex: 2),
                  _headerCell('Waktu Tersisa', flex: 2),
                  _headerCell('Aksi', flex: 1),
                ],
              ),
            ),

            // Table Rows
            Expanded(
              child: ListView.separated(
                itemCount: patients.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: AppColors.greyColor.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final patient = patients[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        // Patient (avatar + name)
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  patient.name,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Patient ID
                        Expanded(
                          flex: 2,
                          child: Text(
                            patient.patientCode,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Gender
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${patient.gender.name[0].toUpperCase()}${patient.gender.name.substring(1)}',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Last Treatment
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatLastTreatment(patient.endTime),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),

                        // Status
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: switch (patient.status) {
                                    InfusionStatusEnum.running =>
                                      AppColors.greenColor,
                                    InfusionStatusEnum.completed =>
                                      AppColors.greyColor,
                                    InfusionStatusEnum.stopped =>
                                      AppColors.redColor,
                                    InfusionStatusEnum.scheduled =>
                                      AppColors.blueColor,
                                    _ => Colors.transparent,
                                  },
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                switch (patient.status) {
                                  InfusionStatusEnum.running => 'Berjalan',
                                  InfusionStatusEnum.completed => 'Selesai',
                                  InfusionStatusEnum.stopped => 'Dihentikan',
                                  InfusionStatusEnum.scheduled => 'Dijadwalkan',
                                  _ => '',
                                },
                                style: AppTextStyles.body.copyWith(
                                  color: switch (patient.status) {
                                    InfusionStatusEnum.running =>
                                      AppColors.greenColor,
                                    InfusionStatusEnum.completed =>
                                      AppColors.textSecondary,
                                    InfusionStatusEnum.stopped =>
                                      AppColors.redColor,
                                    InfusionStatusEnum.scheduled =>
                                      AppColors.blueColor,
                                    _ => Colors.transparent,
                                  },
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Remaining Time
                        Expanded(
                          flex: 2,
                          child:
                              patient.status == InfusionStatusEnum.running &&
                                  patient.endTime != null
                              ? RunningTimerCell(patient: patient)
                              : Text(
                                  '-',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        ),

                        // Actions
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () {
                              CustomDialog.showConfirmationRemoveDialog(
                                context: context,
                                title: 'Konfirmasi Hapus Pasien',
                                message:
                                    'Apakah Anda yakin ingin menghapus pasien ${patient.name}? Tindakan ini tidak dapat dibatalkan.',
                                onConfirmed: () {
                                  context.read<PatientBloc>().deletePatient(
                                    patient.id ?? 0,
                                  );
                                },
                              );
                            },
                            child: Assets.svg.iconDelete.svg(
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.redColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
