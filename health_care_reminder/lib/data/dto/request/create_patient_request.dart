import 'package:health_care_reminder/core/utils/enum_mapper.dart';

import '../../../core/enum/gender_enum.dart';

/// [CreatePatientRequest] A data transfer object for creating a new patient.
/// This class encapsulates the necessary information required to create a patient record.
class CreatePatientRequest {
  final String name;
  final String patientCode;

  final Gender gender;

  CreatePatientRequest({
    required this.name,
    required this.patientCode,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'code': patientCode, 'gender': enumToDb(gender)};
  }
}
