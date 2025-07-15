import 'package:flutter/material.dart';
import 'package:prioritize_requirements/features/prioritization/models/project_model.dart';

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
      // ClipRRect ensures the corner triangle is neatly clipped to the card's rounded border
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // --- Main Card Content ---
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
                // --- NEW: Simple, subtle corner triangle ---
                Positioned(
                  top: 0,
                  left: 0,
                  child: ClipPath(
                    clipper: _TopLeftCornerTriangleClipper(),
                    child: Container(
                      width: 30, // The size of the triangle's base
                      height: 30, // The size of the triangle's height
                      color: colorScheme.primary.withOpacity(0.2), // Subtle color
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

// A custom clipper to create a simple triangle in the top-left corner.
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