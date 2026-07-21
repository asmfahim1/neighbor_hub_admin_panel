import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/dimensions.dart';

/// Inline failure message shown above the sign-in form — covers both a
/// regular sign-in failure and the "blocked non-admin account" case (the
/// bloc collapses both into `AuthStatus.failure`, so both render here; see
/// `auth_plan.md`'s UI Design Plan for why there's no separate blocked screen).
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: Dimensions.paddingOnly(bottom: 16),
      padding: Dimensions.paddingSymmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radius(12)),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: Dimensions.icon(20)),
          SizedBox(width: Dimensions.width(10)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.error, fontSize: Dimensions.font(13)),
            ),
          ),
        ],
      ),
    );
  }
}
