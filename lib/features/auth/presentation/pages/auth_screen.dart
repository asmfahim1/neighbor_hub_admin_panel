import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`auth_plan.md`). This just proves the [AuthBloc] wiring compiles
/// and renders something for each [AuthStatus].
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('auth_title'))),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.unknown:
            case AuthStatus.authenticating:
              return const Center(child: CircularProgressIndicator());
            case AuthStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case AuthStatus.authenticated:
              return Center(child: Text('Signed in as ${state.session?.displayName ?? ''}'));
            case AuthStatus.unauthenticated:
              return const Center(child: Text('Sign in'));
          }
        },
      ),
    );
  }
}
