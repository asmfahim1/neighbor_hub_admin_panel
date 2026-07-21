import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/common_loader.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/sign_in_form.dart';

/// Sign-in screen — responsive: single-column on mobile, split-pane on web
/// (`Dimensions.isWeb`). See `auth_plan.md`'s UI Design Plan for the full
/// design rationale. Stateless: rendering is entirely driven by `AuthBloc`.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard,
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case AuthStatus.unknown:
              case AuthStatus.authenticated:
                // `unknown`: still resolving the initial session on app start.
                // `authenticated`: transient — the listener above is about to
                // navigate away, so nothing meaningful to render here.
                return const Center(child: CommonLoader());
              case AuthStatus.unauthenticated:
              case AuthStatus.authenticating:
              case AuthStatus.failure:
                final errorMessage = state.status == AuthStatus.failure ? state.message : null;
                return _SignInLayout(errorMessage: errorMessage);
            }
          },
        ),
      ),
    );
  }
}

class _SignInLayout extends StatelessWidget {
  const _SignInLayout({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dimensions.isWeb
        ? _WebSignInLayout(errorMessage: errorMessage)
        : _MobileSignInLayout(errorMessage: errorMessage);
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.tr('auth_new_here'), style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.signUp),
          child: Text(context.tr('auth_register_link')),
        ),
      ],
    );
  }
}

class _MobileSignInLayout extends StatelessWidget {
  const _MobileSignInLayout({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: Dimensions.paddingSymmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: Dimensions.height(24)),
          const Center(child: AuthBrandPanel(compact: true)),
          SizedBox(height: Dimensions.height(32)),
          Text(
            context.tr('auth_welcome_title'),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: Dimensions.font(24)),
          ),
          SizedBox(height: Dimensions.height(6)),
          Text(
            context.tr('auth_welcome_subtitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: Dimensions.height(28)),
          if (errorMessage != null) AuthErrorBanner(message: errorMessage!),
          const SignInForm(),
          SizedBox(height: Dimensions.height(16)),
          const _RegisterLink(),
          SizedBox(height: Dimensions.height(16)),
          Text(
            context.tr('auth_admin_only_footer'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Dimensions.font(12)),
          ),
          SizedBox(height: Dimensions.height(16)),
        ],
      ),
    );
  }
}

class _WebSignInLayout extends StatelessWidget {
  const _WebSignInLayout({this.errorMessage});

  final String? errorMessage;

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
            child: const Center(child: AuthBrandPanel()),
          ),
        ),
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              padding: Dimensions.allPadding(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('auth_welcome_title'),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('auth_welcome_subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    if (errorMessage != null) AuthErrorBanner(message: errorMessage!),
                    const SignInForm(),
                    const SizedBox(height: 16),
                    const _RegisterLink(),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('auth_admin_only_footer'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
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
