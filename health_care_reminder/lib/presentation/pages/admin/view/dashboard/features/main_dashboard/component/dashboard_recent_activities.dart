import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/helper/app_shimmer.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';
import 'package:health_care_reminder/domain/entity/activity_entity.dart';
import 'package:health_care_reminder/presentation/bloc/activity/activity_bloc.dart';

class DashboardRecentActivities extends StatelessWidget {
  const DashboardRecentActivities({super.key});

  void _showAllActivitiesDialog(
    BuildContext context,
    List<ActivityEntity> activities,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.purpleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: AppColors.purpleColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Semua Aktivitas',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${activities.length} total aktivitas',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.greyColor.withOpacity(0.3)),

              // Scrollable Activity List
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final isLast = index == activities.length - 1;
                    return _ActivityTimelineItem(
                      activity: activity,
                      isLast: isLast,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.purpleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: AppColors.purpleColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivitas Terbaru',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Peristiwa infusi terbaru',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Refresh button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      context.read<ActivityBloc>().fetchRecentActivities();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.greyColor.withOpacity(0.3)),

          // Content
          BlocBuilder<ActivityBloc, ActivityState>(
            builder: (context, state) {
              if (state is ActivityLoading) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            AppShimmer(height: 40, width: 40),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppShimmer(height: 14, width: 200),
                                  const SizedBox(height: 6),
                                  AppShimmer(height: 10, width: 100),
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

              if (state is ActivityError) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.redColor,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ActivityLoaded) {
                if (state.activities.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            color: AppColors.greyColor,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada aktivitas terbaru',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                const maxVisible = 5;
                final allActivities = state.activities;
                final visibleActivities = allActivities.length > maxVisible
                    ? allActivities.sublist(0, maxVisible)
                    : allActivities;
                final hasMore = allActivities.length > maxVisible;

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      itemCount: visibleActivities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final activity = visibleActivities[index];
                        final isLast =
                            index == visibleActivities.length - 1 && !hasMore;
                        return _ActivityTimelineItem(
                          activity: activity,
                          isLast: isLast,
                        );
                      },
                    ),
                    if (hasMore) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showAllActivitiesDialog(
                              context,
                              allActivities,
                            ),
                            icon: const Icon(
                              Icons.expand_more_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Lihat Semua (${allActivities.length})',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.purpleColor,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.purpleColor,
                              side: BorderSide(
                                color: AppColors.purpleColor.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

// ─── Timeline Item ────────────────────────────────────────────────────────────

class _ActivityTimelineItem extends StatelessWidget {
  final ActivityEntity activity;
  final bool isLast;

  const _ActivityTimelineItem({required this.activity, required this.isLast});

  _ActivityStyle get _style {
    switch (activity.type) {
      case 'infusion_created':
        return _ActivityStyle(
          icon: Icons.play_circle_outline_rounded,
          color: AppColors.greenColor,
          bgColor: AppColors.greenColor.withOpacity(0.1),
          label: 'Infus Dimulai',
        );
      case 'infusion_completed':
        return _ActivityStyle(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.blueColor,
          bgColor: AppColors.blueColor.withOpacity(0.1),
          label: 'Infus Selesai',
        );
      case 'infusion_stopped':
        return _ActivityStyle(
          icon: Icons.stop_circle_outlined,
          color: AppColors.redColor,
          bgColor: AppColors.redColor.withOpacity(0.1),
          label: 'Infus Dihentikan',
        );
      case 'patient_created':
        return _ActivityStyle(
          icon: Icons.person_add_alt_1_rounded,
          color: AppColors.purpleColor,
          bgColor: AppColors.purpleColor.withOpacity(0.1),
          label: 'Pasien Baru',
        );
      case 'patient_deleted':
        return _ActivityStyle(
          icon: Icons.person_remove_alt_1_rounded,
          color: AppColors.redColor,
          bgColor: AppColors.redColor.withOpacity(0.1),
          label: 'Pasien Dihapus',
        );
      default:
        return _ActivityStyle(
          icon: Icons.info_outline_rounded,
          color: AppColors.textSecondary,
          bgColor: AppColors.greyColor.withOpacity(0.2),
          label: 'Aktivitas Lain',
        );
    }
  }

  String _formatTimeAgo(DateTime createdAt) {
    final now = DateTime.now().toUtc();
    final utcCreated = createdAt.isUtc ? createdAt : createdAt.toUtc();
    final diff = now.difference(utcCreated);

    if (diff.inSeconds < 60) return 'Sekarang';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m yang lalu';
    if (diff.inHours < 24) return '${diff.inHours}h yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays}d yang lalu';
    return '${(diff.inDays / 7).floor()}w yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail (dot + line)
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: style.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(style.icon, color: style.color, size: 18),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.greyColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: style.bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          style.label,
                          style: AppTextStyles.caption.copyWith(
                            color: style.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(activity.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity.message,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Style Helper ─────────────────────────────────────────────────────────────

class _ActivityStyle {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String label;

  const _ActivityStyle({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.label,
  });
}
