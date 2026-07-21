import 'package:flutter/material.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const settings = '/settings';
  static String initialRoute = splash;
  static const splash = '/splash';
    static const dashboard = '/dashboard';
    static const buildings = '/buildings';
    static const apartments = '/apartments';
    static const residents = '/residents';
    static const moderation = '/moderation';
    static const announcements = '/announcements';
    static const polls = '/polls';
    static const analytics = '/analytics';
    static const chat = '/chat';
    static const notifications = '/notifications';
    static const profile = '/profile';
    static const auth = '/auth';
    static const signUp = '/sign-up';
  // arcle:feature_routes
}
