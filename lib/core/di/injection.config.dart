// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:neighbor_hub_admin_panel/core/api_client/api_service.dart'
    as _i811;
import 'package:neighbor_hub_admin_panel/core/api_client/dio_client.dart'
    as _i1037;
import 'package:neighbor_hub_admin_panel/core/di/injectable_module.dart'
    as _i85;
import 'package:neighbor_hub_admin_panel/core/firebase/current_session.dart'
    as _i827;
import 'package:neighbor_hub_admin_panel/core/firebase/firebase_auth_service.dart'
    as _i243;
import 'package:neighbor_hub_admin_panel/core/firebase/firestore_service.dart'
    as _i998;
import 'package:neighbor_hub_admin_panel/core/notifications/notification_service.dart'
    as _i723;
import 'package:neighbor_hub_admin_panel/core/notifications/push_notification_service.dart'
    as _i925;
import 'package:neighbor_hub_admin_panel/core/permissions/permission_service.dart'
    as _i363;
import 'package:neighbor_hub_admin_panel/core/session_manager/pref_manager.dart'
    as _i535;
import 'package:neighbor_hub_admin_panel/core/session_manager/session_manager.dart'
    as _i455;
import 'package:neighbor_hub_admin_panel/features/analytics/data/repository/analytics_repository_impl.dart'
    as _i441;
import 'package:neighbor_hub_admin_panel/features/analytics/data/source/analytics_remote_source.dart'
    as _i965;
import 'package:neighbor_hub_admin_panel/features/analytics/domain/repository/analytics_repository.dart'
    as _i901;
import 'package:neighbor_hub_admin_panel/features/analytics/domain/usecase/analytics_usecase.dart'
    as _i131;
import 'package:neighbor_hub_admin_panel/features/announcements/data/repository/announcements_repository_impl.dart'
    as _i43;
import 'package:neighbor_hub_admin_panel/features/announcements/data/source/announcements_remote_source.dart'
    as _i68;
import 'package:neighbor_hub_admin_panel/features/announcements/domain/repository/announcements_repository.dart'
    as _i929;
import 'package:neighbor_hub_admin_panel/features/announcements/domain/usecase/announcements_usecase.dart'
    as _i32;
import 'package:neighbor_hub_admin_panel/features/apartments/data/repository/apartments_repository_impl.dart'
    as _i480;
import 'package:neighbor_hub_admin_panel/features/apartments/data/source/apartments_remote_source.dart'
    as _i730;
import 'package:neighbor_hub_admin_panel/features/apartments/domain/repository/apartments_repository.dart'
    as _i795;
import 'package:neighbor_hub_admin_panel/features/apartments/domain/usecase/apartments_usecase.dart'
    as _i293;
import 'package:neighbor_hub_admin_panel/features/apartments/presentation/bloc/apartments_bloc.dart'
    as _i169;
import 'package:neighbor_hub_admin_panel/features/auth/data/repository/auth_repository_impl.dart'
    as _i936;
import 'package:neighbor_hub_admin_panel/features/auth/data/source/auth_remote_source.dart'
    as _i528;
import 'package:neighbor_hub_admin_panel/features/auth/domain/repository/auth_repository.dart'
    as _i277;
import 'package:neighbor_hub_admin_panel/features/auth/domain/usecase/auth_usecase.dart'
    as _i123;
import 'package:neighbor_hub_admin_panel/features/auth/presentation/bloc/auth_bloc.dart'
    as _i592;
import 'package:neighbor_hub_admin_panel/features/buildings/data/repository/buildings_repository_impl.dart'
    as _i317;
import 'package:neighbor_hub_admin_panel/features/buildings/data/source/buildings_remote_source.dart'
    as _i654;
import 'package:neighbor_hub_admin_panel/features/buildings/domain/repository/buildings_repository.dart'
    as _i114;
import 'package:neighbor_hub_admin_panel/features/buildings/domain/usecase/buildings_usecase.dart'
    as _i257;
import 'package:neighbor_hub_admin_panel/features/buildings/presentation/bloc/buildings_bloc.dart'
    as _i521;
import 'package:neighbor_hub_admin_panel/features/chat/data/repository/chat_repository_impl.dart'
    as _i620;
import 'package:neighbor_hub_admin_panel/features/chat/data/source/chat_remote_source.dart'
    as _i310;
import 'package:neighbor_hub_admin_panel/features/chat/domain/repository/chat_repository.dart'
    as _i1067;
import 'package:neighbor_hub_admin_panel/features/chat/domain/usecase/chat_usecase.dart'
    as _i579;
import 'package:neighbor_hub_admin_panel/features/dashboard/data/repository/dashboard_repository_impl.dart'
    as _i453;
