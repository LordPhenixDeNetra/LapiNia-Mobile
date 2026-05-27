import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/lapins/lapin_list_screen.dart';
import '../screens/lapins/lapin_detail_screen.dart';
import '../screens/lapins/lapin_form_screen.dart';
import '../screens/portees/portee_list_screen.dart';
import '../screens/portees/portee_detail_screen.dart';
import '../screens/portees/saillie_form_screen.dart';
import '../screens/main_shell_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isOnAuthRoute = state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/login';

      if (!isAuthenticated && !isOnAuthRoute) {
        return '/welcome';
      }

      if (isAuthenticated && isOnAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/lapins',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LapinListScreen(),
            ),
          ),
          GoRoute(
            path: '/portees',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PorteeListScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/lapin/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LapinDetailScreen(lapinId: id);
        },
      ),
      GoRoute(
        path: '/lapin/new',
        builder: (context, state) => const LapinFormScreen(),
      ),
      GoRoute(
        path: '/lapin/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LapinFormScreen(lapinId: id);
        },
      ),
      GoRoute(
        path: '/portee/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PorteeDetailScreen(porteeId: id);
        },
      ),
      GoRoute(
        path: '/saillie/new',
        builder: (context, state) {
          final mereId = state.uri.queryParameters['mereId'];
          return SaillieFormScreen(mereId: mereId);
        },
      ),
    ],
  );
}
