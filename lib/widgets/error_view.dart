// lib/widgets/error_view.dart
import 'package:flutter/material.dart';
import '../config/constants.dart';
import 'custom_button.dart';

class ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String title;

  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.title = 'Une erreur est survenue',
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.red.withOpacity(0.7),
              size: isTablet ? 80 : 60,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isTablet ? 24 : 20,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: isTablet ? 32 : 24),
              CustomButton(
                text: 'Réessayer',
                onPressed: onRetry!,
                width: isTablet ? 300 : 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateView({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: isTablet ? 100 : 80,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              message,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isTablet ? 22 : 18,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: isTablet ? 12 : 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: isTablet ? 32 : 24),
              CustomButton(
                text: actionLabel!,
                onPressed: onAction!,
                width: isTablet ? 300 : 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
