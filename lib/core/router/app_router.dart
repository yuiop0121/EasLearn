import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edupulse_ai/features/dashboard/presentation/dashboard_screen.dart';
import 'package:edupulse_ai/features/chat/presentation/chat_screen.dart';
import 'package:edupulse_ai/features/grading/presentation/grading_screen.dart';
import 'package:edupulse_ai/features/question_bank/presentation/question_bank.dart';
import 'package:edupulse_ai/core/widgets/scaffold_with_navigation.dart';
import 'package:edupulse_ai/features/dashboard/presentation/login_page.dart'; // NEW: Import Login Page

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    // NEW: Login Route 
    // Kept outside the StatefulShellRoute so it doesn't show the bottom navigation bar
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

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
        // Question Bank
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/question-bank',
              builder: (context, state) => const QuestionBankPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
