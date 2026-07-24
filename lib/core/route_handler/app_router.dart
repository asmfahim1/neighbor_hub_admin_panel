import 'package:flutter/material.dart';

import '../../features/settings/presentation/settings_screen.dart';
import 'app_routes.dart';
// arcle:feature_imports
import '../../features/auth/presentation/pages/auth_screen.dart';
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/polls/presentation/pages/polls_screen.dart';
import '../../features/announcements/presentation/pages/announcements_screen.dart';
import '../../features/moderation/presentation/pages/moderation_screen.dart';
import '../../features/residents/presentation/pages/residents_screen.dart';
import '../../features/apartments/presentation/pages/apartments_screen.dart';
import '../../features/buildings/presentation/pages/buildings_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
            case AppRoutes.dashboard:
        final previewMode = settings.arguments == true;
        return MaterialPageRoute(builder: (_) => DashboardScreen(previewMode: previewMode));
            case AppRoutes.buildings:
        return MaterialPageRoute(builder: (_) => const BuildingsScreen());
            case AppRoutes.apartments:
        return MaterialPageRoute(builder: (_) => const ApartmentsScreen());
            case AppRoutes.residents:
        return MaterialPageRoute(builder: (_) => const ResidentsScreen());
            case AppRoutes.moderation:
        return MaterialPageRoute(builder: (_) => const ModerationScreen());
            case AppRoutes.announcements:
        return MaterialPageRoute(builder: (_) => const AnnouncementsScreen());
            case AppRoutes.polls:
        return MaterialPageRoute(builder: (_) => const PollsScreen());
            case AppRoutes.analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
            case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());
            case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
            case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
            case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      // arcle:feature_cases
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
