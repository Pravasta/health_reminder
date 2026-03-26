import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomFormWidget {
  Widget buildTextFormInput({
    String? label,
    TextEditingController? controller,
    FocusNode? focusNode, // Tambahkan parameter FocusNode
    void Function(String)? onChanged,
    String? initialValue,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    int? minLines,
    bool? enabled,
    bool? readOnly,
    String? hintText,
    Function()? customAction,
    Color? borderColor,
    Color? focusedBorderColor,
    Widget? prefixIcon,
    Widget? suffix,
    Widget? prefix,
    TextAlign? formTextAlign,
    bool? obscureText,
    EdgeInsetsGeometry? contentPadding,
    Key? key,
    Color? fillColor,
    bool isShowError = true,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              ?prefix,
              if (prefix != null) SizedBox(width: 8),
              Text(
                label,
                textAlign: TextAlign.start,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 4),
        GestureDetector(
          onTap: customAction,
          child: Stack(
            children: [
              TextFormField(
                key: key,
                enabled: enabled ?? true,
                readOnly: readOnly ?? false,
                controller: controller,
                focusNode: focusNode, // Tambahkan focusNode di sini
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                textAlign: formTextAlign ?? TextAlign.start,
                maxLines: maxLines ?? 1,
                minLines: minLines,
                obscureText: obscureText ?? false,
                initialValue: initialValue,
                onChanged: onChanged,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  focusColor: AppColors.primaryColor,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  hintText: hintText ?? 'Masukan $label',
                  prefixIcon: prefixIcon,
                  hintStyle: AppTextStyles.body.copyWith(
                    color: enabled == null || enabled
                        ? AppColors.textPrimary.withAlpha(170)
                        : AppColors.textPrimary,
                  ),
                  filled: true,
                  fillColor: fillColor ?? AppColors.lightGreyColor,
                  labelStyle: AppTextStyles.body,
                  contentPadding:
                      contentPadding ??
                      EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor ?? AppColors.lightGreyColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  // Border saat fokus
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: focusedBorderColor ?? AppColors.textSecondary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  // Border saat tidak aktif
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: borderColor ?? AppColors.lightGreyColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  // Border saat error
                  errorBorder: isShowError
                      ? OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        )
                      : OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.lightGreyColor,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),

                  // Border saat error dan fokus
                  focusedErrorBorder: isShowError
                      ? OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        )
                      : OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.textSecondary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),

                  // Disabled border
                  disabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(
                      color: AppColors.greyColor,
                      width: 1.5,
                    ),
                  ),

                  // Tambahkan properti errorStyle
                  errorStyle: isShowError
                      ? null
                      : AppTextStyles.body.copyWith(fontSize: 0),
                ),
                validator:
                    validator ??
                    (val) {
                      if (val == "") {
                        return '$label wajib diisi';
                      }
                      return null;
                    },
              ),
              suffix != null
                  ? Positioned(right: 0, top: 0, bottom: 0, child: suffix)
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
