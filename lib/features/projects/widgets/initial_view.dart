import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rqmts/features/prioritization/models/project_model.dart';
import 'package:rqmts/features/prioritization/models/requirement_model.dart';
import 'package:rqmts/features/prioritization/providers/projects_provider.dart';
import 'package:rqmts/features/projects/widgets/requirement_card.dart';

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
    if (mounted) {
      setState(() {
        if (!_inputFocusNode.hasFocus) {
          _editingRequirement = null;
        }
      });
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
 final bool isListEmpty = widget.project.requirements.isEmpty;
    final canStartSorting =
        widget.project.requirements.where((r) => !r.isDone).length >= 2;
    final hasUnfinishedReqs = widget.project.requirements.any((r) => !r.isDone);

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
           padding: EdgeInsets.only(bottom: isListEmpty ? 70 : 140.0),
              child: SafeArea(
                bottom: false, // Prevents layout jank
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Replace your existing header Column with this Row structure:

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
                                  widget.project.name,
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
                                    'Requirements',
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
                      child: widget.project.requirements.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    // 👈 Wrap the Image with Flexible
                                    child: Image.asset(
                                      'assets/icons/awake.png',
                                      // No need for a fixed width here, Flexible handles it.
                                      width: 150,
                                      fit: BoxFit.scaleDown,
                                      opacity:
                                          const AlwaysStoppedAnimation(0.6),
                                    ),
                                  ),
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
                                                    .read(projectsProvider
                                                        .notifier)
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
          AnimatedOpacity(
            opacity: isInputActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !isInputActive,
              child: GestureDetector(
                onTap: _finishEditing,
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                ),
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
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: canStartSorting
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(projectsProvider.notifier)
                                      .startSorting(widget.project.id);
                                },
                                icon: const Icon(Icons.move_up),
                                label: const Text('Start Prioritizing'),
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
    if (widget.editingRequirement != null) {
      _controller.text = widget.editingRequirement!.text;
    }
  }

  @override
  void didUpdateWidget(covariant _AddRequirementInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editingRequirement != oldWidget.editingRequirement) {
      if (widget.editingRequirement != null) {
        _controller.text = widget.editingRequirement!.text;
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
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (widget.editingRequirement != null) {
      ref.read(projectsProvider.notifier).editRequirementText(
            widget.projectId,
            widget.editingRequirement!.id,
            text,
          );
    } else {
      ref
          .read(projectsProvider.notifier)
          .addRequirement(widget.projectId, text);
    }

    if (widget.editingRequirement == null) {
      _controller.clear();
      widget.focusNode.requestFocus();
    } else {
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
                  hintText: isEditing ? 'Edit requirement' : 'New requirement',
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
