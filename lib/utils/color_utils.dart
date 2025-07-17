import 'package:flutter/material.dart';

class ColorUtils {
  // 뽀모도로 개수에 따른 색상 반환 (빨간색 테마)
  static Color getPomodoroColor(int count) {
    if (count == 0) {
      return Colors.transparent;
    } else if (count <= 2) {
      return Colors.red.shade100;
    } else if (count <= 4) {
      return Colors.red.shade300;
    } else if (count <= 6) {
      return Colors.red.shade500;
    } else {
      return Colors.red.shade700;
    }
  }

  // 뽀모도로 개수에 따른 텍스트 색상 반환
  static Color getTextColor(int count) {
    if (count == 0) {
      return Colors.black;
    } else if (count <= 2) {
      return Colors.red.shade800;
    } else {
      return Colors.white;
    }
  }
}
