import 'package:flutter/material.dart';

/// Palette taken from the Figma design.
abstract final class AppColors {
  static const Color wood = Color(0xFF3B1E18);
  static const Color paper = Color(0xFFFFF9D6);

  // Text
  static const Color heading = Color(0xFF673E36);
  static const Color itemText = Color(0xFF000000);
  static const Color ink = Color(0xFF412600);

  // Checkboxes
  static const Color check = Color(0x87114B00);
  static const Color checkMark = Color(0xFF77D812);

  // "Add item" panel
  static const Color panel = Color(0xFF10482C);
  static const Color panelField = Color(0xFF112317);
  static const Color highlight = Color(0xFFFFCE34);

  // Buttons
  static const Color buttonBorder = Color(0xFFD5D5D5);
  static const Color accent = Color(0xFFB8FF34);
  static const Color accentBorder = Color(0xFF5CA800);
  static const Color onAccent = Color(0xFF0A3200);
  static const Color danger = Color(0xFFFF3434);
  static const Color dangerBorder = Color(0xFFAF0000);
  static const Color onDanger = Color(0xFF410000);
  static const Color addIcon = Color(0xFFFBC415);
  static const Color close = Color(0xFF860303);
  static const Color closeRing = Color(0xFFF80000);
  static const Color delete = Color(0xFFFB1519);
}
