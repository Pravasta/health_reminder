import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/components/custom_button.dart';
import 'package:health_care_reminder/core/components/custom_dialog.dart';
import 'package:health_care_reminder/core/components/custom_form_widget.dart';
import 'package:health_care_reminder/core/enum/gender_enum.dart';
import 'package:health_care_reminder/core/routes/app_transition.dart';
import 'package:health_care_reminder/core/services/device_id_service.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';
import 'package:health_care_reminder/data/dto/request/create_infusion_request.dart';
import 'package:health_care_reminder/domain/entity/infusion_entity.dart';
import 'package:health_care_reminder/domain/entity/patient_entity.dart';
import 'package:health_care_reminder/presentation/bloc/infusion/infusion_bloc.dart';
import 'package:health_care_reminder/presentation/bloc/infusion_by_patient/infusion_by_patient_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/create_infusion/create_infusion_bloc.dart';
import 'treatment_history.dart';

class AddTreatmentPage extends StatefulWidget {
  const AddTreatmentPage({super.key, required this.patient});

  final PatientEntity patient;

  @override
  State<AddTreatmentPage> createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  final TextEditingController _infusionNameController = TextEditingController();
  final TextEditingController _tpmController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final _loadingKey = GlobalKey();

  bool _isFormValid = false;

  void _validateForm() {
    if (_infusionNameController.text.isNotEmpty &&
        _tpmController.text.isNotEmpty &&
        int.tryParse(_tpmController.text) != null &&
        int.tryParse(_tpmController.text)! > 0) {
      setState(() {
        _isFormValid = true;
      });
    } else {
      setState(() {
        _isFormValid = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<InfusionByPatientBloc>().getInfusionRunningByPatientId(
      patientId: widget.patient.id ?? 0,
    );
  }

  @override
  void dispose() {
    _infusionNameController.dispose();
    _tpmController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  bool _dialogShown = false;

  void _showActiveTreatmentDialog(InfusionEntity infusion) {
    if (_dialogShown) return;
    _dialogShown = true;

    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('dd MMM yyyy');
    final duration = infusion.endTime.difference(infusion.startTime);
    final remaining = infusion.endTime.difference(DateTime.now());
    final treatmentName = infusion.infusionName;

    final patientName = infusion.patientName;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.blackColor.withOpacity(0.6),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 40,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      size: 56,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Treatment Sedang Berjalan',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Patient ini sedang dalam proses treatment. Tidak bisa membuat schedule baru.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        // Patient
                        _buildDialogInfoRow(
                          icon: Icons.person,
                          label: 'Pasien',
                          value: patientName,
                        ),
                        const Divider(height: 20),

                        // Treatment
                        _buildDialogInfoRow(
                          icon: Icons.medical_services_outlined,
                          label: 'Treatment',
                          value: treatmentName,
                        ),
                        const Divider(height: 20),

                        // Date
                        _buildDialogInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Tanggal',
                          value: dateFormatter.format(infusion.startTime),
                        ),
                        const Divider(height: 20),

                        // Time range
                        _buildDialogInfoRow(
                          icon: Icons.access_time,
                          label: 'Waktu',
                          value:
                              '${timeFormatter.format(infusion.startTime)} - ${timeFormatter.format(infusion.endTime)}',
                        ),
                        const Divider(height: 20),

                        // Duration
                        _buildDialogInfoRow(
                          icon: Icons.timer_outlined,
                          label: 'Durasi',
                          value: _formatDuration(duration),
                        ),
                        const Divider(height: 20),

                        // Remaining
                        _buildDialogInfoRow(
                          icon: Icons.hourglass_bottom,
                          label: 'Sisa Waktu',
                          value: remaining.isNegative
                              ? 'Waktu habis'
                              : _formatDuration(remaining),
                          valueColor: remaining.isNegative
                              ? AppColors.redColor
                              : Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Treatment History button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop(); // Close dialog
                        final result = await AppTransition.pushTransition<bool>(
                          context,
                          TreatmentHistory(patient: widget.patient),
                        );

                        if (result == true) {
                          _dialogShown =
                              false; // Reset agar dialog bisa tampil lagi
                          // Re-check apakah masih ada infusion yang running
                          if (mounted) {
                            context
                                .read<InfusionByPatientBloc>()
                                .getInfusionRunningByPatientId(
                                  patientId: widget.patient.id ?? 0,
                                );
                          }
                        }
                      },
                      title: 'Lihat Riwayat Treatment',
                      fontSize: 16,
                      buttonType: ButtonType.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () {
                        context.read<InfusionBloc>().stopInfusion(
                          infusionId: infusion.id,
                        );
                      },
                      title: 'HENTIKAN',
                      fontSize: 16,
                      buttonType: ButtonType.danger,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Back button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Close dialog
                        Navigator.of(context).pop(); // Go back
                      },
                      title: 'Kembali',
                      fontSize: 16,
                      buttonType: ButtonType.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary.withOpacity(0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hr $minutes min';
    } else if (hours > 0) {
      return '$hours hr';
    } else if (minutes > 0 && seconds > 0) {
      return '$minutes min $seconds sec';
    } else if (minutes > 0) {
      return '$minutes min';
    } else {
      return '$seconds sec';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InfusionByPatientBloc, InfusionByPatientState>(
          listener: (context, state) {
            if (state.status == InfusionByPatientStatus.loading) {
              // Tampilkan loading jika sedang memeriksa infusion yang berjalan
              CustomDialog.showLoadingDialog(
                context: context,
                loadingKey: _loadingKey,
              );
            }

            if (state.status == InfusionByPatientStatus.success) {
              CustomDialog.hideLoadingDialog(loadingKey: _loadingKey);
              if (state.infusion != null &&
                  state.infusion!.patientId == widget.patient.id) {
                final activeInfusion = state.infusion;

                if (activeInfusion!.endTime.isAfter(DateTime.now())) {
                  _showActiveTreatmentDialog(activeInfusion);
                }
              }
            }

            if (state.status == InfusionByPatientStatus.error) {
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.error,
                title: 'Error',
                message: state.message,
              );
            }
          },
        ),
        BlocListener<InfusionBloc, InfusionState>(
          listener: (context, state) {
            if (state.status == InfusionStatus.stopped) {
              CustomDialog.hideLoadingDialog(loadingKey: _loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.success,
                title: 'Infus Dihentikan',
                message: 'Infus yang aktif telah dihentikan.',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _dialogShown = false; // Reset agar dialog bisa tampil lagi
                  // Re-check apakah masih ada infusion yang running
                  if (mounted) {
                    context
                        .read<InfusionByPatientBloc>()
                        .getInfusionRunningByPatientId(
                          patientId: widget.patient.id ?? 0,
                        );
                  }
                },
              );
            }

            if (state.status == InfusionStatus.stopping) {
              AppTransition.popTransition(
                context,
              ); // Tutup dialog aktif jika ada
              CustomDialog.showLoadingDialog(
                context: context,
                loadingKey: _loadingKey,
              );
            }

            if (state.status == InfusionStatus.stopError) {
              CustomDialog.hideLoadingDialog(loadingKey: _loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.error,
                title: 'Error',
                message: state.message,
              );
            }
          },
        ),
        BlocListener<CreateInfusionBloc, CreateInfusionState>(
          listener: (context, state) {
            if (state.status == CreateInfusionStatus.success) {
              CustomDialog.hideLoadingDialog(loadingKey: _loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.success,
                title: 'Sukses',
                message: 'Jadwal infus telah berhasil dibuat.',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous page
                },
              );
            }

            if (state.status == CreateInfusionStatus.loading) {
              CustomDialog.showLoadingDialog(
                context: context,
                loadingKey: _loadingKey,
              );
            }

            if (state.status == CreateInfusionStatus.error) {
              CustomDialog.hideLoadingDialog(loadingKey: _loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.error,
                title: 'Error',
                message: state.message,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          title: Text('Tambah Infus', style: AppTextStyles.subtitle),
          actions: [
            IconButton(
              onPressed: () async {
                final infusionPatientBloc = context
                    .read<InfusionByPatientBloc>();

                final result = await AppTransition.pushTransition<bool>(
                  context,
                  TreatmentHistory(patient: widget.patient),
                );

                if (result == true && mounted) {
                  _dialogShown = false;
                  infusionPatientBloc.getInfusionRunningByPatientId(
                    patientId: widget.patient.id ?? 0,
                  );
                }
              },
              icon: const Icon(Icons.history, color: AppColors.blackColor),
            ),
            const SizedBox(width: 8.0),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.lightToscaColor,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyColor.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Pasien',
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Nama: ${widget.patient.name}',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Kode Pasien: ${widget.patient.patientCode}',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 4.0),

                      Text(
                        'Jenis Kelamin: ${widget.patient.gender.displayName[0].toUpperCase()}${widget.patient.gender.displayName.substring(1)}',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyColor.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CustomFormWidget().buildTextFormInput(
                        label: 'Nama Infus',
                        hintText: 'e.g., Infus ABC',
                        controller: _infusionNameController,
                        onChanged: (_) => _validateForm(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      CustomFormWidget().buildTextFormInput(
                        label: 'TPM (Waktu Per Menit)',
                        hintText: 'e.g., 80',
                        keyboardType: TextInputType.number,
                        controller: _tpmController,
                        onChanged: (value) {
                          final tpm = int.tryParse(value);
                          if (tpm != null && tpm > 0) {
                            setState(() {
                              _durationController.text = (tpm).toString();
                            });
                          } else {
                            setState(() {
                              _durationController.text = '';
                            });
                          }
                          _validateForm();
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ),
                      ),
                      if (_tpmController.text.isNotEmpty) ...[
                        const SizedBox(height: 24.0),
                        CustomFormWidget().buildTextFormInput(
                          label: 'Durasi Kustom (opsional dalam menit)',
                          hintText: 'e.g., 45',
                          keyboardType: TextInputType.number,
                          controller: _durationController,
                          onChanged: (_) => _validateForm(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 16.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: AppColors.greenColor.withOpacity(0.2),
                            border: Border.all(
                              color: AppColors.greenColor.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Timer akan diatur untuk durasi yang dipilih. Pasien akan diberitahu sesuai dengan itu.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24.0),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: () async {
                            if (!_isFormValid) return;

                            final createInfusionBloc = context
                                .read<CreateInfusionBloc>();

                            final deviceId =
                                await DeviceIdService.getDeviceId();

                            final request = CreateInfusionRequest(
                              patientId: widget.patient.id ?? 0,
                              infusionName: _infusionNameController.text,
                              tpm: int.parse(_tpmController.text),
                              deviceId: deviceId,
                              customTime: _durationController.text.isNotEmpty
                                  ? int.parse(_durationController.text)
                                  : null,
                            );

                            createInfusionBloc.createInfusion(request: request);
                          },
                          title: 'Simpan Jadwal',
                          fontSize: 16,
                          buttonType: _isFormValid
                              ? ButtonType.secondary
                              : ButtonType.disable,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
