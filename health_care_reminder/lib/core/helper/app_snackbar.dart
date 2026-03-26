import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';

import '../enum/app_snackbar_type.dart';
import '../utils/screen_size.dart';
import '../utils/snackbar_decoration.dart';
import 'assets/assets.gen.dart';

class AppSnackbar {
  static Future<void> showCustomSnackbar({
    required BuildContext context,
    AppSnackbarType type = AppSnackbarType.save,
    required String title,
    required String message,
    String? message2,
    String? message3,
    Function? onDismiss,
  }) async {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Responsive(
        mobile: _MobileCustomSnackbar(
          title: title,
          message1: message,
          message2: message2,
          message3: message3,
          onDismiss: () {
            overlayEntry.remove();
          },
          type: type,
        ),
        tablet: _CustomSnackbarWidget(
          title: title,
          message1: message,
          message2: message2,
          message3: message3,
          onDismiss: () {
            overlayEntry.remove();
            onDismiss?.call();
          },
          type: type,
        ),
        desktop: _CustomSnackbarWidget(
          title: title,
          message1: message,
          message2: message2,
          message3: message3,
          onDismiss: () {
            overlayEntry.remove();
            onDismiss?.call();
          },
          type: type,
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    // Future.delayed(Duration(milliseconds: 1800), () {
    //   if (overlayEntry.mounted) {
    //     overlayEntry.remove();
    //   }
    // });
  }
}

class _CustomSnackbarWidget extends StatefulWidget {
  const _CustomSnackbarWidget({
    required this.title,
    required this.message1,
    this.message2,
    this.message3,
    required this.onDismiss,
    required this.type,
  });

  final String title;
  final String message1;
  final String? message2;
  final String? message3;
  final VoidCallback onDismiss;
  final AppSnackbarType type;

  @override
  State<_CustomSnackbarWidget> createState() => __CustomSnackbarWidgetState();
}

class __CustomSnackbarWidgetState extends State<_CustomSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 300),
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset(1.0, 0.0), // Slide from right
          end: Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  final List<AppSnackbarType> _usedChecklist = [
    AppSnackbarType.save,
    AppSnackbarType.edit,
    AppSnackbarType.delete,
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 100) {
                  _dismiss();
                }
              },
              child: Container(
                width: screenWidth * 0.4,

                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.greyColor, width: 1),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            right: _usedChecklist.contains(widget.type) ? 8 : 0,
                            bottom: _usedChecklist.contains(widget.type)
                                ? 8
                                : 0,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SnackBarDecoration.iconBackgroundColor(
                                widget.type,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              SnackBarDecoration.imageAsset(widget.type),
                              width: 28,
                              height: 28,
                              colorFilter:
                                  widget.type == AppSnackbarType.success
                                  ? null
                                  : ColorFilter.mode(
                                      SnackBarDecoration.iconColor(widget.type),
                                      BlendMode.srcIn,
                                    ),
                            ),
                          ),
                        ),
                        if (_usedChecklist.contains(widget.type))
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.greenColor,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                Assets.svg.iconCompleted.path,
                                width: 12,
                                height: 12,
                                colorFilter: ColorFilter.mode(
                                  AppColors.whiteColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      width: _usedChecklist.contains(widget.type) ? 8 : 16,
                    ),
                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: widget.message1,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                              children: [
                                TextSpan(
                                  text: ' ${widget.message2 ?? ''}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${widget.message3 ?? ''}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () => _dismiss(),
                            child: Text(
                              'Tutup',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _dismiss(),
                      child: Icon(Icons.close, color: AppColors.blackColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileCustomSnackbar extends StatefulWidget {
  const _MobileCustomSnackbar({
    required this.title,
    required this.message1,
    this.message2,
    this.message3,
    required this.onDismiss,
    required this.type,
  });

  final String title;
  final String message1;
  final String? message2;
  final String? message3;
  final VoidCallback onDismiss;
  final AppSnackbarType type;

  @override
  State<_MobileCustomSnackbar> createState() => __MobileCustomSnackbarState();
}

class __MobileCustomSnackbarState extends State<_MobileCustomSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      reverseDuration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          // begin slide from top
          begin: Offset(0.0, -1.0),
          end: Offset(0.0, 0.0),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  final List<AppSnackbarType> _usedChecklist = [
    AppSnackbarType.save,
    AppSnackbarType.edit,
    AppSnackbarType.delete,
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Dismiss on horizontal swipe
                if (details.primaryVelocity! > 100) {
                  _dismiss();
                }
              },
              child: Container(
                width: double.infinity,
                // decoration: getCustomBoxDecoration(
                //   color: appColorsTheme.surface,
                //   borderRadius: BorderRadius.circular(12),
                //   border: Border.all(color: appColorsTheme.border, width: 0.5),
                // ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            right: _usedChecklist.contains(widget.type) ? 8 : 0,
                            bottom: _usedChecklist.contains(widget.type)
                                ? 8
                                : 0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SnackBarDecoration.iconBackgroundColor(
                                widget.type,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              SnackBarDecoration.imageAsset(widget.type),
                              width: 24,
                              height: 24,
                              colorFilter:
                                  widget.type == AppSnackbarType.success
                                  ? null
                                  : ColorFilter.mode(
                                      SnackBarDecoration.iconColor(widget.type),
                                      BlendMode.srcIn,
                                    ),
                            ),
                          ),
                        ),
                        if (_usedChecklist.contains(widget.type))
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.greenColor,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                Assets.svg.iconCompleted.path,
                                width: 12,
                                height: 12,
                                colorFilter: ColorFilter.mode(
                                  AppColors.whiteColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Text Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: widget.message1,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w300,
                              ),
                              children: [
                                TextSpan(
                                  text: ' ${widget.message2 ?? ''}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${widget.message3 ?? ''}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => _dismiss(),
                      child: Icon(Icons.close, color: AppColors.blackColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
