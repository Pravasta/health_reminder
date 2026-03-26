import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/components/custom_button.dart';
import 'package:health_care_reminder/core/helper/assets/assets.gen.dart';
import 'package:health_care_reminder/core/routes/app_transition.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';
import 'package:health_care_reminder/core/utils/screen_size.dart';
import 'package:health_care_reminder/presentation/pages/admin/admin_page.dart';

import '../../../core/services/ws_event_router.dart';
import '../../bloc/activity/activity_bloc.dart';
import '../../bloc/dashboard_summary/dashboard_bloc.dart';
import '../../bloc/infusion/infusion_bloc.dart';
import '../../bloc/patient_new/patient_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.deviceId});
  final String deviceId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WsEventRouter wsEventRouter;

  @override
  void initState() {
    super.initState();
    wsEventRouter = WsEventRouter(
      dashboardBloc: context.read<DashboardBloc>(),
      infusionBloc: context.read<InfusionBloc>(),
      patientBloc: context.read<PatientBloc>(),
      activityBloc: context.read<ActivityBloc>(),
      deviceId: widget.deviceId,
      context: context,
    );

    wsEventRouter.start();
  }

  @override
  void dispose() {
    wsEventRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        mobile: _mobileView(context),
        tablet: _tabletView(context),
        desktop: _tabletView(context),
      ),
    );
  }

  Container _mobileView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          _buildLogo(56),
          const SizedBox(height: 24),

          // Title & Subtitle
          _buildTitle(),
          const SizedBox(height: 8),
          _buildSubtitle(),
          const SizedBox(height: 48),

          // CTA Button
          _buildGetStartedButton(context),
          const SizedBox(height: 40),

          // Tagline
          _buildTagline(),
        ],
      ),
    );
  }

  Container _tabletView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left — Logo
          Expanded(child: Center(child: _buildLogo(80))),
          const SizedBox(width: 48),

          // Right — Content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 40),
                _buildGetStartedButton(context),
                const SizedBox(height: 32),
                _buildTagline(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared Widgets ───────────────────────────────────────────────────────

  Widget _buildLogo(double iconSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            AppColors.lightBlueColor,
            AppColors.toscaColor,
            AppColors.greenColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.toscaColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Assets.svg.activity.svg(
        width: iconSize,
        height: iconSize,
        colorFilter: const ColorFilter.mode(
          AppColors.whiteColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Si-AMIN',
      style: AppTextStyles.heading.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Asisten kesehatan pribadi Anda',
      style: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
        fontSize: 16,
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: Responsive.view<double>(
        context: context,
        mobile: double.infinity,
        tablet: 300,
        desktop: 300,
      ),
      child: CustomButton(
        onPressed: () {
          AppTransition.pushTransition(context, const AdminPage());
        },
        title: 'Mulai',
        fontSize: 16,
        assetsPath: Assets.svg.login.path,
        buttonType: ButtonType.secondary,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Mudah. Pintar. Peduli.',
      style: AppTextStyles.caption.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}
