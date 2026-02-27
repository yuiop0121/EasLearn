import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupulse_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:edupulse_ai/features/chat/presentation/chat_screen.dart';
import 'package:edupulse_ai/features/grading/presentation/grading_screen.dart';
import 'package:edupulse_ai/features/memory_bank/presentation/memory_bank_screen.dart';
import 'package:edupulse_ai/core/widgets/scaffold_with_navigation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavigation(navigationShell: navigationShell);
      },
      branches: [
        // Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Chat
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
        // Grading
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/grading',
              builder: (context, state) => const GradingScreen(),
            ),
          ],
        ),
        // Memory Bank
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/memory-bank',
              builder: (context, state) => const MemoryBankScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
