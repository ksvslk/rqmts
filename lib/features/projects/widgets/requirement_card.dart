import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioritize_requirements/features/prioritization/models/requirement_model.dart';
import 'package:prioritize_requirements/features/prioritization/providers/projects_provider.dart';

// CHANGED: The card is now a ConsumerWidget to interact with the provider.
class RequirementCard extends ConsumerWidget {
  const RequirementCard({
    super.key,
    required this.projectId, // NEW: Needed to update the correct project
    required this.requirement,
    this.onTap,
    this.isSelectable = false,
    this.isPrioritized = false,
    this.rank,
  });

  final String projectId;
  final Requirement requirement;
  final VoidCallback? onTap;
  final bool isSelectable;
  final bool isPrioritized;
  final int? rank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define the style for the text based on the done state
    final textStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      decoration:
          requirement.isDone ? TextDecoration.lineThrough : TextDecoration.none,
      decorationThickness: 2.0,
      color: requirement.isDone
          ? colorScheme.onSurface.withOpacity(0.5)
          : colorScheme.onSurface,
    );

    // Define the style for the rank number based on the done state
    final rankStyle = theme.textTheme.bodyLarge?.copyWith(
      color: requirement.isDone
          ? colorScheme.primary.withOpacity(0.6)
          : colorScheme.primary,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    final cardContent = Material(
      // The card itself is dimmed when done
      color: requirement.isDone
          ? colorScheme.surface.withOpacity(0.7)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // The tap action is now conditional
        onTap: isSelectable
            ? onTap // In comparison view, use the passed onTap
            : () { // In list view, toggle the done state
                ref
                    .read(projectsProvider.notifier)
                    .toggleRequirementDone(projectId, requirement.id);
              },
        borderRadius: BorderRadius.circular(12),
        splashColor: colorScheme.primary.withOpacity(0.2),
        highlightColor: colorScheme.primary.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? colorScheme.onSurface.withOpacity(0.1)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPrioritized && rank != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      '$rank.',
                      style: rankStyle, // Apply conditional rank style
                    ),
                  ),
                Expanded(
                  child: Text(
                    requirement.text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign:
                        isPrioritized ? TextAlign.start : TextAlign.center,
                    style: textStyle, // Apply conditional text style
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: cardContent,
    );
  }
}