import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ValeonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;

  const ValeonTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(color: AppTheme.onBackground),
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.onSurface),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppTheme.onSurface) : null,
      suffixIcon: suffixIcon,
    ),
  );
}
