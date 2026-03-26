import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care_reminder/presentation/bloc/infusion/infusion_bloc.dart';
import 'package:health_care_reminder/presentation/pages/home/home_page.dart';

import 'core/injection/env.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/activity/activity_bloc.dart';
import 'presentation/bloc/create_infusion/create_infusion_bloc.dart';
import 'presentation/bloc/create_patient/create_patient_bloc.dart';
import 'presentation/bloc/dashboard_summary/dashboard_bloc.dart';
import 'presentation/bloc/infusion_by_patient/infusion_by_patient_bloc.dart';
import 'presentation/bloc/infusion_history/infusion_history_bloc.dart';
import 'presentation/bloc/patient_new/patient_bloc.dart';

Environment get appEnvironment {
  final envString = dotenv.env['APP_ENV'] ?? 'development';
  return Environment.values.firstWhere(
    (e) => e.value == envString,
    orElse: () => Environment.development,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.deviceId});

  final String deviceId;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PatientBloc>(create: (_) => PatientBloc()),
        BlocProvider<InfusionBloc>(create: (_) => InfusionBloc()),

        BlocProvider<DashboardBloc>(create: (_) => DashboardBloc()),
        BlocProvider<ActivityBloc>(
          create: (_) => ActivityBloc()..fetchRecentActivities(),
        ),
        BlocProvider<CreatePatientBloc>(create: (_) => CreatePatientBloc()),
        BlocProvider<CreateInfusionBloc>(create: (_) => CreateInfusionBloc()),
        BlocProvider<InfusionByPatientBloc>(
          create: (_) => InfusionByPatientBloc(),
        ),
        BlocProvider<InfusionHistoryBloc>(create: (_) => InfusionHistoryBloc()),
      ],
      child: MaterialApp(
        title: 'Si-AMIN',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: HomePage(deviceId: deviceId),
      ),
    );
  }
}
