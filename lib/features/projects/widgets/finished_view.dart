import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rqmts/features/prioritization/models/project_model.dart';
import 'package:rqmts/features/prioritization/models/requirement_model.dart';
import 'package:rqmts/features/prioritization/providers/projects_provider.dart';
import 'package:rqmts/features/projects/widgets/requirement_card.dart';
import 'package:share_plus/share_plus.dart';

class FinishedView extends ConsumerWidget {
  const FinishedView({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    String _formatNumberedList(List<Requirement> reqs) {
      return reqs.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final text = entry.value.text;
        return '$index. $text';
      }).join('\n');
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =======================================================
          // THE FIX IS HERE: The header is now styled like InitialView.
          // =======================================================
       Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button on the left
                          IconButton(
                            icon: Platform.isAndroid
                                ? const Icon(Icons.arrow_back)
                                : const Icon(Icons.arrow_back_ios_new),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            iconSize: 24,
                            color: theme.colorScheme.onSurface,
                          ),
                          // Expanded center section for title and subtitle
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  project.name,
                                  textAlign: TextAlign.center,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 26,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 10.0),
                                  child: Text(
                                    'Prioritized',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Invisible spacer to balance the layout
                          const SizedBox(width: 48), // Same width as IconButton
                        ],
                      ),
                    ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: project.requirements.length,
              itemBuilder: (context, index) {
                return RequirementCard(
                  requirement: project.requirements[index],
                  isPrioritized: true,
                  rank: index + 1, 
                  projectId: project.id,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.format_list_numbered,
                  label: 'Copy List',
                  onPressed: () {
                    final listToCopy = _formatNumberedList(project.requirements);
                    Clipboard.setData(ClipboardData(text: listToCopy));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                          const SnackBar(content: Text('Copied list')));
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.notes,
                  label: 'Copy Text',
                  onPressed: () {
                    final textToCopy =
                        project.requirements.map((req) => req.text).join('\n');
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                          const SnackBar(content: Text('Copied text')));
                  },
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onPressed: () {
                    final listToShare = _formatNumberedList(project.requirements);
                    Share.share(listToShare, subject: 'Prioritized List: ${project.name}');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: ElevatedButton(
              child: const Text('Edit & Re-sort'),
              onPressed: () {
                ref.read(projectsProvider.notifier).resetProject(project.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Material(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          splashColor: colorScheme.primary.withOpacity(0.2),
          highlightColor: colorScheme.primary.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}