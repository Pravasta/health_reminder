import 'package:flutter/material.dart';
import 'package:health_care_reminder/core/theme/app_colors.dart';
import 'package:health_care_reminder/core/theme/app_text_styles.dart';
import 'sidebar_item.dart';

class Sidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          const SizedBox(height: 20),
          SidebarLogo(
            title: 'Si-AMIN',
            isCollapsed: isCollapsed,
            subtitle: 'Admin Panel',
          ),

          const Divider(height: 1, color: AppColors.greyColor),
          const SizedBox(height: 12),

          Column(
            children: _SiderBarItem.items
                .asMap()
                .entries
                .map(
                  (entry) => InkWell(
                    onTap: () => onItemSelected(entry.key),
                    child: SidebarItem(
                      icon: entry.value.icon,
                      title: entry.value.title,
                      isCollapsed: isCollapsed,
                      isSelected: entry.key == selectedIndex,
                    ),
                  ),
                )
                .toList(),
          ),

          const Spacer(),

          isCollapsed
              ? IconButton(icon: const Icon(Icons.menu), onPressed: onToggle)
              : Center(
                  child: Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onToggle,
                      ),
                      const SizedBox(width: 12),
                      Text("Tutup", style: AppTextStyles.body),
                      const Spacer(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class _SiderBarItem {
  final IconData icon;
  final String title;
  final bool isCollapsed;
  final bool isSelected;

  static List<_SiderBarItem> items = [
    _SiderBarItem(
      icon: Icons.dashboard,
      title: "Dashboard",
      isCollapsed: false,
      isSelected: false,
    ),
    _SiderBarItem(
      icon: Icons.people,
      title: "Daftar Pasien",
      isCollapsed: false,
      isSelected: false,
    ),
  ];

  _SiderBarItem({
    required this.icon,
    required this.title,
    required this.isCollapsed,
    required this.isSelected,
  });
}
