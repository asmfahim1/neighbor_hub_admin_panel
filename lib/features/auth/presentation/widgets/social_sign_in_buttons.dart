import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/dimensions.dart';

/// Google + Apple sign-in buttons. Stateless — purely presentational,
/// callbacks dispatch the bloc events from the parent.
class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
    this.isEnabled = true,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          leading: const _GoogleMark(),
          label: context.tr('auth_continue_google'),
          onPressed: isEnabled ? onGooglePressed : null,
        ),
        SizedBox(height: Dimensions.height(12)),
        _SocialButton(
          leading: const Icon(Icons.apple, size: 22),
          label: context.tr('auth_continue_apple'),
          onPressed: isEnabled ? onApplePressed : null,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.leading, required this.label, required this.onPressed});

  final Widget leading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.height(48),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: leading,
        label: Text(label),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radius(12))),
        ),
      ),
    );
  }
}

/// A simple "G" mark substitute — no official Google brand asset is bundled
/// in this project, so a neutral colored badge is used instead of the real
/// logo (avoids shipping an unlicensed asset).
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: Text(
        'G',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4285F4)),
      ),
    );
  }
}
