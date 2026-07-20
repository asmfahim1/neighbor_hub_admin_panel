import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/settings/presentation/app_settings_cubit.dart';
import '../session_manager/pref_manager.dart';
import 'injection.dart';
// arcle:feature_imports
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/domain/usecase/profile_usecase.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/domain/usecase/notifications_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/chat/domain/usecase/chat_usecase.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/analytics/domain/usecase/analytics_usecase.dart';
import '../../features/polls/presentation/bloc/polls_bloc.dart';
import '../../features/polls/domain/usecase/polls_usecase.dart';
import '../../features/announcements/presentation/bloc/announcements_bloc.dart';
import '../../features/announcements/domain/usecase/announcements_usecase.dart';
import '../../features/moderation/presentation/bloc/moderation_bloc.dart';
import '../../features/moderation/domain/usecase/moderation_usecase.dart';
import '../../features/residents/presentation/bloc/residents_bloc.dart';
import '../../features/residents/domain/usecase/residents_usecase.dart';
import '../../features/apartments/presentation/bloc/apartments_bloc.dart';
import '../../features/buildings/presentation/bloc/buildings_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

/// Centralized BLoC providers for the application.
/// 
/// All BLoCs are provided at the app level to ensure they are available
/// throughout the widget tree without needing to create them in individual screens.
class AppBlocProviders {
  /// Returns a list of all BLoC providers for the application.
  static List<BlocProvider> get providers => [
    BlocProvider<AppSettingsCubit>(
      create: (_) => AppSettingsCubit(getIt<PrefManager>()),
    ),
        BlocProvider<DashboardBloc>(create: (_) => getIt<DashboardBloc>()),
        BlocProvider<BuildingsBloc>(create: (_) => getIt<BuildingsBloc>()),
        BlocProvider<ApartmentsBloc>(create: (_) => getIt<ApartmentsBloc>()),
        BlocProvider<ResidentsBloc>(create: (_) => ResidentsBloc(getIt<ResidentsUseCase>())),
        BlocProvider<ModerationBloc>(create: (_) => ModerationBloc(getIt<ModerationUseCase>())),
        BlocProvider<AnnouncementsBloc>(create: (_) => AnnouncementsBloc(getIt<AnnouncementsUseCase>())),
        BlocProvider<PollsBloc>(create: (_) => PollsBloc(getIt<PollsUseCase>())),
        BlocProvider<AnalyticsBloc>(create: (_) => AnalyticsBloc(getIt<AnalyticsUseCase>())),
        BlocProvider<ChatBloc>(create: (_) => ChatBloc(getIt<ChatUseCase>())),
        BlocProvider<NotificationsBloc>(create: (_) => NotificationsBloc(getIt<NotificationsUseCase>())),
        BlocProvider<ProfileBloc>(create: (_) => ProfileBloc(getIt<ProfileUseCase>())),
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
    // arcle:feature_providers
  ];

  /// Wraps the given child widget with MultiBlocProvider.
  static Widget wrapWithProviders(Widget child) {
    return MultiBlocProvider(
      providers: providers,
      child: child,
    );
  }
}
