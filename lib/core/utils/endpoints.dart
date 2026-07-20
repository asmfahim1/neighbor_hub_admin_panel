class ApiEndpoints {
  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';

  // Users endpoints
  static const String usersList = '/users';
  static const String usersDetail = '/users/{id}';

    // ----- dashboard endpoints -----
  static const dashboardList = '/dashboard';
  static const dashboardDetail = '/dashboard/{id}';
  // ----- end dashboard -----
    // ----- buildings endpoints -----
  static const buildingsList = '/buildings';
  static const buildingsDetail = '/buildings/{id}';
  // ----- end buildings -----
    // ----- apartments endpoints -----
  static const apartmentsList = '/apartments';
  static const apartmentsDetail = '/apartments/{id}';
  // ----- end apartments -----
    // ----- residents endpoints -----
  static const residentsList = '/residents';
  static const residentsDetail = '/residents/{id}';
  // ----- end residents -----
    // ----- moderation endpoints -----
  static const moderationList = '/moderation';
  static const moderationDetail = '/moderation/{id}';
  // ----- end moderation -----
    // ----- announcements endpoints -----
  static const announcementsList = '/announcements';
  static const announcementsDetail = '/announcements/{id}';
  // ----- end announcements -----
    // ----- polls endpoints -----
  static const pollsList = '/polls';
  static const pollsDetail = '/polls/{id}';
  // ----- end polls -----
    // ----- analytics endpoints -----
  static const analyticsList = '/analytics';
  static const analyticsDetail = '/analytics/{id}';
  // ----- end analytics -----
    // ----- chat endpoints -----
  static const chatList = '/chat';
  static const chatDetail = '/chat/{id}';
  // ----- end chat -----
    // ----- notifications endpoints -----
  static const notificationsList = '/notifications';
  static const notificationsDetail = '/notifications/{id}';
  // ----- end notifications -----
    // ----- profile endpoints -----
  static const profileList = '/profile';
  static const profileDetail = '/profile/{id}';
  // ----- end profile -----
    // ----- auth endpoints -----
  static const authList = '/auth';
  static const authDetail = '/auth/{id}';
  // ----- end auth -----
  // arcle:feature_endpoints
}
