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
    Key? key,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
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
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
      ),
    );
  }
}