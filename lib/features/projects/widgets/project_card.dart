import 'package:flutter/material.dart';
import 'package:rqmts/features/prioritization/models/project_model.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    Color _getCornerColor() {
      // =======================================================
      // THE FIX IS HERE: Check the new property first.
      // =======================================================

      // State 1: All requirements are striked off.
      if (project.isFullyComplete) {
        // A muted, gray-ish color signifies "archived" or "all done".
        return colorScheme.primary.withOpacity(0.2); 
      }
      // State 2: Prioritization is finished.
      else if (project.isFinished) {
        return colorScheme.primary.withOpacity(0.75); 
      } 
      // State 3: Sorting is in progress.
      else if (project.isSorting) {
        return colorScheme.tertiaryContainer;
      } 
      // State 4: Default (Not sorted).
      else {
        return colorScheme.onSurfaceVariant.withOpacity(0.5);
      }
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          project.name,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: ClipPath(
                    clipper: _TopLeftCornerTriangleClipper(),
                    child: Container(
                      width: 30,
                      height: 30,
                      color: _getCornerColor(),
                    ),
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

class _TopLeftCornerTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}