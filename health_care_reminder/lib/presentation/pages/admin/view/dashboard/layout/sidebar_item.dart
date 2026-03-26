import 'package:flutter/material.dart';
import 'package:health_care_reminder/core/helper/assets/assets.gen.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isCollapsed;
  final bool isSelected;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isCollapsed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.blueColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            icon,
            color: isSelected ? AppColors.whiteColor : AppColors.textPrimary,
          ),

          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? AppColors.whiteColor
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class SidebarLogo extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  final String subtitle;

  const SidebarLogo({
    super.key,
    required this.title,
    required this.isCollapsed,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.whiteColor,
                BlendMode.srcIn,
              ),
            ),
          ),

          if (!isCollapsed) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
