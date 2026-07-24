import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'dashboard_card.dart';

class DashboardAdminShell extends StatelessWidget {
  const DashboardAdminShell({
    super.key,
    required this.authState,
    required this.body,
    required this.onNavigate,
    required this.onSignOut,
  });

  final AuthState authState;
  final Widget body;
  final ValueChanged<String> onNavigate;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth >= Dimensions.webBreakpoint;

        if (useSidebar) {
          return Scaffold(
            body: Row(
              children: [
                DashboardSidebar(
                  authState: authState,
                  activeRoute: AppRoutes.dashboard,
                  onNavigate: onNavigate,
                  onSignOut: onSignOut,
                ),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          drawer: DashboardMobileDrawer(
            authState: authState,
            activeRoute: AppRoutes.dashboard,
            onNavigate: onNavigate,
            onSignOut: onSignOut,
          ),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(context.tr('dashboard_title')),
            actions: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () => onNavigate(AppRoutes.notifications),
              ),
            ],
          ),
          body: body,
          bottomNavigationBar: Builder(
            builder: (navContext) {
              return DashboardBottomNavigation(
                activeRoute: AppRoutes.dashboard,
                onNavigate: onNavigate,
                onMenuPressed: () => Scaffold.of(navContext).openDrawer(),
              );
            },
          ),
        );
      },
    );
  }
}

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    super.key,
    required this.authState,
    required this.activeRoute,
    required this.onNavigate,
    required this.onSignOut,
  });

  final AuthState authState;
  final String activeRoute;
  final ValueChanged<String> onNavigate;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: dashboardBorderColor(context))),
      ),
      child: DashboardNavigationContent(
        authState: authState,
        activeRoute: activeRoute,
        onNavigate: onNavigate,
        onSignOut: onSignOut,
      ),
    );
  }
}

class DashboardMobileDrawer extends StatelessWidget {
  const DashboardMobileDrawer({
    super.key,
    required this.authState,
    required this.activeRoute,
    required this.onNavigate,
    required this.onSignOut,
  });

  final AuthState authState;
  final String activeRoute;
  final ValueChanged<String> onNavigate;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DashboardNavigationContent(
        authState: authState,
        activeRoute: activeRoute,
        onNavigate: (route) {
          Navigator.of(context).pop();
          onNavigate(route);
        },
        onSignOut: () {
          Navigator.of(context).pop();
          onSignOut();
        },
      ),
    );
  }
}

class DashboardNavigationContent extends StatelessWidget {
  const DashboardNavigationContent({
    super.key,
    required this.authState,
    required this.activeRoute,
    required this.onNavigate,
    required this.onSignOut,
  });

  final AuthState authState;
  final String activeRoute;
  final ValueChanged<String> onNavigate;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          DashboardAdminIdentity(authState: authState),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              children: [
                const DashboardNavSection(label: 'Primary'),
                for (final item in _primaryItems)
                  DashboardNavItem(
                    label: item.label,
                    icon: item.icon,
                    route: item.route,
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                const DashboardNavSection(label: 'Communication'),
                for (final item in _communicationItems)
                  DashboardNavItem(
                    label: item.label,
                    icon: item.icon,
                    route: item.route,
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                const DashboardNavSection(label: 'Management'),
                for (final item in _managementItems)
                  DashboardNavItem(
                    label: item.label,
                    icon: item.icon,
                    route: item.route,
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              children: [
                for (final item in _accountItems)
                  DashboardNavItem(
                    label: item.label,
                    icon: item.icon,
                    route: item.route,
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Sign out'),
                  onTap: onSignOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardNavData {
  const DashboardNavData({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

const _primaryItems = [
  DashboardNavData(
    label: 'Dashboard',
    icon: Icons.dashboard_rounded,
    route: AppRoutes.dashboard,
  ),
  DashboardNavData(
    label: 'Requests',
    icon: Icons.pending_actions_rounded,
    route: AppRoutes.residents,
  ),
  DashboardNavData(
    label: 'Apartments',
    icon: Icons.apartment_rounded,
    route: AppRoutes.apartments,
  ),
  DashboardNavData(
    label: 'Residents',
    icon: Icons.groups_2_rounded,
    route: AppRoutes.residents,
  ),
];

const _communicationItems = [
  DashboardNavData(
    label: 'Announcements',
    icon: Icons.campaign_rounded,
    route: AppRoutes.announcements,
  ),
  DashboardNavData(
    label: 'Chat',
    icon: Icons.chat_bubble_outline_rounded,
    route: AppRoutes.chat,
  ),
  DashboardNavData(
    label: 'Notifications',
    icon: Icons.notifications_none_rounded,
    route: AppRoutes.notifications,
  ),
];

const _managementItems = [
  DashboardNavData(
    label: 'Building',
    icon: Icons.domain_rounded,
    route: AppRoutes.buildings,
  ),
  DashboardNavData(
    label: 'Moderation',
    icon: Icons.shield_outlined,
    route: AppRoutes.moderation,
  ),
  DashboardNavData(
    label: 'Polls',
    icon: Icons.poll_rounded,
    route: AppRoutes.polls,
  ),
  DashboardNavData(
    label: 'Analytics',
    icon: Icons.query_stats_rounded,
    route: AppRoutes.analytics,
  ),
];

const _accountItems = [
  DashboardNavData(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    route: AppRoutes.profile,
  ),
  DashboardNavData(
    label: 'Settings',
    icon: Icons.settings_outlined,
    route: AppRoutes.settings,
  ),
];

class DashboardAdminIdentity extends StatelessWidget {
  const DashboardAdminIdentity({super.key, required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final session = authState.session;
    final displayName = session?.displayName;
    final email = session?.email;
    final name = displayName != null && displayName.trim().isNotEmpty
        ? displayName
        : 'Building Admin';
    final emailText = email != null && email.trim().isNotEmpty
        ? email
        : 'No email available';

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  emailText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 6),
                const DashboardStatusPill(
                  label: 'Admin',
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardBottomNavigation extends StatelessWidget {
  const DashboardBottomNavigation({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
    required this.onMenuPressed,
  });

  final String activeRoute;
  final ValueChanged<String> onNavigate;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _indexForRoute(activeRoute),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
      onTap: (index) {
        switch (index) {
          case 0:
            onNavigate(AppRoutes.dashboard);
            return;
          case 1:
            onNavigate(AppRoutes.residents);
            return;
          case 2:
            onNavigate(AppRoutes.announcements);
            return;
          case 3:
            onNavigate(AppRoutes.notifications);
            return;
          case 4:
            onMenuPressed();
            return;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pending_actions_rounded),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_rounded),
          label: 'Announcements',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_rounded),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_rounded),
          label: 'Menu',
        ),
      ],
    );
  }

  int _indexForRoute(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return 0;
      case AppRoutes.residents:
        return 1;
      case AppRoutes.announcements:
        return 2;
      case AppRoutes.notifications:
        return 3;
      default:
        return 4;
    }
  }
}

class DashboardNavSection extends StatelessWidget {
  const DashboardNavSection({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
      ),
    );
  }
}

class DashboardNavItem extends StatelessWidget {
  const DashboardNavItem({
    super.key,
    required this.label,
    required this.icon,
    required this.route,
    required this.activeRoute,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String route;
  final String activeRoute;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = route == activeRoute;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: selected,
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon),
        title: Text(label),
        onTap: () => onTap(route),
      ),
    );
  }
}
