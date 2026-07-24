import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/common_loader.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_responsive_layout.dart';
import '../widgets/sign_up_form.dart';

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
            return AuthResponsiveLayout(
              titleKey: 'auth_sign_up_title',
              subtitleKey: 'auth_sign_up_subtitle',
              errorMessage: errorMessage,
              form: const SignUpForm(),
              switchLink: const _SignInLink(),
              formMaxWidth: 500,
            );
          },
        ),
      ),
    );
  }
}

class _SignInLink extends StatelessWidget {
  const _SignInLink();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
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
