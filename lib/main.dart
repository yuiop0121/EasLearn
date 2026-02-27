import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edupulse_ai/core/theme/app_theme.dart';
import 'package:edupulse_ai/firebase_options.dart';
import 'package:edupulse_ai/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We assume google-services.json is present, but if not, this might crash in debug.
  // In a real scenario, we'd handle the error or checking.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase init success");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  runApp(const ProviderScope(child: EduPulseApp()));
}

class EduPulseApp extends StatelessWidget {
  const EduPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EasLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
