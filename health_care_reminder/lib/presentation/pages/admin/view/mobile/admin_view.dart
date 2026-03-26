import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/components/custom_dialog.dart';

import '../../../../../core/routes/app_transition.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../domain/entity/patient_entity.dart';
import '../../../../bloc/patient_new/patient_bloc.dart';
import '../../../create_patient/create_patient_page.dart';
import '../patient_mobile_view.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with WidgetsBindingObserver {
  StreamSubscription? _notifSubscription;
  GlobalKey loadingKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load patients saat pertama kali
    context.read<PatientBloc>().fetchAllPatients();
    _notifSubscription = NotificationService().onInfusionUpdated.listen((_) {
      if (mounted) {
        context.read<PatientBloc>().fetchAllPatients();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data ketika app kembali ke foreground
    // Delay sedikit agar notification handler selesai dulu update database
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<PatientBloc>().fetchAllPatients();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text('Halaman Utama', style: AppTextStyles.subtitle),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () {
              context.read<PatientBloc>().fetchAllPatients();
            },
            backgroundColor: AppColors.blueColor,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              AppTransition.pushTransition(context, const CreatePatientPage());
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        color: AppColors.lightToscaColor,
        child: BlocListener<PatientBloc, PatientState>(
          listener: (context, state) {
            if (state.status == PatientStatus.deleting) {
              CustomDialog.hideLoadingDialog(loadingKey: loadingKey);
            }

            if (state.status == PatientStatus.deleted) {
              CustomDialog.hideLoadingDialog(loadingKey: loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.success,
                title: 'Pasien Dihapus',
                message: state.message ?? 'Pasien telah berhasil dihapus.',
                onPressed: () {
                  AppTransition.popTransition(context);
                },
              );
            }

            if (state.status == PatientStatus.error) {
              CustomDialog.hideLoadingDialog(loadingKey: loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.error,
                title: 'Terjadi Kesalahan',
                message: state.message ?? 'Terjadi kesalahan.',
                onPressed: () {
                  AppTransition.popTransition(context);
                },
              );
            }
          },
          child: BlocBuilder<PatientBloc, PatientState>(
            builder: (context, state) {
              final bool isLoading = state.status == PatientStatus.loading;

              if (state.status == PatientStatus.error) {
                return Center(
                  child: Text(
                    'Terjadi Kesalahan: ${state.message}',
                    style: AppTextStyles.bodyLarge,
                  ),
                );
              }

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<PatientEntity> patients = [];
              if (state.status == PatientStatus.success) {
                patients = state.patients;
              }

              if (patients.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada pasien ditemukan.',
                    style: AppTextStyles.bodyLarge,
                  ),
                );
              }

              return PatientMobileView(patients: patients);
            },
          ),
        ),
      ),
    );
  }
}
