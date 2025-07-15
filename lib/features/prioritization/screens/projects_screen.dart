import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:prioritize_requirements/features/prioritization/models/project_model.dart';
import 'package:prioritize_requirements/features/prioritization/providers/projects_provider.dart';
import 'package:prioritize_requirements/features/prioritization/screens/prioritization_screen.dart';
import 'package:prioritize_requirements/features/projects/widgets/project_card.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  Project? _editingProject;
  final _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_inputFocusNode.hasFocus) {
      setState(() {
        _editingProject = null;
      });
    } else {
      setState(() {});
    }
  }

  void _startEditing(Project project) {
    setState(() {
      _editingProject = project;
    });
    _inputFocusNode.requestFocus();
  }

  void _finishEditing() {
    _inputFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isInputActive = _inputFocusNode.hasFocus;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AbsorbPointer(
            absorbing: isInputActive,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: SafeArea(
                bottom: false,
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
                                    'No projects yet.\nAdd one below!',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onBackground
                                            .withOpacity(0.6)),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                final project = projects[index];
                                return Slidable(
                                  key: ValueKey(project.id),
                                  endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    extentRatio: 0.5,
                                    children: isInputActive
                                        ? []
                                        : [
                                            SlidableAction(
                                              onPressed: (_) =>
                                                  _startEditing(project),
                                              backgroundColor: theme
                                                  .colorScheme.primary
                                                  .withOpacity(0.8),
                                              foregroundColor: Colors.white,
                                              icon: Icons.edit,
                                              label: null,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            SlidableAction(
                                              onPressed: (_) {
                                                ref
                                                    .read(projectsProvider
                                                        .notifier)
                                                    .deleteProject(project.id);
                                              },
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete,
                                              label: null,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ],
                                  ),
                                  child: ProjectCard(
                                    project: project,
                                    // =======================================================
                                    // THE FIX IS HERE: The navigation code was missing and is now restored.
                                    // =======================================================
                                    onTap: () {
                                      // Unfocus before navigating away to prevent keyboard issues on return.
                                      _inputFocusNode.unfocus();
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              PrioritizationScreen(
                                            projectId: project.id,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 250),
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
            ),
          ),
          
          if (isInputActive)
            GestureDetector(
              onTap: _finishEditing,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isInputActive ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, -keyboardHeight, 0),
              child: _AddProjectInput(
                editingProject: _editingProject,
                focusNode: _inputFocusNode,
                onFinished: _finishEditing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// The _AddProjectInput widget is unchanged.
class _AddProjectInput extends ConsumerStatefulWidget {
  final Project? editingProject;
  final FocusNode focusNode;
  final VoidCallback onFinished;

  const _AddProjectInput({
    this.editingProject,
    required this.focusNode,
    required this.onFinished,
  });

  @override
  ConsumerState<_AddProjectInput> createState() => _AddProjectInputState();
}

class _AddProjectInputState extends ConsumerState<_AddProjectInput> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editingProject != null) {
      _controller.text = widget.editingProject!.name;
    }
  }

  @override
  void didUpdateWidget(covariant _AddProjectInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingProject != oldWidget.editingProject) {
      if (widget.editingProject != null) {
        _controller.text = widget.editingProject!.name;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      } else {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    if (widget.editingProject != null) {
      ref.read(projectsProvider.notifier).editProjectName(
            widget.editingProject!.id,
            name,
          );
    } else {
      ref.read(projectsProvider.notifier).addProject(name);
    }

    if (widget.editingProject == null) {
      _controller.clear();
      widget.focusNode.requestFocus();
    } else {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEditing = widget.editingProject != null;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.cancel_outlined),
                onPressed: widget.onFinished,
              ),
            Expanded(
              child: TextField(
                focusNode: widget.focusNode,
                controller: _controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  hintText: isEditing ? 'Rename project...' : 'Add new project...',
                  counterText: "",
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isEditing ? Icons.check_circle : Icons.add_circle),
              iconSize: 32,
              color: colorScheme.primary,
              onPressed: _submit,
            )
          ],
        ),
      ),
    );
  }
}