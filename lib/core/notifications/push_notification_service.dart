import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

/// FCM (Firebase Cloud Messaging) client-side plumbing — token acquisition,
/// permission request, and foreground/background/opened-app message streams.
///
/// **Status: optional / dormant infrastructure.** Phase 1 runs entirely on
/// the Spark (free) plan with no Cloud Functions (`admen_web_app_ui_functionality.md`
/// §2), so nothing in this codebase currently *sends* a push — there is no
/// server-side trigger yet. This service exists so that:
/// 1. the device's FCM token can be captured and persisted to
///    `users/{uid}/private/account.fcmToken` (the field already reserved for
///    it in `05_FIRESTORE_DATABASE.md` §3.2b) as soon as a Blaze-plan backend
///    is introduced, with zero client-side rework;
/// 2. the Resident App can copy this file as-is.
///
/// Killed-app delivery depends entirely on a future server-side sender; the
/// in-app/foreground notification experience for Phase 1 is covered by
/// [NotificationService] (local notifications) instead.
@lazySingleton
class PushNotificationService {
  PushNotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  /// Foreground messages — app open and visible.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// User tapped a notification that opened/resumed the app from background.
  Stream<RemoteMessage> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp;

  /// Fires whenever the platform rotates the FCM token — per
  /// `05_FIRESTORE_DATABASE.md` §3.2b, the token must be re-persisted on
  /// every rotation, never written just once at account creation.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// The message (if any) that caused the app to be launched from a
  /// completely killed state by a notification tap.
  Future<RemoteMessage?> getInitialMessage() => _messaging.getInitialMessage();

  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() => _messaging.getToken();

  Future<void> deleteToken() => _messaging.deleteToken();

  /// Registers the top-level [firebaseMessagingBackgroundHandler]. Must be
  /// called once, after `Firebase.initializeApp()` and before `runApp` (see
  /// `bootstrap.dart`) — a Flutter/FCM requirement, not a project choice.
  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}

/// Background message handler — invoked in its own isolate when a push
/// arrives while the app is backgrounded or fully killed. Must be a
/// top-level (or static) function per the `firebase_messaging` contract.
///
/// Intentionally minimal: Phase 1 has no Cloud Function sender, so no
/// message will actually arrive here yet. Kept as ready plumbing — see the
/// class doc comment above.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
