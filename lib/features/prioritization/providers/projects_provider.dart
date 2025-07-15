import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioritize_requirements/features/prioritization/models/project_model.dart';
import 'package:prioritize_requirements/features/prioritization/models/requirement_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// CHANGED: This function no longer creates a sample project.
// It simply reads from the box. If the box is empty, it correctly
// returns an empty list.
List<Project> _readProjectsFromHive() {
  final box = Hive.box<Project>('projects');
  return box.values.toList();
}

class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super(_readProjectsFromHive());

  Future<void> _saveStateToHive() async {
    final box = Hive.box<Project>('projects');
    await box.clear();
    for (final project in state) {
      await box.put(project.id, project);
    }
  }

  // --- PROJECT MANAGEMENT ---
  void addProject(String name) {
    // CHANGED: A new project now starts with a completely empty list of requirements.
    const List<Requirement> emptyReqs = [];
    final newProject = Project(
      id: _uuid.v4(),
      name: name,
      requirements: emptyReqs,
      initialRequirements: emptyReqs,
    );
    state = [...state, newProject];
    _saveStateToHive();
  }

  void editProjectName(String projectId, String newName) {
    final project = state.firstWhere((p) => p.id == projectId);
    _updateProject(project.copyWith(name: newName));
  }

  void deleteProject(String projectId) {
    state = state.where((project) => project.id != projectId).toList();
    _saveStateToHive();
  }

  // --- REQUIREMENT MANAGEMENT ---
  void addRequirement(String projectId, String text) {
    final newRequirement = Requirement(id: _uuid.v4(), text: text);
    final project = state.firstWhere((p) => p.id == projectId);
    
    final updatedProject = project.copyWith(
      requirements: [...project.requirements, newRequirement],
      initialRequirements: [...project.initialRequirements, newRequirement],
    );
    _updateProject(updatedProject);
  }

  void editRequirementText(
      String projectId, String requirementId, String newText) {
    final project = state.firstWhere((p) => p.id == projectId);

    Requirement update(Requirement req) =>
        req.id == requirementId ? req.copyWith(text: newText) : req;

    final updatedRequirements = project.requirements.map(update).toList();
    final updatedInitialRequirements =
        project.initialRequirements.map(update).toList();
    
    _updateProject(project.copyWith(
      requirements: updatedRequirements,
      initialRequirements: updatedInitialRequirements,
    ));
  }

  void deleteRequirement(String projectId, String requirementId) {
    final project = state.firstWhere((p) => p.id == projectId);
    
    final updatedRequirements =
        project.requirements.where((r) => r.id != requirementId).toList();
    final updatedInitialRequirements =
        project.initialRequirements.where((r) => r.id != requirementId).toList();

    final updatedProject = project.copyWith(
      requirements: updatedRequirements,
      initialRequirements: updatedInitialRequirements,
    );
    _updateProject(updatedProject);
  }

  void toggleRequirementDone(String projectId, String requirementId) {
    final project = state.firstWhere((p) => p.id == projectId);
    
    Requirement toggle(Requirement req) => req.id == requirementId
        ? req.copyWith(isDone: !req.isDone)
        : req;

    final updatedRequirements = project.requirements.map(toggle).toList();
    final updatedInitialRequirements =
        project.initialRequirements.map(toggle).toList();

    _updateProject(project.copyWith(
      requirements: updatedRequirements,
      initialRequirements: updatedInitialRequirements,
    ));
  }

  // --- SORTING & WORKFLOW LOGIC ---
  void _updateProject(Project updatedProject) {
    state = [
      for (final project in state)
        if (project.id == updatedProject.id) updatedProject else project,
    ];
    _saveStateToHive();
  }

  void startSorting(String projectId) {
    final project = state.firstWhere((p) => p.id == projectId);
    final undoneReqs = project.initialRequirements.where((r) => !r.isDone).toList();
    final doneReqs = project.initialRequirements.where((r) => r.isDone).toList();

    final sortingProject = project.copyWith(
      requirements: undoneReqs,
      initialRequirements: doneReqs,
      isSorting: true,
      isFinished: false,
      pass: 0,
      comparison: 0,
    );
     _updateProject(sortingProject);
  }
  
  void resetProject(String projectId) {
    final project = state.firstWhere((p) => p.id == projectId);
    _updateProject(project.copyWith(
      requirements: project.initialRequirements,
      isSorting: false,
      isFinished: false,
      pass: 0,
      comparison: 0,
    ));
  }
  
  void cancelSorting(String projectId) {
    final project = state.firstWhere((p) => p.id == projectId);
    _updateProject(project.copyWith(
      requirements: project.initialRequirements,
      isSorting: false
      ));
  }

  void userMadeChoice(String projectId, Requirement chosenRequirement) {
    final project = state.firstWhere((p) => p.id == projectId);
    if (!project.isSorting) return;

    final currentList = List<Requirement>.from(project.requirements);
    final i = project.pass;
    final j = project.comparison;

    if (j + 1 >= currentList.length) {
      _finishSorting(project, currentList);
      return;
    }

    final item1 = currentList[j];
    final item2 = currentList[j + 1];

    if (chosenRequirement.id == item2.id) {
      currentList[j] = item2;
      currentList[j + 1] = item1;
    }

    int nextComparison = j + 1;
    int nextPass = i;

    if (nextComparison >= currentList.length - i - 1) {
      nextPass++;
      nextComparison = 0;
    }

    if (nextPass >= currentList.length - 1 || currentList.length < 2) {
      _finishSorting(project, currentList);
    } else {
      _updateProject(project.copyWith(
        requirements: currentList,
        pass: nextPass,
        comparison: nextComparison,
      ));
    }
  }

  void _finishSorting(Project project, List<Requirement> sortedList) {
    final doneItems = project.initialRequirements;
    final finalFullList = [...sortedList, ...doneItems];
    
    _updateProject(project.copyWith(
      requirements: finalFullList,
      initialRequirements: finalFullList,
      isSorting: false,
      isFinished: true,
    ));
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier();
});