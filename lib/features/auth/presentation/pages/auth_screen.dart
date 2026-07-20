import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_card.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('auth_title'))),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AuthStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case AuthStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    AuthCard(entity: state.items[index]),
              );
            case AuthStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
