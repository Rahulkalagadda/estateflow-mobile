import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/activate_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/leads/presentation/lead_list_screen.dart';
import '../../features/leads/presentation/lead_details_screen.dart';
import '../../features/leads/presentation/create_lead_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/team_directory_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../theme/app_theme.dart';
import '../models/lead_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isLoggedIn = auth.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isActivating = state.uri.toString().startsWith('/activate');

      if (!isLoggedIn && !isLoggingIn && !isActivating) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/activate',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ActivateScreen(token: token);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/leads',
            builder: (context, state) => const LeadListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CreateLeadScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => LeadDetailsScreen(leadId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => CreateLeadScreen(existingLead: state.extra as LeadModel?),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'team',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const TeamDirectoryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true, // For glassmorphism effect
      drawer: const _SideDrawer(),
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/leads/create');
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }
}

class _SideDrawer extends StatelessWidget {
  const _SideDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.business, color: context.colors.primary),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'EstateFlow',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.colors.onBackground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.colors.outlineVariant),
            ListTile(
              leading: Icon(Icons.settings, color: context.colors.onSurfaceVariant),
              title: Text('Settings', style: TextStyle(color: context.colors.onSurface)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: context.colors.onSurfaceVariant),
              title: Text('Help & Support', style: TextStyle(color: context.colors.onSurface)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: Icon(Icons.logout, color: context.colors.error),
              title: Text('Logout', style: TextStyle(color: context.colors.error)),
              onTap: () {
                Navigator.pop(context);
                final authNotifier = ProviderScope.containerOf(context).read(authProvider.notifier);
                authNotifier.logout();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _BottomNavBar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceHighlight.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(color: context.colors.outlineVariant, width: 1),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavBarItem(
                    icon: Icons.space_dashboard_rounded,
                    isSelected: location == '/',
                    onTap: () => context.go('/'),
                  ),
                  _NavBarItem(
                    icon: Icons.people_alt_rounded,
                    isSelected: location.startsWith('/leads'),
                    onTap: () => context.go('/leads'),
                  ),
                  const SizedBox(width: 48), // Space for FAB
                  _NavBarItem(
                    icon: Icons.notifications_rounded,
                    isSelected: location == '/notifications',
                    onTap: () => context.go('/notifications'),
                  ),
                  _NavBarItem(
                    icon: Icons.menu_rounded,
                    isSelected: false,
                    onTap: onMenuTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? context.colors.primary : context.colors.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}
