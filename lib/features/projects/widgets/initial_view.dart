import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:prioritize_requirements/features/prioritization/models/project_model.dart';
import 'package:prioritize_requirements/features/prioritization/models/requirement_model.dart';
import 'package:prioritize_requirements/features/prioritization/providers/projects_provider.dart';
import 'package:prioritize_requirements/features/projects/widgets/requirement_card.dart';

class InitialView extends ConsumerStatefulWidget {
  const InitialView({super.key, required this.project});
  final Project project;

  @override
  ConsumerState<InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends ConsumerState<InitialView> {
  Requirement? _editingRequirement;
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
        _editingRequirement = null;
      });
    } else {
      setState(() {});
    }
  }

  void _startEditing(Requirement requirement) {
    setState(() {
      _editingRequirement = requirement;
    });
    _inputFocusNode.requestFocus();
  }

  void _finishEditing() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isInputActive = _inputFocusNode.hasFocus;
    
    final canStartSorting =
        widget.project.requirements.where((r) => !r.isDone).length >= 2;
    final hasUnfinishedReqs =
        widget.project.requirements.any((r) => !r.isDone);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        if (isInputActive) {
          _finishEditing();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          AbsorbPointer(
            absorbing: isInputActive,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 140.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            widget.project.name,
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
                              color:
                                  theme.colorScheme.onBackground.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: widget.project.requirements.isEmpty
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
                                    'No requirements yet.\nAdd one below!',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onBackground
                                            .withOpacity(0.6)),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: widget.project.requirements.length,
                              itemBuilder: (context, index) {
                                final requirement =
                                    widget.project.requirements[index];
                                return Slidable(
                                  key: ValueKey(requirement.id),
                                  endActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: isInputActive
                                        ? []
                                        : [
                                            SlidableAction(
                                              onPressed: (_) =>
                                                  _startEditing(requirement),
                                              backgroundColor: theme
                                                  .colorScheme.primary
                                                  .withOpacity(0.8),
                                              foregroundColor: Colors.white,
                                              icon: Icons.edit,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            SlidableAction(
                                              onPressed: (_) {
                                                ref
                                                    .read(
                                                        projectsProvider.notifier)
                                                    .deleteRequirement(
                                                        widget.project.id,
                                                        requirement.id);
                                              },
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ],
                                  ),
                                  child: RequirementCard(
                                    projectId: widget.project.id,
                                    requirement: requirement,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isInputActive)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 24, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: canStartSorting
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(projectsProvider.notifier)
                                      .startSorting(widget.project.id);
                                },
                                icon: const Icon(Icons.play_arrow_sharp),
                                label: const Text('Start Prioritizing'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              )
                            : hasUnfinishedReqs
                                ? Text(
                                    'Add at least 2 unfinished requirements to start.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.5),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  
                  // Reference to the new, correct widget.
                  _AddRequirementInput(
                    projectId: widget.project.id,
                    editingRequirement: _editingRequirement,
                    focusNode: _inputFocusNode,
                    onFinished: _finishEditing,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// THE FIX IS HERE: The new _AddRequirementInput widget, implemented correctly.
// ===========================================================================
class _AddRequirementInput extends ConsumerStatefulWidget {
  final String projectId;
  final Requirement? editingRequirement;
  final FocusNode focusNode;
  final VoidCallback onFinished;

  const _AddRequirementInput({
    required this.projectId,
    this.editingRequirement,
    required this.focusNode,
    required this.onFinished,
  });

  @override
  ConsumerState<_AddRequirementInput> createState() =>
      _AddRequirementInputState();
}

class _AddRequirementInputState extends ConsumerState<_AddRequirementInput> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field if we are editing an existing requirement.
    if (widget.editingRequirement != null) {
      _controller.text = widget.editingRequirement!.text;
    }
  }

  @override
  void didUpdateWidget(covariant _AddRequirementInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This handles the state change when the user taps the "Edit" button.
    if (widget.editingRequirement != oldWidget.editingRequirement) {
      if (widget.editingRequirement != null) {
        // We are now editing, so update the controller's text.
        _controller.text = widget.editingRequirement!.text;
        // Move the cursor to the end of the text.
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      } else {
        // We are back in "add" mode, so clear the controller.
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// This method intelligently decides whether to add or edit a requirement.
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (widget.editingRequirement != null) {
      // We are in edit mode.
      ref.read(projectsProvider.notifier).editRequirementText(
            widget.projectId,
            widget.editingRequirement!.id,
            text,
          );
    } else {
      // We are in add mode.
      ref.read(projectsProvider.notifier).addRequirement(widget.projectId, text);
    }

    // After submitting, decide what to do next.
    if (widget.editingRequirement == null) {
      // If we were adding, clear the text to allow adding another quickly.
      _controller.clear();
      widget.focusNode.requestFocus();
    } else {
      // If we were editing, call the callback to exit edit mode.
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isEditing = widget.editingRequirement != null;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            // Conditionally show a "Cancel" button only when editing.
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
                  hintText: isEditing ? 'Edit requirement...' : 'Add new requirement...',
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
            // Conditionally change the icon based on the mode.
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