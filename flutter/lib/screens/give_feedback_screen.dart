import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/interaction_provider.dart';
import '../providers/team_provider.dart';

class GiveFeedbackScreen extends StatefulWidget {
  const GiveFeedbackScreen({super.key});

  @override
  State<GiveFeedbackScreen> createState() => _GiveFeedbackScreenState();
}

class _GiveFeedbackScreenState extends State<GiveFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final Set<String> _selectedRecipients = {};
  bool _shareWithTeam = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.watch<AuthProvider>();
    final team = context.watch<TeamProvider>();
    final interactions = context.watch<InteractionProvider>();

    final currentUserEmail = auth.user?.email;
    final members = team.getAllMembers().where(
          (m) => m.member.email != currentUserEmail,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Give Feedback'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.secondaryContainer,
                    colorScheme.tertiaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.feedback,
                    size: 48,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share constructive feedback',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Help your teammate grow',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recipients
            Text(
              'To',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (members.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No team members available',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: members.map((m) {
                  final isSelected =
                      _selectedRecipients.contains(m.member.email);
                  return FilterChip(
                    label: Text(m.member.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRecipients.add(m.member.email);
                        } else {
                          _selectedRecipients.remove(m.member.email);
                        }
                      });
                    },
                    avatar: isSelected
                        ? null
                        : CircleAvatar(
                            backgroundColor: colorScheme.secondaryContainer,
                            child: Text(
                              m.member.displayName[0].toUpperCase(),
                              style: TextStyle(
                                color: colorScheme.onSecondaryContainer,
                                fontSize: 12,
                              ),
                            ),
                          ),
                  );
                }).toList(),
              ),
            if (_selectedRecipients.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Select at least one recipient',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Message
            Text(
              'Feedback',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Share your constructive feedback...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your feedback';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Share with team
            SwitchListTile(
              value: _shareWithTeam,
              onChanged: (value) => setState(() => _shareWithTeam = value),
              title: const Text('Share with team'),
              subtitle:
                  const Text('Make this feedback visible to all team members'),
              secondary: Icon(
                _shareWithTeam ? Icons.public : Icons.lock_outline,
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (interactions.saveError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  interactions.saveError!,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),

            // Submit button
            FilledButton.icon(
              onPressed: interactions.isSaving
                  ? null
                  : () => _submit(context, currentUserEmail),
              icon: interactions.isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send),
              label:
                  Text(interactions.isSaving ? 'Sending...' : 'Send Feedback'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context, String? fromEmail) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRecipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one recipient')),
      );
      return;
    }
    if (fromEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine your email')),
      );
      return;
    }

    final interactions = context.read<InteractionProvider>();
    final success = await interactions.giveFeedback(
      from: fromEmail,
      to: _selectedRecipients.toList(),
      note: _noteController.text,
      shared: _shareWithTeam,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback sent!')),
      );
      Navigator.pop(context);
    }
  }
}