import 'package:neighbor_hub_admin_panel/features/dashboard/data/source/dashboard_remote_source.dart'
    as _i829;
import 'package:neighbor_hub_admin_panel/features/dashboard/domain/repository/dashboard_repository.dart'
    as _i613;
import 'package:neighbor_hub_admin_panel/features/dashboard/domain/usecase/dashboard_usecase.dart'
    as _i862;
import 'package:neighbor_hub_admin_panel/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i264;
import 'package:neighbor_hub_admin_panel/features/moderation/data/repository/moderation_repository_impl.dart'
    as _i657;
import 'package:neighbor_hub_admin_panel/features/moderation/data/source/moderation_remote_source.dart'
    as _i660;
import 'package:neighbor_hub_admin_panel/features/moderation/domain/repository/moderation_repository.dart'
    as _i555;
import 'package:neighbor_hub_admin_panel/features/moderation/domain/usecase/moderation_usecase.dart'
    as _i392;
import 'package:neighbor_hub_admin_panel/features/notifications/data/repository/notifications_repository_impl.dart'
    as _i80;
import 'package:neighbor_hub_admin_panel/features/notifications/data/source/notifications_remote_source.dart'
    as _i485;
import 'package:neighbor_hub_admin_panel/features/notifications/domain/repository/notifications_repository.dart'
    as _i507;
import 'package:neighbor_hub_admin_panel/features/notifications/domain/usecase/notifications_usecase.dart'
    as _i456;
import 'package:neighbor_hub_admin_panel/features/polls/data/repository/polls_repository_impl.dart'
    as _i469;
import 'package:neighbor_hub_admin_panel/features/polls/data/source/polls_remote_source.dart'
    as _i428;
import 'package:neighbor_hub_admin_panel/features/polls/domain/repository/polls_repository.dart'
    as _i886;
import 'package:neighbor_hub_admin_panel/features/polls/domain/usecase/polls_usecase.dart'
    as _i889;
import 'package:neighbor_hub_admin_panel/features/profile/data/repository/profile_repository_impl.dart'
    as _i50;
import 'package:neighbor_hub_admin_panel/features/profile/data/source/profile_remote_source.dart'
    as _i738;
import 'package:neighbor_hub_admin_panel/features/profile/domain/repository/profile_repository.dart'
    as _i1034;
import 'package:neighbor_hub_admin_panel/features/profile/domain/usecase/profile_usecase.dart'
    as _i350;
import 'package:neighbor_hub_admin_panel/features/residents/data/repository/residents_repository_impl.dart'
    as _i582;
import 'package:neighbor_hub_admin_panel/features/residents/data/source/residents_remote_source.dart'
    as _i798;
import 'package:neighbor_hub_admin_panel/features/residents/domain/repository/residents_repository.dart'
    as _i627;
