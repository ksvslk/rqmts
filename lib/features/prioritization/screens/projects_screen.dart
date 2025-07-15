import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:prioritize_requirements/features/prioritization/models/project_model.dart';
import 'package:prioritize_requirements/features/prioritization/providers/projects_provider.dart';
import 'package:prioritize_requirements/features/prioritization/screens/prioritization_screen.dart';
import 'package:prioritize_requirements/features/projects/widgets/project_card.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    _showProjectDialog(
      context: context,
      title: 'New Project',
      textController: textController,
      onSave: () {
        final name = textController.text.trim();
        if (name.isNotEmpty) {
          ref.read(projectsProvider.notifier).addProject(name);
        }
      },
    );
  }

  void _showEditProjectDialog(
      BuildContext context, WidgetRef ref, Project project) {
    final textController = TextEditingController(text: project.name);
    _showProjectDialog(
      context: context,
      title: 'Edit Project',
      textController: textController,
      onSave: () {
        final newName = textController.text.trim();
        if (newName.isNotEmpty) {
          ref.read(projectsProvider.notifier).editProjectName(project.id, newName);
        }
      },
    );
  }

  void _showProjectDialog({
    required BuildContext context,
    required String title,
    required TextEditingController textController,
    required VoidCallback onSave,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Project name'),
              onSubmitted: (_) {
                onSave();
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
                onSave();
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
    final projects = ref.watch(projectsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // The floatingActionButton property is removed. We will now handle it
      // manually with a Stack for perfect control.
      body: Stack(
        children: [
          // LAYER 1: The main screen content that is allowed to resize.
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Text(
                    'Projects',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 26,
                    ),
                  ),
                ),
                Expanded(
                  child: projects.isEmpty
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
                                'No projects yet.\nTap the + to add one!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onBackground
                                        .withOpacity(0.6)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Padding to ensure FAB doesn't hide last item
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            final project = projects[index];
                            return Slidable(
                              key: ValueKey(project.id),
                              endActionPane: ActionPane(
                                motion: const StretchMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) =>
                                        _showEditProjectDialog(context, ref, project),
                                    backgroundColor:
                                        theme.colorScheme.primary.withOpacity(0.8),
                                    foregroundColor: Colors.white,
                                    icon: Icons.edit,
                                    label: null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  SlidableAction(
                                    onPressed: (_) {
                                      ref
                                          .read(projectsProvider.notifier)
                                          .deleteProject(project.id);
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(SnackBar(
                                            content: Text(
                                                'Deleted project "${project.name}"')));
                                    },
                                    backgroundColor: theme.colorScheme.error,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: null,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ],
                              ),
                              child: ProjectCard(
                                project: project,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrioritizationScreen(
                                        projectId: project.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // LAYER 2: The Floating Action Button, positioned independently.
          // This will NOT move when the keyboard appears.
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _showAddProjectDialog(context, ref),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}