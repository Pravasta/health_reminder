import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonType { disable, danger, primary, primaryGradient, secondary }

extension ButtonTypeExtension on ButtonType {
  Color get buttonColor {
    switch (this) {
      case ButtonType.disable:
        return AppColors.greyColor;
      case ButtonType.danger:
        return AppColors.redColor;
      case ButtonType.primary:
        return AppColors.primaryColor;
      case ButtonType.primaryGradient:
        return AppColors
            .primaryColor; // Gradient handling can be added separately
      case ButtonType.secondary:
        return AppColors.secondaryColor;
    }
  }

  Color get textColor {
    switch (this) {
      case ButtonType.disable:
        return AppColors.textPrimary;
      case ButtonType.danger:
        return AppColors.whiteColor;
      case ButtonType.primary:
        return AppColors.whiteColor;
      case ButtonType.primaryGradient:
        return AppColors.whiteColor;
      case ButtonType.secondary:
        return AppColors.whiteColor;
    }
  }

  Color get borderColor {
    switch (this) {
      case ButtonType.disable:
        return AppColors.greyColor;
      case ButtonType.danger:
        return AppColors.redColor;
      case ButtonType.primary:
        return AppColors.primaryColor;
      case ButtonType.primaryGradient:
        return AppColors.primaryColor;
      case ButtonType.secondary:
        return AppColors.secondaryColor;
    }
  }

  Color get iconColor {
    switch (this) {
      case ButtonType.disable:
        return AppColors.textPrimary;
      case ButtonType.danger:
        return AppColors.whiteColor;
      case ButtonType.primary:
        return AppColors.whiteColor;
      case ButtonType.primaryGradient:
        return AppColors.whiteColor;
      case ButtonType.secondary:
        return AppColors.whiteColor;
    }
  }
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.buttonType,
    this.fontSize = 12,
    this.assetsPath,
    this.contentPadding = const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 24,
    ),
  });

  final VoidCallback onPressed;
  final String title;
  final ButtonType buttonType;
  final String? assetsPath;
  final double fontSize;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonType.buttonColor,
        foregroundColor: buttonType.textColor,
        backgroundBuilder: (_, _, child) {
          if (buttonType == ButtonType.primaryGradient) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            );
          }
          return child!;
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: buttonType.borderColor),
        padding: contentPadding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // center
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (assetsPath != null) ...[
            SvgPicture.asset(
              assetsPath!,
              width: fontSize + 4,
              height: fontSize + 4,
              colorFilter: ColorFilter.mode(
                buttonType.iconColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: buttonType.textColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
