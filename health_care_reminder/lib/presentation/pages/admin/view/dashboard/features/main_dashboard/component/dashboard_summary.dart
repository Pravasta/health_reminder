import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:health_care_reminder/core/helper/app_shimmer.dart';
import 'package:health_care_reminder/core/helper/assets/assets.gen.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';

import '../../../../../../../bloc/dashboard_summary/dashboard_bloc.dart';

class DashboardSummary extends StatefulWidget {
  const DashboardSummary({super.key});

  @override
  State<DashboardSummary> createState() => _DashboardSummaryState();
}

class _DashboardSummaryState extends State<DashboardSummary> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().fetchDashboardSummary();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final bool isLoading = state is DashboardLoading;

        if (state is DashboardError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Gagal memuat data dashboard',
              style: AppTextStyles.body.copyWith(color: AppColors.redColor),
            ),
          );
        }

        final dashboardData = state is DashboardSuccess ? state.summary : null;

        return Row(
          children: [
            Expanded(
              child: _DashboardSummaryItem(
                Assets.svg.user.path,
                'Total Pasien',
                dashboardData != null
                    ? dashboardData.totalPatients.toString()
                    : '0',
                'Jumlah pasien terdaftar',
                AppColors.blueColor,
                isLoading,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DashboardSummaryItem(
                Assets.svg.activity.path,
                'Infusi Aktif',
                dashboardData != null
                    ? dashboardData.activeInfusions.toString()
                    : '0',
                'Sedang berlangsung',
                AppColors.greenColor,
                isLoading,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DashboardSummaryItem(
                Assets.svg.svgAlertCircle.path,
                'Infusi Akan Berakhir Segera',
                dashboardData != null
                    ? dashboardData.endingInfusions.toString()
                    : '0',
                'Dalam 5 menit ke depan',
                AppColors.redColor,
                isLoading,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DashboardSummaryItem(
                Assets.svg.userConfig.path,
                'Infusi Selesai',
                dashboardData != null
                    ? dashboardData.completedInfusions.toString()
                    : '0',
                'Total infusi yang selesai',
                AppColors.greenColor,
                isLoading,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardSummaryItem extends StatelessWidget {
  const _DashboardSummaryItem(
    this.iconAssets,
    this.title,
    this.value,
    this.description,
    this.backgroundColor,
    this.isLoading,
  );

  final String iconAssets;
  final String title;
  final String value;
  final String description;
  final Color backgroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              iconAssets,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.whiteColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 12),
          isLoading
              ? AppShimmer(height: 24, width: 80)
              : Text(
                  value,
                  style: AppTextStyles.heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
