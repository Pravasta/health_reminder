import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_care_reminder/core/enum/infusion_status_enum.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';

import '../../../../../../../../domain/entity/infusion_entity.dart';
import '../../../../../../../bloc/infusion/infusion_bloc.dart';

class DashboardLiveMonitoring extends StatefulWidget {
  const DashboardLiveMonitoring({super.key});

  @override
  State<DashboardLiveMonitoring> createState() =>
      _DashboardLiveMonitoringState();
}

class _DashboardLiveMonitoringState extends State<DashboardLiveMonitoring> {
  @override
  void initState() {
    super.initState();
    context.read<InfusionBloc>().getInfusions();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monitoring Langsung',
            style: AppTextStyles.heading.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Pembaruan waktu nyata tentang status infusi',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          BlocBuilder<InfusionBloc, InfusionState>(
            builder: (context, state) {
              if (state.status == InfusionStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.infusions.isEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: AppColors.greyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'Tidak ada infusi yang ditemukan.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: state.infusions.length,
                itemBuilder: (context, index) {
                  return _LiveMonitoringCard(infusion: state.infusions[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Live Monitoring Card ─────────────────────────────────────────────────────

class _LiveMonitoringCard extends StatefulWidget {
  final InfusionEntity infusion;
  const _LiveMonitoringCard({required this.infusion});

  @override
  State<_LiveMonitoringCard> createState() => _LiveMonitoringCardState();
}

class _LiveMonitoringCardState extends State<_LiveMonitoringCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  Duration _total = Duration.zero;

  InfusionEntity get infusion => widget.infusion;
  bool get isRunning => infusion.status == InfusionStatusEnum.running;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void didUpdateWidget(covariant _LiveMonitoringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.infusion.endTime != widget.infusion.endTime ||
        oldWidget.infusion.startTime != widget.infusion.startTime) {
      _timer?.cancel();
      _initTimer();
    }
  }

  void _initTimer() {
    _calculateDurations();
    if (isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _calculateDurations();
      });
    }
  }

  void _calculateDurations() {
    _total = infusion.endTime.difference(infusion.startTime);
    final diff = infusion.endTime.difference(DateTime.now());
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });

    if (isRunning && _remaining == Duration.zero) {
      _timer?.cancel();
      context.read<InfusionBloc>().getInfusions();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _progress {
    if (_total.inSeconds <= 0) return 1.0;
    final elapsed = _total.inSeconds - _remaining.inSeconds;
    return (elapsed / _total.inSeconds).clamp(0.0, 1.0);
  }

  String _formatRemaining(Duration d) {
    if (d == Duration.zero && !isRunning) return '00:00';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (infusion.status) {
      InfusionStatusEnum.running => AppColors.greenColor,
      InfusionStatusEnum.completed => AppColors.greyColor,
      InfusionStatusEnum.stopped => AppColors.redColor,
      InfusionStatusEnum.scheduled => AppColors.blueColor,
    };

    final statusLabel = switch (infusion.status) {
      InfusionStatusEnum.running => 'Normal',
      InfusionStatusEnum.completed => 'Selesai',
      InfusionStatusEnum.stopped => 'Dihentikan',
      InfusionStatusEnum.scheduled => 'Dijadwalkan',
    };

    final progressColor = isRunning ? AppColors.blueColor : AppColors.greyColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: isRunning
            ? Border.all(
                color: AppColors.blueColor.withOpacity(0.2),
                width: 1.5,
              )
            : Border.all(color: AppColors.greyColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar + Name + Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      infusion.patientName,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Status dot + label
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Perlakuan ──
          Text(
            'Perlakuan',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            infusion.infusionName,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // ── Remaining Time ──
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Waktu Tersisa',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatRemaining(_remaining),
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: isRunning ? AppColors.blueColor : AppColors.textSecondary,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),

          const Spacer(),

          // ── Progress Bar ──
          Row(
            children: [
              Text(
                'Progres',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                '${(_progress * 100).round()}%',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 5,
              backgroundColor: AppColors.greyColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