import 'package:neighbor_hub_admin_panel/features/residents/domain/usecase/residents_usecase.dart'
    as _i12;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => appModule.notificationsPlugin,
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => appModule.firebaseFirestore,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => appModule.firebaseAuth);
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => appModule.firebaseMessaging,
    );
    gh.lazySingleton<_i827.CurrentSession>(() => _i827.CurrentSession());
    gh.lazySingleton<_i363.PermissionService>(() => _i363.PermissionService());
    gh.factory<_i535.PrefManager>(
      () => _i535.PrefManager(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i925.PushNotificationService>(
      () => _i925.PushNotificationService(gh<_i892.FirebaseMessaging>()),
    );
    gh.lazySingleton<_i723.NotificationService>(
      () => _i723.NotificationService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.lazySingleton<_i243.FirebaseAuthService>(
      () => _i243.FirebaseAuthService(gh<_i59.FirebaseAuth>()),
    );
    gh.lazySingleton<_i998.FirestoreService>(
      () => _i998.FirestoreService(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i528.AuthRemoteSource>(
      () => _i528.AuthFirestoreSource(
        gh<_i243.FirebaseAuthService>(),
        gh<_i998.FirestoreService>(),
        gh<_i925.PushNotificationService>(),
      ),
    );
    gh.lazySingleton<_i730.ApartmentsRemoteSource>(
      () => _i730.ApartmentsFirestoreSource(gh<_i998.FirestoreService>()),
    );
    gh.lazySingleton<_i654.BuildingsRemoteSource>(
      () => _i654.BuildingsFirestoreSource(gh<_i998.FirestoreService>()),
    );
    gh.factory<_i455.SessionManager>(
      () => _i455.SessionManager(gh<_i535.PrefManager>()),
    );
    gh.lazySingleton<_i829.DashboardRemoteSource>(
      () => _i829.DashboardFirestoreSource(gh<_i998.FirestoreService>()),
    );
    gh.lazySingleton<_i277.AuthRepository>(
      () => _i936.AuthRepositoryImpl(
        gh<_i528.AuthRemoteSource>(),
        gh<_i827.CurrentSession>(),
      ),
    );
    gh.lazySingleton<_i1037.DioClient>(
      () => _i1037.DioClient(gh<_i455.SessionManager>()),
    );
    gh.lazySingleton<_i795.ApartmentsRepository>(
      () => _i480.ApartmentsRepositoryImpl(gh<_i730.ApartmentsRemoteSource>()),
    );
    gh.lazySingleton<_i114.BuildingsRepository>(
      () => _i317.BuildingsRepositoryImpl(gh<_i654.BuildingsRemoteSource>()),
    );
    gh.factory<_i123.WatchAuthStateUseCase>(
      () => _i123.WatchAuthStateUseCase(gh<_i277.AuthRepository>()),
    );
    gh.factory<_i123.SignInWithEmailUseCase>(
      () => _i123.SignInWithEmailUseCase(gh<_i277.AuthRepository>()),
    );
    gh.factory<_i123.SignInWithGoogleUseCase>(
      () => _i123.SignInWithGoogleUseCase(gh<_i277.AuthRepository>()),
    );
    gh.factory<_i123.SignInWithAppleUseCase>(
      () => _i123.SignInWithAppleUseCase(gh<_i277.AuthRepository>()),
    );
    gh.factory<_i123.SendPasswordResetEmailUseCase>(
      () => _i123.SendPasswordResetEmailUseCase(gh<_i277.AuthRepository>()),
    );
    gh.factory<_i123.SignOutUseCase>(
      () => _i123.SignOutUseCase(gh<_i277.AuthRepository>()),
    );
    gh.lazySingleton<_i613.DashboardRepository>(
      () => _i453.DashboardRepositoryImpl(gh<_i829.DashboardRemoteSource>()),
    );
    gh.lazySingleton<_i811.ApiService>(
      () => _i811.ApiService(gh<_i1037.DioClient>()),
    );
    gh.lazySingleton<_i965.AnalyticsRemoteSource>(
      () => _i965.AnalyticsRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i68.AnnouncementsRemoteSource>(
      () => _i68.AnnouncementsRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i310.ChatRemoteSource>(
      () => _i310.ChatRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i660.ModerationRemoteSource>(
      () => _i660.ModerationRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i485.NotificationsRemoteSource>(
      () => _i485.NotificationsRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i428.PollsRemoteSource>(
      () => _i428.PollsRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i738.ProfileRemoteSource>(
      () => _i738.ProfileRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i798.ResidentsRemoteSource>(
      () => _i798.ResidentsRemoteSource(
        gh<_i811.ApiService>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.lazySingleton<_i929.AnnouncementsRepository>(
      () => _i43.AnnouncementsRepositoryImpl(
        gh<_i68.AnnouncementsRemoteSource>(),
      ),
    );
    gh.lazySingleton<_i901.AnalyticsRepository>(
      () => _i441.AnalyticsRepositoryImpl(gh<_i965.AnalyticsRemoteSource>()),
    );
    gh.factory<_i293.WatchApartmentsUseCase>(
      () => _i293.WatchApartmentsUseCase(gh<_i795.ApartmentsRepository>()),
    );
    gh.factory<_i293.CreateApartmentUseCase>(
      () => _i293.CreateApartmentUseCase(gh<_i795.ApartmentsRepository>()),
    );
    gh.factory<_i293.UpdateApartmentUseCase>(
      () => _i293.UpdateApartmentUseCase(gh<_i795.ApartmentsRepository>()),
    );
    gh.factory<_i293.DeleteApartmentUseCase>(
      () => _i293.DeleteApartmentUseCase(gh<_i795.ApartmentsRepository>()),
    );
    gh.factory<_i293.SetApartmentStatusUseCase>(
      () => _i293.SetApartmentStatusUseCase(gh<_i795.ApartmentsRepository>()),
    );
    gh.factory<_i293.ResolvePrimaryResidentUseCase>(
      () =>
          _i293.ResolvePrimaryResidentUseCase(gh<_i795.ApartmentsRepository>()),
    );
    gh.lazySingleton<_i507.NotificationsRepository>(
      () => _i80.NotificationsRepositoryImpl(
        gh<_i485.NotificationsRemoteSource>(),
      ),
    );
    gh.factory<_i131.AnalyticsUseCase>(
      () => _i131.AnalyticsUseCase(gh<_i901.AnalyticsRepository>()),
    );
    gh.lazySingleton<_i627.ResidentsRepository>(
      () => _i582.ResidentsRepositoryImpl(gh<_i798.ResidentsRemoteSource>()),
    );
    gh.factory<_i592.AuthBloc>(
      () => _i592.AuthBloc(
        gh<_i123.WatchAuthStateUseCase>(),
        gh<_i123.SignInWithEmailUseCase>(),
        gh<_i123.SignInWithGoogleUseCase>(),
        gh<_i123.SignInWithAppleUseCase>(),
        gh<_i123.SendPasswordResetEmailUseCase>(),
        gh<_i123.SignOutUseCase>(),
      ),
    );
    gh.factory<_i32.AnnouncementsUseCase>(
      () => _i32.AnnouncementsUseCase(gh<_i929.AnnouncementsRepository>()),
    );
    gh.lazySingleton<_i1067.ChatRepository>(
      () => _i620.ChatRepositoryImpl(gh<_i310.ChatRemoteSource>()),
    );
    gh.factory<_i12.ResidentsUseCase>(
      () => _i12.ResidentsUseCase(gh<_i627.ResidentsRepository>()),
    );
    gh.lazySingleton<_i886.PollsRepository>(
      () => _i469.PollsRepositoryImpl(gh<_i428.PollsRemoteSource>()),
    );
    gh.lazySingleton<_i555.ModerationRepository>(
      () => _i657.ModerationRepositoryImpl(gh<_i660.ModerationRemoteSource>()),
    );
    gh.factory<_i862.WatchDashboardApartmentsUseCase>(
      () => _i862.WatchDashboardApartmentsUseCase(
        gh<_i613.DashboardRepository>(),
      ),
    );
    gh.factory<_i862.WatchDashboardPendingRequestsUseCase>(
      () => _i862.WatchDashboardPendingRequestsUseCase(
        gh<_i613.DashboardRepository>(),
      ),
    );
    gh.factory<_i862.WatchDashboardRecentPostsUseCase>(
      () => _i862.WatchDashboardRecentPostsUseCase(
        gh<_i613.DashboardRepository>(),
      ),
    );
    gh.factory<_i862.WatchDashboardRecentAnnouncementsUseCase>(
      () => _i862.WatchDashboardRecentAnnouncementsUseCase(
        gh<_i613.DashboardRepository>(),
      ),
    );
    gh.factory<_i889.PollsUseCase>(
      () => _i889.PollsUseCase(gh<_i886.PollsRepository>()),
    );
    gh.factory<_i257.WatchBuildingUseCase>(
      () => _i257.WatchBuildingUseCase(gh<_i114.BuildingsRepository>()),
    );
    gh.factory<_i257.SaveBuildingUseCase>(
      () => _i257.SaveBuildingUseCase(gh<_i114.BuildingsRepository>()),
    );
    gh.factory<_i257.GenerateApartmentsUseCase>(
      () => _i257.GenerateApartmentsUseCase(gh<_i114.BuildingsRepository>()),
    );
    gh.factory<_i456.NotificationsUseCase>(
      () => _i456.NotificationsUseCase(gh<_i507.NotificationsRepository>()),
    );
    gh.factory<_i392.ModerationUseCase>(
      () => _i392.ModerationUseCase(gh<_i555.ModerationRepository>()),
    );
    gh.lazySingleton<_i1034.ProfileRepository>(
      () => _i50.ProfileRepositoryImpl(gh<_i738.ProfileRemoteSource>()),
    );
    gh.factory<_i264.DashboardBloc>(
      () => _i264.DashboardBloc(
        gh<_i862.WatchDashboardApartmentsUseCase>(),
        gh<_i862.WatchDashboardPendingRequestsUseCase>(),
        gh<_i862.WatchDashboardRecentPostsUseCase>(),
        gh<_i862.WatchDashboardRecentAnnouncementsUseCase>(),
      ),
    );
    gh.factory<_i169.ApartmentsBloc>(
      () => _i169.ApartmentsBloc(
        gh<_i293.WatchApartmentsUseCase>(),
        gh<_i293.CreateApartmentUseCase>(),
        gh<_i293.UpdateApartmentUseCase>(),
        gh<_i293.DeleteApartmentUseCase>(),
        gh<_i293.SetApartmentStatusUseCase>(),
      ),
    );
    gh.factory<_i579.ChatUseCase>(
      () => _i579.ChatUseCase(gh<_i1067.ChatRepository>()),
    );
    gh.factory<_i350.ProfileUseCase>(
      () => _i350.ProfileUseCase(gh<_i1034.ProfileRepository>()),
    );
    gh.factory<_i521.BuildingsBloc>(
      () => _i521.BuildingsBloc(
        gh<_i257.WatchBuildingUseCase>(),
        gh<_i257.SaveBuildingUseCase>(),
        gh<_i257.GenerateApartmentsUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i85.AppModule {}
