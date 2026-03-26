import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../helper/assets/assets.gen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum DialogEnum { success, error, info, warning }

class CustomDialog {
  static bool _isShowingLoading = false;
  static BuildContext? _loadingContext;

  static void showMainDialog({
    required BuildContext context,
    required Widget child,
  }) {
    showDialog(
      context: context,
      barrierColor: AppColors.blackColor.withOpacity(0.3),
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: child,
        );
      },
    );
  }

  static void hideLoadingDialog({GlobalKey? loadingKey}) {
    if (_isShowingLoading && _loadingContext != null) {
      Navigator.of(_loadingContext!).pop();
      _isShowingLoading = false;
      _loadingContext = null;
    }
  }

  static void showLoadingDialog({
    required BuildContext context,
    GlobalKey? loadingKey,
  }) {
    if (_isShowingLoading) return;

    _isShowingLoading = true;
    _loadingContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.blackColor.withOpacity(0.3),
      builder: (dialogContext) {
        _loadingContext = dialogContext; // Update context to dialog context
        return Dialog(
          key: loadingKey,
          elevation: 1,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: AppColors.lightPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Mohon Tunggu Sebentar',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.greyColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (_isShowingLoading) {
                                Navigator.of(dialogContext).pop();
                                _isShowingLoading = false;
                                _loadingContext = null;
                              }
                            },
                            icon: Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Dialog dismissed
      _isShowingLoading = false;
      _loadingContext = null;
    });
  }

  static Future showConfirmationRemoveDialog({
    required BuildContext context,
    required String title,
    String subtitle = '',
    required String message,
    VoidCallback? onConfirmed,
  }) async {
    return showDialog(
      context: context,
      barrierColor: AppColors.blackColor.withOpacity(0.3),
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.redColor,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        Assets.svg.svgTrash.path,
                        width: 48,
                        height: 48,
                        colorFilter: ColorFilter.mode(
                          AppColors.whiteColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (subtitle.isNotEmpty) ...[
                      Text(
                        subtitle,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.greyColor),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onConfirmed != null) {
                                onConfirmed();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.redColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Hapus',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future showCustomDialog({
    required BuildContext context,
    required DialogEnum dialogType,
    required String title,
    required String message,
    VoidCallback? onPressed,
  }) async {
    String? imagePath;
    Color? bgIconColor;
    Color? iconColor;
    Color? buttonColor;
    switch (dialogType) {
      case DialogEnum.success:
        imagePath = Assets.svg.svgSuccess.path;
        bgIconColor = AppColors.greenColor;
        iconColor = AppColors.whiteColor;
        buttonColor = AppColors.greenColor;
        break;
      case DialogEnum.error:
        imagePath = Assets.svg.svgError.path;
        bgIconColor = AppColors.lightRedColor;
        iconColor = AppColors.redColor;
        buttonColor = AppColors.redColor;
        break;
      case DialogEnum.info:
        imagePath = Assets.svg.svgAlertCircle.path;
        bgIconColor = AppColors.primaryColor;
        iconColor = AppColors.whiteColor;
        buttonColor = AppColors.primaryColor;
        break;
      case DialogEnum.warning:
        imagePath = Assets.svg.svgAlertCircle.path;
        bgIconColor = AppColors.yellowColor;
        iconColor = AppColors.whiteColor;
        buttonColor = AppColors.yellowColor;
        break;
    }

    return showDialog(
      context: context,
      barrierColor: AppColors.blackColor.withOpacity(0.3),
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: bgIconColor,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        imagePath!,
                        width: 48,
                        height: 48,
                        colorFilter: ColorFilter.mode(
                          iconColor!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onPressed != null
                              ? onPressed()
                              : Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Tutup',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
