import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rqmts/features/prioritization/providers/projects_provider.dart';
import 'package:rqmts/features/projects/widgets/comparison_view.dart';
import 'package:rqmts/features/projects/widgets/finished_view.dart';
import 'package:rqmts/features/projects/widgets/initial_view.dart';

class PrioritizationScreen extends ConsumerWidget {
  const PrioritizationScreen({super.key, required this.projectId});
  final String projectId;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectsProvider.select(
      (projects) => projects.firstWhere((p) => p.id == projectId,
          orElse: () => ref.read(projectsProvider).first),
    ));
    return Scaffold(
      // NEW: The floating action button is now a Row to hold both buttons
      resizeToAvoidBottomInset: false,
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