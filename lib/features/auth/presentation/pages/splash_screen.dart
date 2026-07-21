import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/svg_icon.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/animated_app_name.dart';

/// App launch screen — the full-screen version of the web sign-in layout's
/// left brand panel (same gradient, logo, tagline), with the app name
/// revealed via [AnimatedAppName]. Doubles as the auto-login gate: it holds
/// the splash for a minimum duration while [AuthBloc] resolves the
/// persisted Firebase session (`AuthStarted` is dispatched once at bloc
/// construction — see `auth_bloc.dart`), then routes to the Dashboard or
/// the sign-in screen. This works uniformly for every sign-in method
/// (email/password, Google, Apple) because Firebase Auth's own session
/// persistence — not this screen — is what remembers the signed-in user;
/// `AuthBloc.watchAuthState()` just reports whatever Firebase already knows.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Floor for how long the splash stays up, so the entrance animation is
  /// always seen in full even when Firebase resolves the session instantly
  /// (e.g. already cached in memory).
  static const _minDisplayDuration = Duration(milliseconds: 1600);

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    unawaited(_waitThenNavigate());
  }

  Future<void> _waitThenNavigate() async {
    final bloc = context.read<AuthBloc>();
    final currentState = bloc.state;
    final resolvedState = currentState.status != AuthStatus.unknown
        ? Future.value(currentState)
        : bloc.stream.firstWhere((state) => state.status != AuthStatus.unknown);

    final results = await Future.wait([
      resolvedState,
      Future<void>.delayed(_minDisplayDuration),
    ]);

    if (!mounted || _navigated) return;
    _navigated = true;

    final state = results.first as AuthState;
    Navigator.of(context).pushNamedAndRemoveUntil(
      state.status == AuthStatus.authenticated ? AppRoutes.dashboard : AppRoutes.auth,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.brandNavyDark, AppColors.darkBackground]
                : [AppColors.brandNavyLight, const Color(0xFF1E293B)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: SvgIcon(AppAssets.logoMark, size: Dimensions.icon(96)),
              ),
              SizedBox(height: Dimensions.height(24)),
              AnimatedAppName(
                text: context.tr('auth_app_name'),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: Dimensions.font(32),
                      color: Colors.white,
                    ),
              ),
              SizedBox(height: Dimensions.height(10)),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(opacity: value, child: child),
                child: Text(
                  context.tr('auth_brand_tagline'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: Dimensions.font(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
