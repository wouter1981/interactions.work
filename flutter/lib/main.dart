import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/interaction_provider.dart';
import 'providers/repository_provider.dart';
import 'providers/team_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InteractionsApp());
}

class InteractionsApp extends StatelessWidget {
  const InteractionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RepositoryProvider>(
          create: (_) => RepositoryProvider(),
          update: (_, auth, repo) => repo!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<RepositoryProvider, TeamProvider>(
          create: (_) => TeamProvider(),
          update: (_, repo, team) => team!..updateRepository(repo),
        ),
        ChangeNotifierProxyProvider3<AuthProvider, RepositoryProvider,
            TeamProvider, InteractionProvider>(
          create: (_) => InteractionProvider(),
          update: (_, auth, repo, team, interaction) =>
              interaction!..updateDependencies(auth, repo, team),
        ),
      ],
      child: const App(),
    );
  }
}
