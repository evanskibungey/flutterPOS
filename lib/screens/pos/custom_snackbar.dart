import 'package:flutter/material.dart';
import 'package:pos_app/theme/app_theme.dart'; // Import the AppTheme

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isSuccess = true, // Default is success if not error
    bool isInfo = false,
    bool isWarning = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    // Determine the icon and color based on the type
    IconData icon;
    Color backgroundColor;
    
    if (isError) {
      icon = Icons.error_outline;
      backgroundColor = AppColors.errorColor;
    } else if (isWarning) {
      icon = Icons.warning_amber_outlined;
      backgroundColor = AppColors.warningColor;
    } else if (isInfo) {
      icon = Icons.info_outline;
      backgroundColor = AppColors.infoColor;
    } else {
      // Default is success
      icon = Icons.check_circle_outline;
      backgroundColor = AppColors.successColor;
    }
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(16),
      elevation: 4,
    );
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // Helper methods for specific types of snackbars
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      isError: false,
      isSuccess: true,
      isInfo: false,
      isWarning: false,
      duration: duration,
      action: action,
    );
  }
  
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      isError: true,
      isSuccess: false,
      isInfo: false,
      isWarning: false,
      duration: duration,
      action: action,
    );
  }
  
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      isError: false,
      isSuccess: false,
      isInfo: true,
      isWarning: false,
      duration: duration,
      action: action,
    );
  }
  
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      isError: false,
      isSuccess: false,
      isInfo: false,
      isWarning: true,
      duration: duration,
      action: action,
    );
  }
}