import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'package:flutter/services.dart';

class UIUtils {
  // 스낵바 표시
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
      ),
    );
  }

  // 성공 메시지 표시
  static void showSuccessMessage(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }

  // 에러 메시지 표시
  static void showErrorMessage(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }

  // 확인 다이얼로그 표시
  static Future<bool> showConfirmDialog(
    BuildContext context,
    String title,
    String content, {
    String confirmText = '확인',
    String cancelText = '취소',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // 로딩 다이얼로그 표시
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: AppConstants.defaultPadding),
            Text(message),
          ],
        ),
      ),
    );
  }

  // 로딩 다이얼로그 닫기
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // 시간 선택 다이얼로그 표시
  static Future<int?> showTimePickerDialog(
    BuildContext context,
    String title,
    int currentValue,
    int minValue,
    int maxValue,
  ) async {
    int selectedValue = currentValue;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: DropdownButton<int>(
            value: selectedValue,
            items: List.generate(maxValue - minValue + 1, (index) {
              final value = minValue + index;
              return DropdownMenuItem(value: value, child: Text('$value 분'));
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedValue = value;
                });
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedValue),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  // 카드 스타일 위젯 생성
  static Widget createCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    Color? borderColor,
    double? borderWidth,
    Color? backgroundColor,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppConstants.defaultPadding),
      padding: padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.borderRadius,
        ),
        border: borderColor != null
            ? Border.all(color: borderColor, width: borderWidth ?? 1.0)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  // 구분선 위젯 생성
  static Widget createDivider({
    double? height,
    double? thickness,
    Color? color,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin:
          margin ??
          const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Divider(height: height, thickness: thickness, color: color),
    );
  }

  // 빈 상태 위젯 생성
  static Widget createEmptyState({
    required String message,
    IconData? icon,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: AppConstants.defaultPadding),
          ],
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ],
      ),
    );
  }
}

class LockTaskUtil {
  static const MethodChannel _channel = MethodChannel('bbomodoro/locktask');

  static Future<void> startLockTask() async {
    try {
      await _channel.invokeMethod('startLockTask');
    } catch (e) {
      // ignore or handle error
    }
  }

  static Future<void> stopLockTask() async {
    try {
      await _channel.invokeMethod('stopLockTask');
    } catch (e) {
      // ignore or handle error
    }
  }
}
