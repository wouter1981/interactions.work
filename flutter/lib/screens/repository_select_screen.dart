import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/github_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/repository_provider.dart';

class RepositorySelectScreen extends StatefulWidget {
  const RepositorySelectScreen({super.key});

  @override
  State<RepositorySelectScreen> createState() => _RepositorySelectScreenState();
}

class _RepositorySelectScreenState extends State<RepositorySelectScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyWritable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepositoryProvider>().fetchRepositories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GitHubRepository> _filterRepositories(List<GitHubRepository> repos) {
    var filtered = repos;

    // Filter by write access
    if (_showOnlyWritable) {
      filtered = filtered.where((r) => r.canWrite).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) {
        return r.name.toLowerCase().contains(query) ||
            r.fullName.toLowerCase().contains(query) ||
            (r.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Repository'),
        actions: [
          // User avatar and logout
          if (auth.user != null)
            PopupMenuButton<String>(
              offset: const Offset(0, 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(auth.user!.avatarUrl),
                    ),
                    const SizedBox(width: 8),
                    Text(auth.user!.login),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text('Sign out', style: TextStyle(color: colorScheme.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  auth.logout();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search repositories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),

                // Filter chip
                Row(
                  children: [
                    FilterChip(
                      label: const Text('Write access only'),
                      selected: _showOnlyWritable,
                      onSelected: (value) {
                        setState(() => _showOnlyWritable = value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Repository list
          Expanded(
            child: Consumer<RepositoryProvider>(
              builder: (context, repoProvider, _) {
                if (repoProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (repoProvider.error != null) {
                  return _ErrorView(
                    message: repoProvider.error!,
                    onRetry: () {
                      repoProvider.clearError();
                      repoProvider.fetchRepositories();
                    },
                  );
                }

                final filtered = _filterRepositories(repoProvider.repositories);

                if (filtered.isEmpty) {
                  return _EmptyView(
                    hasSearch: _searchQuery.isNotEmpty,
                    hasFilter: _showOnlyWritable,
                    onClearFilters: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _showOnlyWritable = false;
                      });
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => repoProvider.fetchRepositories(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _RepositoryCard(
                        repository: filtered[index],
                        onTap: () {
                          repoProvider.selectRepository(filtered[index]);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RepositoryCard extends StatelessWidget {
  final GitHubRepository repository;
  final VoidCallback onTap;

  const _RepositoryCard({
    required this.repository,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Repository name and visibility
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(repository.owner.avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          repository.fullName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (repository.owner.isOrganization)
                          Text(
                            'Organization',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Visibility badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: repository.private
                          ? colorScheme.secondaryContainer
                          : colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          repository.private ? Icons.lock : Icons.public,
                          size: 14,
                          color: repository.private
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          repository.private ? 'Private' : 'Public',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: repository.private
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description
              if (repository.description != null &&
                  repository.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  repository.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Permissions
              const SizedBox(height: 12),
              Row(
                children: [
                  if (repository.isAdmin)
                    _PermissionChip(
                      icon: Icons.admin_panel_settings,
                      label: 'Admin',
                      color: colorScheme.primary,
                    ),
                  if (repository.canWrite && !repository.isAdmin)
                    _PermissionChip(
                      icon: Icons.edit,
                      label: 'Write',
                      color: colorScheme.secondary,
                    ),
                  if (!repository.canWrite)
                    _PermissionChip(
                      icon: Icons.visibility,
                      label: 'Read only',
                      color: colorScheme.outline,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PermissionChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load repositories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool hasSearch;
  final bool hasFilter;
  final VoidCallback onClearFilters;

  const _EmptyView({
    required this.hasSearch,
    required this.hasFilter,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch || hasFilter
                  ? 'No matching repositories'
                  : 'No repositories found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch || hasFilter
                  ? 'Try adjusting your search or filters'
                  : 'Create a repository on GitHub to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            if (hasSearch || hasFilter) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
