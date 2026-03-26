import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get bold => GoogleFonts.poppins(fontWeight: FontWeight.bold);
  static TextStyle get caption =>
      GoogleFonts.poppins().copyWith(fontSize: 12, color: AppColors.blackColor);

  static TextStyle get body =>
      GoogleFonts.poppins().copyWith(fontSize: 14, color: AppColors.blackColor);

  static TextStyle get bodyLarge =>
      GoogleFonts.poppins().copyWith(fontSize: 16, color: AppColors.blackColor);

  static TextStyle get subtitle =>
      GoogleFonts.poppins().copyWith(fontSize: 18, color: AppColors.blackColor);

  static TextStyle get title =>
      GoogleFonts.poppins().copyWith(fontSize: 20, color: AppColors.blackColor);

  static TextStyle get heading =>
      GoogleFonts.poppins().copyWith(fontSize: 24, color: AppColors.blackColor);
}
