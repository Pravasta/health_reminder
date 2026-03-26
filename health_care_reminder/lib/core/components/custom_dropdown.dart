import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomDropdown {
  Widget buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
    String? label,
    Widget? prefixIcon,
    bool enabled = true,
    String? errorText,
    EdgeInsetsGeometry? contentPadding,
    Color? borderColor,
    Color? focusedBorderColor,
    Color? fillColor,
    double borderRadius = 8.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.greyColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: enabled ? onChanged : null,
            hint: hint != null
                ? Text(
                    hint,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor ?? AppColors.lightGreyColor,
              contentPadding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: prefixIcon,
              errorText: errorText,
              errorStyle: AppTextStyles.caption.copyWith(
                color: AppColors.redColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ?? AppColors.lightGreyColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ?? AppColors.lightGreyColor,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: focusedBorderColor ?? AppColors.greyColor,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(
                  color: AppColors.redColor,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(
                  color: AppColors.redColor,
                  width: 2.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: AppColors.greyColor.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
            ),
            style: AppTextStyles.body.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            dropdownColor: AppColors.whiteColor,

            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
              size: 24,
            ),
            elevation: 8,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ],
    );
  }

  // Helper method untuk membuat DropdownMenuItem dengan styling yang konsisten
  static DropdownMenuItem<T> buildMenuItem<T>({
    required T value,
    required String text,
    Widget? leading,
    Widget? trailing,
    bool enabled = true,
  }) {
    return DropdownMenuItem<T>(
      value: value,
      enabled: enabled,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 12)],
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.body.copyWith(
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
          ],
        ),
      ),
    );
  }
}
