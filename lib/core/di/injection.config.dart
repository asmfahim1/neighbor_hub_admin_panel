// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
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
import 'package:neighbor_hub_admin_panel/core/notifications/notification_service.dart'
    as _i723;
import 'package:neighbor_hub_admin_panel/core/permissions/permission_service.dart'
    as _i363;
import 'package:neighbor_hub_admin_panel/core/session_manager/pref_manager.dart'
    as _i535;
import 'package:neighbor_hub_admin_panel/core/session_manager/session_manager.dart'
    as _i455;
import 'package:neighbor_hub_admin_panel/features/demo/data/repositories/demo_repository_impl.dart'
    as _i951;
import 'package:neighbor_hub_admin_panel/features/demo/data/sources/demo_remote_data_source.dart'
    as _i1065;
import 'package:neighbor_hub_admin_panel/features/demo/domain/repositories/demo_repository.dart'
    as _i806;
import 'package:neighbor_hub_admin_panel/features/demo/domain/usecases/get_users_usecase.dart'
    as _i840;
import 'package:neighbor_hub_admin_panel/features/demo/domain/usecases/login_usecase.dart'
    as _i687;
import 'package:neighbor_hub_admin_panel/features/demo/domain/usecases/logout_usecase.dart'
    as _i274;
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
    gh.lazySingleton<_i363.PermissionService>(() => _i363.PermissionService());
    gh.factory<_i535.PrefManager>(
      () => _i535.PrefManager(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i723.NotificationService>(
      () => _i723.NotificationService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.factory<_i455.SessionManager>(
      () => _i455.SessionManager(gh<_i535.PrefManager>()),
    );
    gh.lazySingleton<_i1037.DioClient>(
      () => _i1037.DioClient(gh<_i455.SessionManager>()),
    );
    gh.lazySingleton<_i811.ApiService>(
      () => _i811.ApiService(gh<_i1037.DioClient>()),
    );
    gh.factory<_i1065.DemoRemoteDataSource>(
      () => _i1065.DemoRemoteDataSource(gh<_i811.ApiService>()),
    );
    gh.lazySingleton<_i806.DemoRepository>(
      () => _i951.DemoRepositoryImpl(
        gh<_i1065.DemoRemoteDataSource>(),
        gh<_i455.SessionManager>(),
      ),
    );
    gh.factory<_i840.GetUsersUseCase>(
      () => _i840.GetUsersUseCase(gh<_i806.DemoRepository>()),
    );
    gh.factory<_i687.LoginUseCase>(
      () => _i687.LoginUseCase(gh<_i806.DemoRepository>()),
    );
    gh.factory<_i274.LogoutUseCase>(
      () => _i274.LogoutUseCase(gh<_i806.DemoRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i85.AppModule {}
