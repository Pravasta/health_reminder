import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadow {
  static List<BoxShadow> getCustomBoxShadow({
    List<Color>? colors,
    List<Offset>? offsets,
    List<double>? blurRadius,
  }) {
    int length = offsets?.length ?? 0;

    // Pastikan semua list memiliki panjang yang sama
    if (offsets != null && offsets.length != length) {
      throw ArgumentError("Panjang list offsets harus sama dengan colors");
    }
    if (blurRadius != null && blurRadius.length != length) {
      throw ArgumentError("Panjang list blurRadius harus sama dengan colors");
    }

    List<BoxShadow> boxShadows = [];
    for (int i = 0; i < length; i++) {
      boxShadows.add(
        BoxShadow(
          color: colors?[i] ?? AppColors.blackColor.withOpacity(0.1),
          offset: offsets?[i] ?? const Offset(0, 4),
          blurRadius: blurRadius?[i] ?? 10,
        ),
      );
    }

    return boxShadows;
  }
}
