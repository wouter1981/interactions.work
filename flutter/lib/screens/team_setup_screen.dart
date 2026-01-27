import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/repository_provider.dart';
import '../providers/team_provider.dart';

class TeamSetupScreen extends StatefulWidget {
  const TeamSetupScreen({super.key});

  @override
  State<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manifestoController = TextEditingController();
  final _visionController = TextEditingController();

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Pre-fill team name with repository name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<RepositoryProvider>().selectedRepository;
      if (repo != null && _nameController.text.isEmpty) {
        _nameController.text = repo.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manifestoController.dispose();
    _visionController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final team = context.read<TeamProvider>();

    await team.createTeam(
      name: _nameController.text.trim(),
      manifesto: _manifestoController.text.trim().isEmpty
          ? null
          : _manifestoController.text.trim(),
      vision: _visionController.text.trim().isEmpty
          ? null
          : _visionController.text.trim(),
      leaderEmail: auth.user?.email ?? auth.user?.login ?? 'unknown',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final repoProvider = context.watch<RepositoryProvider>();
    final teamProvider = context.watch<TeamProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Team'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: teamProvider.isLoading
              ? null
              : () => repoProvider.clearSelection(),
        ),
      ),
      body: teamProvider.state == TeamState.checking
          ? const _CheckingTeamView()
          : teamProvider.state == TeamState.creating
              ? const _CreatingTeamView()
              : Form(
                  key: _formKey,
                  child: Stepper(
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _createTeam();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            FilledButton(
                              onPressed: details.onStepContinue,
                              child: Text(
                                _currentStep == 2 ? 'Create Team' : 'Continue',
                              ),
                            ),
                            if (_currentStep > 0) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: details.onStepCancel,
                                child: const Text('Back'),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    steps: [
                      // Step 1: Team Name
                      Step(
                        title: const Text('Team Name'),
                        subtitle: const Text('What is your team called?'),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Team Name',
                                hintText: 'e.g., Engineering Team',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a team name';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'This will be the display name for your team.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Step 2: Manifesto
                      Step(
                        title: const Text('Manifesto'),
                        subtitle: const Text('Define your team culture'),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _manifestoController,
                              decoration: const InputDecoration(
                                labelText: 'Team Manifesto (optional)',
                                hintText:
                                    'e.g., We value open communication, continuous learning, and mutual respect...',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 5,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'A manifesto defines the behavior norms and cultural principles your team strives for. '
                                      'Members commit to following these principles.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Step 3: Vision
                      Step(
                        title: const Text('Vision'),
                        subtitle: const Text('Set your team goals'),
                        isActive: _currentStep >= 2,
                        state: _currentStep > 2
                            ? StepState.complete
                            : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _visionController,
                              decoration: const InputDecoration(
                                labelText: 'Team Vision (optional)',
                                hintText:
                                    'e.g., To build the most reliable and user-friendly platform...',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 5,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    size: 20,
                                    color: colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'A vision describes what your team aims to achieve. '
                                      'It provides direction and inspiration for team members.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (teamProvider.error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: colorScheme.onErrorContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        teamProvider.error!,
                                        style: TextStyle(
                                          color: colorScheme.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: colorScheme.onErrorContainer,
                                      ),
                                      onPressed: () =>
                                          teamProvider.clearError(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _CheckingTeamView extends StatelessWidget {
  const _CheckingTeamView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Checking for existing team...'),
        ],
      ),
    );
  }
}

class _CreatingTeamView extends StatelessWidget {
  const _CreatingTeamView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Creating your team...',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Setting up the repository structure',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SetupStep(icon: Icons.check, label: 'Creating interactions branch'),
                  const SizedBox(height: 8),
                  _SetupStep(icon: Icons.check, label: 'Adding team configuration'),
                  const SizedBox(height: 8),
                  _SetupStep(icon: Icons.hourglass_empty, label: 'Setting up directories'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupStep extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SetupStep({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: icon == Icons.check
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
