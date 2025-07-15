import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:prioritize_requirements/features/prioritization/models/project_model.dart';
import 'package:prioritize_requirements/features/prioritization/models/requirement_model.dart';
import 'package:prioritize_requirements/features/prioritization/providers/projects_provider.dart';
import 'package:prioritize_requirements/features/projects/widgets/requirement_card.dart';

class InitialView extends ConsumerWidget {
  const InitialView({super.key, required this.project});
  final Project project;

  void _showEditRequirementDialog(
      BuildContext context, WidgetRef ref, Requirement requirement) {
    final textController = TextEditingController(text: requirement.text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Requirement'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Requirement text...'),
              onSubmitted: (_) {
                final newText = textController.text.trim();
                if (newText.isNotEmpty) {
                  ref.read(projectsProvider.notifier).editRequirementText(
                      project.id, requirement.id, newText);
                }
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newText = textController.text.trim();
                if (newText.isNotEmpty) {
                  ref.read(projectsProvider.notifier).editRequirementText(
                      project.id, requirement.id, newText);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canStartSorting =
        project.requirements.where((r) => !r.isDone).length >= 2;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  project.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 26,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 10.0),
                child: Text(
                  'Requirements',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: project.requirements.isEmpty
                ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/sleeping.png',
                                width: 150,
                                opacity: const AlwaysStoppedAnimation(0.6),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No requirements yet.\nTap the + to add one!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.6)),
                              ),
                            ],
                          ),
                        )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: project.requirements.length,
                    itemBuilder: (context, index) {
                      final requirement = project.requirements[index];
                      return Slidable(
                        key: ValueKey(requirement.id),
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => _showEditRequirementDialog(
                                  context, ref, requirement),
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.8),
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
              
                              borderRadius: BorderRadius.circular(12),
                            ),
                            SlidableAction(
                              onPressed: (_) {
                                ref
                                    .read(projectsProvider.notifier)
                                    .deleteRequirement(
                                        project.id, requirement.id);
                              },
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ),
                        // CHANGED: Pass the projectId to the card
                        child: RequirementCard(
                          projectId: project.id,
                          requirement: requirement,
                        ),
                      );
                    },
                  ),
          ),
          if (!canStartSorting && project.requirements.any((r) => !r.isDone))
            Padding(
              padding: const EdgeInsets.only(bottom: 90.0),
              child: Text(
                'Add at least 2 unfinished requirements to start.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}