import 'package:flutter/material.dart';
import '../config/constants.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final verticalPadding = isTablet ? 20.0 : 16.0;
    final iconSize = isTablet ? 24.0 : 20.0;
    final fontSize = isTablet ? 16.0 : 14.0;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDark,
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontSize: fontSize,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: iconSize)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: verticalPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }
}
