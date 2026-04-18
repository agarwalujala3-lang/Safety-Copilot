import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme/security_theme.dart';

class SafetyCopilotApp {
  static void run() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(
      ChangeNotifierProvider(
        create: (_) => AppState()..bootstrap(),
        child: const _RootApp(),
      ),
    );
  }
}

class _RootApp extends StatelessWidget {
  const _RootApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Copilot',
      debugShowCheckedModeBanner: false,
      theme: SecurityTheme.dark(),
      home: Consumer<AppState>(
        builder: (context, state, child) {
          if (!state.initialized) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!state.isAuthenticated) {
            return const LoginScreen();
          }
          return const DashboardScreen();
        },
      ),
      builder: (context, child) {
        if (AppConfig.isProd) {
          return child ?? const SizedBox.shrink();
        }
        return Banner(
          message: AppConfig.flavor.toUpperCase(),
          location: BannerLocation.topEnd,
          color: const Color(0xFFAF6A24),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
