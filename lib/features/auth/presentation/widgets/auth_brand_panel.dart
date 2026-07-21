import 'package:flutter/material.dart';

import '../../../../core/common_widgets/svg_icon.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/dimensions.dart';

/// Logo + app name (+ tagline, when [compact] is false) — reused as the
/// mobile header and the web split-pane's left panel. Stateless: purely
/// presentational, no bloc/controller involvement.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key, this.compact = false});

  /// `true` on mobile (small mark, no tagline, theme-colored text).
  /// `false` on web's left panel (larger mark, tagline, white text over the
  /// brand gradient).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final nameColor = compact ? null : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgIcon(AppAssets.logoMark, size: Dimensions.icon(compact ? 56 : 88)),
        SizedBox(height: Dimensions.height(compact ? 12 : 20)),
        Text(
          context.tr('auth_app_name'),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: Dimensions.font(compact ? 22 : 30),
                color: nameColor,
              ),
        ),
        if (!compact) ...[
          SizedBox(height: Dimensions.height(8)),
          Text(
            context.tr('auth_brand_tagline'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: Dimensions.font(15)),
          ),
        ],
      ],
    );
  }
}
