import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/components/custom_button.dart';
import 'package:health_care_reminder/core/components/custom_dialog.dart';
import 'package:health_care_reminder/core/components/custom_dropdown.dart';
import 'package:health_care_reminder/core/components/custom_form_widget.dart';
import 'package:health_care_reminder/core/enum/gender_enum.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';
import 'package:health_care_reminder/core/utils/validators.dart';
import 'package:health_care_reminder/data/dto/request/create_patient_request.dart';
import 'package:health_care_reminder/presentation/bloc/create_patient/create_patient_bloc.dart';
import 'package:health_care_reminder/presentation/bloc/patient_new/patient_bloc.dart';

class CreatePatientPage extends StatefulWidget {
  const CreatePatientPage({super.key});

  @override
  State<CreatePatientPage> createState() => _CreatePatientPageState();
}

class _CreatePatientPageState extends State<CreatePatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _loadingKey = GlobalKey();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _patientCodeController = TextEditingController();
  Gender? value;

  @override
  void dispose() {
    _nameController.dispose();
    _patientCodeController.dispose();
    super.dispose();
  }

  bool _isFormValid = false;

  void _validateForm() {
    if (_nameController.text.isNotEmpty &&
        _patientCodeController.text.isNotEmpty &&
        value != null) {
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
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreatePatientBloc, CreatePatientState>(
          listener: (context, stateCreate) {
            if (stateCreate.status == CreatePatientStatus.success) {
              CustomDialog.hideLoadingDialog(loadingKey: _loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.success,
                title: 'Sukses',
                message: 'Patient berhasil ditambahkan',
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to previous page
                  context.read<PatientBloc>().fetchAllPatients();
                },
              );
            }

            if (stateCreate.status == CreatePatientStatus.error) {
              CustomDialog.hideLoadingDialog(loadingKey: _loadingKey);
              CustomDialog.showCustomDialog(
                context: context,
                dialogType: DialogEnum.error,
                title: 'Error',
                message: stateCreate.message,
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              );
            }

            if (stateCreate.status == CreatePatientStatus.loading) {
              CustomDialog.showLoadingDialog(
                context: context,
                loadingKey: _loadingKey,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Tambah Pasien Baru', style: AppTextStyles.subtitle),
          backgroundColor: AppColors.whiteColor,
          elevation: 1,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.lightToscaColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFormWidget().buildTextFormInput(
                      label: 'Nama Pasien',
                      hintText: 'Masukkan nama pasien',
                      controller: _nameController,
                      validator: Validators.validateName,
                      onChanged: (_) => _validateForm(),
                    ),
                    const SizedBox(height: 16),
                    CustomFormWidget().buildTextFormInput(
                      hintText: 'e.g., P001',
                      label: 'Kode Pasien',
                      controller: _patientCodeController,
                      validator: Validators.validateText,
                      onChanged: (_) => _validateForm(),
                    ),
                    const SizedBox(height: 16),
                    CustomDropdown().buildDropdown(
                      label: 'Pilih Jenis Kelamin',
                      hint: 'Pilih Jenis Kelamin',
                      value: value,
                      items: Gender.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.displayName[0].toUpperCase() +
                                    e.displayName.substring(1),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (Gender? newValue) {
                        setState(() {
                          value = newValue;
                        });
                        _validateForm();
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () {
                          if (!_isFormValid) return;

                          if (_formKey.currentState!.validate()) {
                            // Save patient logic here
                            final data = CreatePatientRequest(
                              name: _nameController.text.trim(),
                              patientCode: _patientCodeController.text.trim(),
                              gender: value!,
                            );

                            context.read<CreatePatientBloc>().createPatient(
                              data,
                            );
                          }
                        },
                        title: 'Simpan Pasien',
                        fontSize: 16,
                        buttonType: _isFormValid
                            ? ButtonType.primary
                            : ButtonType.disable,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
