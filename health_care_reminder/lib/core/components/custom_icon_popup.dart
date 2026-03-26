import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomIconPopup<T> extends StatefulWidget {
  const CustomIconPopup({
    super.key,
    required this.iconSize,
    this.onMenuSelected,
    this.menuItems,
    this.iconPadding,
    this.assetsItems,
    this.color,
    this.icon,
  });

  final double iconSize;
  final List<Function?>? onMenuSelected;
  final List<String>? menuItems;
  final double? iconPadding;
  final List<String>? assetsItems;
  final List<Color>? color;
  final Widget? icon;

  @override
  State<CustomIconPopup> createState() => _CustomIconPopupState();
}

class _CustomIconPopupState<T> extends State<CustomIconPopup<T>> {
  @override
  Widget build(BuildContext context) {
    final menuItems = <PopupMenuEntry<int>>[];

    // create menu items from list of string
    if (widget.menuItems != null) {
      for (var i = 0; i < widget.menuItems!.length; i++) {
        menuItems.add(
          PopupMenuItem<int>(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            value: i + 1,
            child: Row(
              children: [
                if (widget.assetsItems != null &&
                    widget.assetsItems!.length >= i + 1) ...[
                  SvgPicture.asset(
                    widget.assetsItems![i],
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      widget.color != null && widget.color!.length >= i + 1
                          ? widget.color![i]
                          : AppColors.blackColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
                Text(
                  widget.menuItems![i],
                  style: AppTextStyles.caption.copyWith(
                    color: widget.color != null && widget.color!.length >= i + 1
                        ? widget.color![i]
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return PopupMenuButton<int>(
      padding: EdgeInsets.zero,

      position: PopupMenuPosition.under,
      itemBuilder: (context) => menuItems,
      onSelected: (value) {
        if (widget.onMenuSelected != null &&
            widget.onMenuSelected!.length >= value) {
          final action = widget.onMenuSelected![value - 1];
          if (action != null) {
            action();
          }
        }
      },
      child: SizedBox(child: widget.icon),
    );
  }
}
