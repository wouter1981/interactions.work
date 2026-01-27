import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/repository_provider.dart';
import 'providers/team_provider.dart';
import 'screens/login_screen.dart';
import 'screens/repository_select_screen.dart';
import 'screens/team_setup_screen.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, RepositoryProvider, TeamProvider>(
      builder: (context, auth, repo, team, _) {
        // Not logged in -> show login
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // Logged in but no repository selected -> show repo selection
        if (repo.selectedRepository == null) {
          return const RepositorySelectScreen();
        }

        // Repository selected but team not initialized -> show setup
        if (!team.isInitialized) {
          return const TeamSetupScreen();
        }

        // Everything ready -> show home
        return const HomeScreen();
      },
    );
  }
}
