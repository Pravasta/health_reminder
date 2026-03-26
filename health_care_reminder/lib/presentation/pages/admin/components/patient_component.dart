import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enum/infusion_status_enum.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entity/patient_entity.dart';
import '../../../bloc/patient_new/patient_bloc.dart';

class RunningTimerCell extends StatefulWidget {
  final PatientEntity patient;
  const RunningTimerCell({super.key, required this.patient});

  @override
  State<RunningTimerCell> createState() => RunningTimerCellState();
}

class RunningTimerCellState extends State<RunningTimerCell> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemaining();
    });
  }

  @override
  void didUpdateWidget(covariant RunningTimerCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient.endTime != widget.patient.endTime) {
      _calculateRemaining();
    }
  }

  void _calculateRemaining() {
    if (widget.patient.endTime != null) {
      final diff = widget.patient.endTime!.difference(DateTime.now());
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });

      if (_remaining == Duration.zero) {
        _timer?.cancel();
        context.read<PatientBloc>().fetchAllPatients();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: AppColors.greenColor, size: 16),
          const SizedBox(width: 6),
          Text(
            _formatDuration(_remaining),
            style: AppTextStyles.caption.copyWith(
              color: _remaining.inMinutes <= 5
                  ? AppColors.redColor
                  : AppColors.greenColor,
              fontWeight: FontWeight.bold,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          if (widget.patient.tpm != null) ...[
            const SizedBox(width: 8),
            Text(
              '(${widget.patient.tpm} TPM)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Status Badge Widget ──────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final InfusionStatusEnum status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      InfusionStatusEnum.running => (
        AppColors.greenColor.withOpacity(0.2),
        AppColors.greenColor,
        'Running',
      ),
      InfusionStatusEnum.completed => (
        AppColors.blueColor.withOpacity(0.2),
        AppColors.blueColor,
        'Completed',
      ),
      InfusionStatusEnum.stopped => (
        AppColors.redColor.withOpacity(0.2),
        AppColors.redColor,
        'Stopped',
      ),
      InfusionStatusEnum.scheduled => (
        AppColors.greyColor.withOpacity(0.2),
        AppColors.greyColor,
        'Scheduled',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
