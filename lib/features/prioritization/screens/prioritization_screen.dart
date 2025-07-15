import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioritize_requirements/features/prioritization/providers/projects_provider.dart';
import 'package:prioritize_requirements/features/projects/widgets/comparison_view.dart';
import 'package:prioritize_requirements/features/projects/widgets/finished_view.dart';
import 'package:prioritize_requirements/features/projects/widgets/initial_view.dart';

class PrioritizationScreen extends ConsumerWidget {
  const PrioritizationScreen({super.key, required this.projectId});
  final String projectId;

  void _showAddRequirementDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Requirement'),
          content: SizedBox( // NEW: Makes dialog wider
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Requirement'),
              onSubmitted: (_) { // Allow submitting with the enter key
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  ref
                      .read(projectsProvider.notifier)
                      .addRequirement(projectId, text);
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
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  ref
                      .read(projectsProvider.notifier)
                      .addRequirement(projectId, text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectsProvider.select(
      (projects) => projects.firstWhere((p) => p.id == projectId,
          orElse: () => ref.read(projectsProvider).first),
    ));

    final isInitialView = !project.isSorting && !project.isFinished;
    final canStartSorting = project.requirements.length >= 2;

    return Scaffold(
      // NEW: The floating action button is now a Row to hold both buttons
      resizeToAvoidBottomInset: false,

      floatingActionButton: isInitialView
          ? Padding(
              padding: const EdgeInsets.only(left: 32.0), // Aligns the Row correctly
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // The "Start" button, now an extended FAB style
                  ElevatedButton.icon(
                    onPressed: canStartSorting
                        ? () => ref
                            .read(projectsProvider.notifier)
                            .startSorting(projectId)
                        : null,
                    label: const Text('Start Prioritizing'),
                    icon: const Icon(Icons.swap_vert_rounded),
                  ),
                  // The "Add" button
                  FloatingActionButton(
                    onPressed: () => _showAddRequirementDialog(context, ref),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(project),
      ),
    );
  }

  Widget _buildBody(project) {
    if (project.isSorting) {
      return ComparisonView(
          key: const ValueKey('ComparisonView'), project: project);
    } else if (project.isFinished) {
      return FinishedView(key: const ValueKey('FinishedView'), project: project);
    } else {
      return InitialView(key: const ValueKey('InitialView'), project: project);
    }
  }
}