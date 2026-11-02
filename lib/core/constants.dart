import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1E40AF);
  static const success = Color(0xFF047857);
  static const warning = Color(0xFFB45309);
  static const error = Color(0xFFB91C1C);
  static const bg = Color(0xFFF4F6FA);
  static const textMain = Color(0xFF0F1B33);
  static const textSec = Color(0xFF5B6478);
  static const border = Color(0xFFE5E7EB);
}

/// Warna sesuai persentase kehadiran (0.0 - 1.0).
Color pctColor(double p) {
  if (p >= 0.75) return AppColors.success;
  if (p >= 0.5) return AppColors.warning;
  return AppColors.error;
}
