import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/firebase/current_session.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_admin_shell.dart';
import '../widgets/dashboard_body.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.previewMode = false});

  final bool previewMode;

  void _startWatchIfNeeded(
    BuildContext context,
    AuthState authState,
    DashboardState dashboardState,
  ) {
    final shouldStart =
        dashboardState.status == DashboardStatus.initial || (!previewMode && dashboardState.isPreview);
    if (!shouldStart) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (previewMode) {
        context.read<DashboardBloc>().add(const DashboardPreviewStarted());
        return;
      }
      if (authState.status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.auth,
          (route) => false,
        );
        return;
      }
      if (authState.status != AuthStatus.authenticated) return;
      try {
        final buildingId = getIt<CurrentSession>().requireBuildingId();
        context.read<DashboardBloc>().add(DashboardWatchStarted(buildingId));
      } catch (_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.splash,
          (route) => false,
        );
      }
    });
  }

  void _navigate(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _signOut(BuildContext context) {
    if (previewMode) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.auth,
        (route) => false,
      );
      return;
    }
    context.read<AuthBloc>().add(const SignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (!previewMode && state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.auth,
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, dashboardState) {
              _startWatchIfNeeded(context, authState, dashboardState);

              return DashboardAdminShell(
                authState: authState,
                body: DashboardBody(state: dashboardState),
                onNavigate: (route) => _navigate(context, route),
                onSignOut: () => _signOut(context),
              );
            },
          );
        },
      ),
    );
  }
}
