import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/interaction_provider.dart';
import '../providers/team_provider.dart';
import 'give_kudos_screen.dart';
import 'give_feedback_screen.dart';

class InteractionsScreen extends StatefulWidget {
  const InteractionsScreen({super.key});

  @override
  State<InteractionsScreen> createState() => _InteractionsScreenState();
}

class _InteractionsScreenState extends State<InteractionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showReceived = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interactions = context.watch<InteractionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kudos'),
            Tab(text: 'Feedback'),
          ],
        ),
        actions: [
          // Toggle sent/received
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Received')),
              ButtonSegment(value: false, label: Text('Sent')),
            ],
            selected: {_showReceived},
            onSelectionChanged: (selected) {
              setState(() => _showReceived = selected.first);
            },
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: interactions.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Kudos tab
                _InteractionList(
                  interactions: _showReceived
                      ? interactions.receivedKudos
                      : interactions.sentKudos,
                  emptyMessage: _showReceived
                      ? 'No kudos received yet'
                      : 'No kudos sent yet',
                  emptyIcon: Icons.emoji_emotions_outlined,
                  showFrom: _showReceived,
                ),
                // Feedback tab
                _InteractionList(
                  interactions: _showReceived
                      ? interactions.receivedFeedback
                      : interactions.sentFeedback,
                  emptyMessage: _showReceived
                      ? 'No feedback received yet'
                      : 'No feedback sent yet',
                  emptyIcon: Icons.feedback_outlined,
                  showFrom: _showReceived,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GiveKudosScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GiveFeedbackScreen()),
            );
          }
        },
        icon: Icon(
            _tabController.index == 0 ? Icons.emoji_emotions : Icons.feedback),
        label: Text(_tabController.index == 0 ? 'Give Kudos' : 'Give Feedback'),
      ),
    );
  }
}

class _InteractionList extends StatelessWidget {
  final List<Interaction> interactions;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool showFrom;

  const _InteractionList({
    required this.interactions,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.showFrom,
  });

  @override
  Widget build(BuildContext context) {
    if (interactions.isEmpty) {
      return _EmptyState(message: emptyMessage, icon: emptyIcon);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<InteractionProvider>().loadInteractions(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88), // Space for FAB
        itemCount: interactions.length,
        itemBuilder: (context, index) {
          final interaction = interactions[index];
          return _InteractionCard(
            interaction: interaction,
            showFrom: showFrom,
          );
        },
      ),
    );
  }
}

class _InteractionCard extends StatelessWidget {
  final Interaction interaction;
  final bool showFrom;

  const _InteractionCard({
    required this.interaction,
    required this.showFrom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final teamProvider = context.read<TeamProvider>();

    // Get display name for person
    String getDisplayName(String email) {
      final profile = teamProvider.memberProfiles[email];
      return profile?.displayName ?? email;
    }

    final personLabel = showFrom ? 'From' : 'To';
    final personEmail =
        showFrom ? interaction.from : interaction.withMembers.join(', ');
    final personName = showFrom
        ? getDisplayName(interaction.from)
        : interaction.withMembers.map(getDisplayName).join(', ');

    final isKudos = interaction.kind == InteractionKind.appreciation;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isKudos
                              ? colorScheme.primary
                              : colorScheme.secondary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isKudos ? Icons.emoji_emotions : Icons.feedback,
                      color:
                          isKudos ? colorScheme.primary : colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          personName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$personLabel: $personEmail',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(interaction.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (interaction.shared)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.public,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                interaction.note,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final teamProvider = context.read<TeamProvider>();

    String getDisplayName(String email) {
      final profile = teamProvider.memberProfiles[email];
      return profile?.displayName ?? email;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    interaction.kind == InteractionKind.appreciation
                        ? Icons.emoji_emotions
                        : Icons.feedback,
                    color: interaction.kind == InteractionKind.appreciation
                        ? colorScheme.primary
                        : colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    interaction.kind.label,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (interaction.shared)
                    const Chip(
                      avatar: Icon(Icons.public, size: 16),
                      label: Text('Shared'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                label: 'From',
                value: getDisplayName(interaction.from),
                subtitle: interaction.from,
              ),
              const SizedBox(height: 16),
              _DetailRow(
                label: 'To',
                value: interaction.withMembers.map(getDisplayName).join(', '),
                subtitle: interaction.withMembers.join(', '),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                label: 'Date',
                value: _formatFullDate(interaction.timestamp),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                interaction.note,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _DetailRow({
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
        if (subtitle != null && subtitle != value)
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
