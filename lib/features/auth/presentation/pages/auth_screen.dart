import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neighbor_hub_admin_panel/core/common_widgets/common_loader.dart';
import 'package:neighbor_hub_admin_panel/core/localization/app_strings.dart';
import 'package:neighbor_hub_admin_panel/core/route_handler/app_routes.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/bloc/auth_state.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/widgets/auth_responsive_layout.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/widgets/sign_in_form.dart';

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
                return const Center(child: CommonLoader());
              case AuthStatus.unauthenticated:
              case AuthStatus.authenticating:
              case AuthStatus.failure:
                final errorMessage = state.status == AuthStatus.failure ? state.message : null;
                return AuthResponsiveLayout(
                  titleKey: 'auth_welcome_title',
                  subtitleKey: 'auth_welcome_subtitle',
                  errorMessage: errorMessage,
                  form: const SignInForm(),
                  switchLink: const _RegisterLink(),
                  footerKey: 'auth_admin_only_footer',
                );
            }
          },
        ),
      ),
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
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
