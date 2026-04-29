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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// A notifier that triggers a router refresh when the auth state changes.
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
  final authState = ref.read(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      // Use ref.read here because refreshListenable will trigger a re-evaluation
      final auth = ref.read(authProvider);
      final isLoggedIn = auth.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isActivating = state.uri.toString().startsWith('/activate');

      print('Router Redirect: isLoggedIn=$isLoggedIn, location=${state.uri}');

      if (!isLoggedIn && !isLoggingIn && !isActivating) {
        print('Redirecting to /login');
        return '/login';
      }
      if (isLoggedIn && isLoggingIn) {
        print('Redirecting to / (from login)');
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
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
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
              ),
            ],
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const TasksScreen(),
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

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.grid_view,
                label: 'HOME',
                isSelected: location == '/',
                onTap: () => context.go('/'),
              ),
              _NavBarItem(
                icon: Icons.diversity_3,
                label: 'LEADS',
                isSelected: location.startsWith('/leads'),
                onTap: () => context.go('/leads'),
              ),
              _NavBarItem(
                icon: Icons.calendar_month,
                label: 'SCHEDULE',
                isSelected: location == '/schedule',
                onTap: () => context.go('/schedule'),
              ),
              _NavBarItem(
                icon: Icons.person,
                label: 'PROFILE',
                isSelected: location == '/profile',
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.outline,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: isSelected ? Colors.white : AppColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
