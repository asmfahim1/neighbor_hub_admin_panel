import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/di/app_di.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/route_handler/app_route_observer.dart';
import 'app/app.dart';
import 'firebase_options.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Must be registered before runApp, per the firebase_messaging contract.
  PushNotificationService.registerBackgroundHandler();

  await setupDependencies();
  await AppRouteStorage.restoreInitialRoute();

  runApp(const App());
}
