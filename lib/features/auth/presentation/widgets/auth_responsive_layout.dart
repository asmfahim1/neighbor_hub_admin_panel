import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/dimensions.dart';
import 'auth_brand_panel.dart';
import 'auth_error_banner.dart';

class AuthResponsiveLayout extends StatelessWidget {
  const AuthResponsiveLayout({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    required this.form,
    required this.switchLink,
    this.errorMessage,
    this.footerKey,
    this.formMaxWidth = 440,
  });

  final String titleKey;
  final String subtitleKey;
  final Widget form;
  final Widget switchLink;
  final String? errorMessage;
  final String? footerKey;
  final double formMaxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSplitPane = constraints.maxWidth >= Dimensions.webBreakpoint;
        if (useSplitPane) {
          return _AuthSplitPaneLayout(
            titleKey: titleKey,
            subtitleKey: subtitleKey,
            form: form,
            switchLink: switchLink,
            errorMessage: errorMessage,
            footerKey: footerKey,
            formMaxWidth: formMaxWidth,
          );
        }

        return _AuthCompactLayout(
          titleKey: titleKey,
          subtitleKey: subtitleKey,
          form: form,
          switchLink: switchLink,
          errorMessage: errorMessage,
          footerKey: footerKey,
          formMaxWidth: formMaxWidth,
          width: constraints.maxWidth,
        );
      },
    );
  }
}

class _AuthCompactLayout extends StatelessWidget {
  const _AuthCompactLayout({
    required this.titleKey,
    required this.subtitleKey,
    required this.form,
    required this.switchLink,
    required this.formMaxWidth,
    required this.width,
    this.errorMessage,
    this.footerKey,
  });

  final String titleKey;
  final String subtitleKey;
  final Widget form;
  final Widget switchLink;
  final String? errorMessage;
  final String? footerKey;
  final double formMaxWidth;
  final double width;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = width < 360 ? 16.0 : 24.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: formMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Dimensions.height(24)),
              const Center(child: AuthBrandPanel(compact: true)),
              SizedBox(height: Dimensions.height(32)),
              _AuthTitleBlock(titleKey: titleKey, subtitleKey: subtitleKey, compact: true),
              SizedBox(height: Dimensions.height(28)),
              if (errorMessage != null) AuthErrorBanner(message: errorMessage!),
              form,
              SizedBox(height: Dimensions.height(16)),
              switchLink,
              if (footerKey != null) ...[
                SizedBox(height: Dimensions.height(16)),
                _AuthFooterText(footerKey: footerKey!),
              ],
              SizedBox(height: Dimensions.height(16)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthSplitPaneLayout extends StatelessWidget {
  const _AuthSplitPaneLayout({
    required this.titleKey,
    required this.subtitleKey,
    required this.form,
    required this.switchLink,
    required this.formMaxWidth,
    this.errorMessage,
    this.footerKey,
  });

  final String titleKey;
  final String subtitleKey;
  final Widget form;
  final Widget switchLink;
  final String? errorMessage;
  final String? footerKey;
  final double formMaxWidth;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.brandNavyDark, AppColors.darkBackground]
                    : [AppColors.brandNavyLight, const Color(0xFF1E293B)],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Center(child: AuthBrandPanel()),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthTitleBlock(titleKey: titleKey, subtitleKey: subtitleKey),
                    const SizedBox(height: 28),
                    if (errorMessage != null) AuthErrorBanner(message: errorMessage!),
                    form,
                    const SizedBox(height: 16),
                    switchLink,
                    if (footerKey != null) ...[
                      const SizedBox(height: 16),
                      _AuthFooterText(footerKey: footerKey!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthTitleBlock extends StatelessWidget {
  const _AuthTitleBlock({
    required this.titleKey,
    required this.subtitleKey,
    this.compact = false,
  });

  final String titleKey;
  final String subtitleKey;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(titleKey),
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: Dimensions.font(compact ? 24 : 28),
              ),
        ),
        SizedBox(height: compact ? Dimensions.height(6) : 6),
        Text(
          context.tr(subtitleKey),
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _AuthFooterText extends StatelessWidget {
  const _AuthFooterText({required this.footerKey});

  final String footerKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr(footerKey),
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Dimensions.font(12)),
    );
  }
}
