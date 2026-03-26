import 'package:flutter/material.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';

import '../enum/app_snackbar_type.dart';
import '../helper/assets/assets.gen.dart';

class SnackBarDecoration {
  static Color iconBackgroundColor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.save:
        return AppColors.blackColor;
      case AppSnackbarType.success:
        return AppColors.greenColor;
      case AppSnackbarType.edit:
        return AppColors.blackColor;
      case AppSnackbarType.delete:
        return AppColors.redColor;
      case AppSnackbarType.warning:
        return AppColors.redColor;
    }
  }

  static String imageAsset(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.save:
        return Assets.svg.iconPencil.path;
      case AppSnackbarType.success:
        return Assets.svg.iconCompleted.path;
      case AppSnackbarType.edit:
        return Assets.svg.iconRefresh.path;
      case AppSnackbarType.delete:
        return Assets.svg.iconDelete.path;
      case AppSnackbarType.warning:
        return Assets.svg.svgAlertCircle.path;
    }
  }

  static Color iconColor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.save:
        return AppColors.blackColor;
      case AppSnackbarType.success:
        return AppColors.whiteColor;
      case AppSnackbarType.edit:
        return AppColors.blackColor;
      case AppSnackbarType.delete:
        return AppColors.whiteColor;
      case AppSnackbarType.warning:
        return AppColors.whiteColor;
    }
  }
}
