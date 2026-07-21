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
import '../widgets/sign_up_form.dart';

/// Self-service admin sign-up screen — "Bootstrap-once" model (§7.1): only
/// the first person to complete this form becomes the building's admin;
/// see `auth_plan.md` for the full rationale. Responsive layout mirrors
/// `AuthScreen` exactly (mobile single column / web split-pane). Stateless:
/// rendering is entirely driven by `AuthBloc`.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
            if (state.status == AuthStatus.authenticated) {
              return const Center(child: CommonLoader());
            }
            final errorMessage = state.status == AuthStatus.failure ? state.message : null;
            return _SignUpLayout(errorMessage: errorMessage);
          },
        ),
      ),
    );
  }
}

class _SignUpLayout extends StatelessWidget {
  const _SignUpLayout({this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dimensions.isWeb
        ? _WebSignUpLayout(errorMessage: errorMessage)
        : _MobileSignUpLayout(errorMessage: errorMessage);
  }
}

class _SignInLink extends StatelessWidget {
  const _SignInLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.tr('auth_have_account'), style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.auth),
          child: Text(context.tr('auth_sign_in_link')),
        ),
      ],
    );
  }
}

class _MobileSignUpLayout extends StatelessWidget {
  const _MobileSignUpLayout({this.errorMessage});

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
            context.tr('auth_sign_up_title'),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: Dimensions.font(24)),
          ),
          SizedBox(height: Dimensions.height(6)),
          Text(
            context.tr('auth_sign_up_subtitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: Dimensions.height(28)),
          if (errorMessage != null) AuthErrorBanner(message: errorMessage!),
          const SignUpForm(),
          SizedBox(height: Dimensions.height(16)),
          const _SignInLink(),
          SizedBox(height: Dimensions.height(16)),
        ],
      ),
    );
  }
}

class _WebSignUpLayout extends StatelessWidget {
  const _WebSignUpLayout({this.errorMessage});

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
                      context.tr('auth_sign_up_title'),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('auth_sign_up_subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    if (errorMessage != null) AuthErrorBanner(message: errorMessage!),
                    const SignUpForm(),
                    const SizedBox(height: 16),
                    const _SignInLink(),
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
