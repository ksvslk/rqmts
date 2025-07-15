import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rqmts/features/prioritization/models/project_model.dart';
import 'package:rqmts/features/prioritization/providers/projects_provider.dart';
import 'package:rqmts/features/projects/widgets/requirement_card.dart';

class ComparisonView extends ConsumerWidget {
  const ComparisonView({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orientation = MediaQuery.of(context).orientation;

    return SafeArea(
      child: orientation == Orientation.portrait
          ? _buildPortraitLayout(context, ref)
          : _buildLandscapeLayout(context, ref),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, WidgetRef ref) {
    final item1 = project.requirements[project.comparison];
    final item2 = project.requirements[project.comparison + 1];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Text('Which is more important?',
              textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: RequirementCard(
              requirement: item1,
              isSelectable: true,
              onTap: () => ref
                  .read(projectsProvider.notifier)
                  .userMadeChoice(project.id, item1), projectId: project.id,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('or',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, color: theme.colorScheme.onBackground.withOpacity(0.5))),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: RequirementCard(
              requirement: item2,
              isSelectable: true,
              onTap: () => ref
                  .read(projectsProvider.notifier)
                  .userMadeChoice(project.id, item2), projectId: project.id,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: TextButton(
            onPressed: () =>
                ref.read(projectsProvider.notifier).cancelSorting(project.id),
            child: const Text('Cancel Sorting'),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, WidgetRef ref) {
    final item1 = project.requirements[project.comparison];
    final item2 = project.requirements[project.comparison + 1];
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text('Which is more important?',
              textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: RequirementCard(
                    requirement: item1,
                    isSelectable: true,
                    onTap: () => ref
                        .read(projectsProvider.notifier)
                        .userMadeChoice(project.id, item1), projectId: project.id,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text('or',
                      style: TextStyle(
                          fontSize: 20,
                          color: theme.colorScheme.onBackground.withOpacity(0.5))),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                  child: RequirementCard(
                    requirement: item2,
                    isSelectable: true,
                    onTap: () => ref
                        .read(projectsProvider.notifier)
                        .userMadeChoice(project.id, item2), projectId: project.id,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextButton(
            onPressed: () =>
                ref.read(projectsProvider.notifier).cancelSorting(project.id),
            child: const Text('Cancel Sorting'),
          ),
        ),
      ],
    );
  }
}