import 'package:flutter/material.dart';
import '../config/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final btnHeight = height ?? (isTablet ? 62.0 : AppSizes.buttonHeight);
    final iconSize = isTablet ? 24.0 : 20.0;
    final fontSize = isTablet ? 18.0 : 16.0;

    return SizedBox(
      width: width ?? double.infinity,
      height: btnHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryBlue,
          foregroundColor: textColor ?? AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: isTablet ? 28.0 : 24.0,
                height: isTablet ? 28.0 : 24.0,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(fontSize: fontSize),
                  ),
                ],
              ),
      ),
    );
  }
}
