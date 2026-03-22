import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rqmts/features/prioritization/models/project_model.dart';
import 'package:rqmts/features/prioritization/models/requirement_model.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String _comparisonKey(String leftId, String rightId) {
  return leftId.compareTo(rightId) < 0
      ? '$leftId|$rightId'
      : '$rightId|$leftId';
}

List<Project> _readProjectsFromHive() {
  final box = Hive.box<Project>('projects');
  return box.values.toList();
}

class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super(_readProjectsFromHive());

  // Using a more efficient save method that doesn't require clearing the box.
  Future<void> _saveProjectToHive(Project project) async {
    final box = Hive.box<Project>('projects');
    await box.put(project.id, project);
  }

  Future<void> _deleteProjectFromHive(String projectId) async {
    final box = Hive.box<Project>('projects');
    await box.delete(projectId);
  }


  // --- PROJECT MANAGEMENT ---
  Future<String> addProject(String name) async {
    const List<Requirement> emptyReqs = [];
    final newProject = Project(
      id: _uuid.v4(),
      name: name,
      requirements: emptyReqs,
      initialRequirements: emptyReqs,
    );
    state = [newProject, ...state];
    await _saveProjectToHive(newProject); // Assuming _saveProjectToHive is your Hive method
    return newProject.id;
  }

  void editProjectName(String projectId, String newName) {
    final project = state.firstWhere((p) => p.id == projectId);
    _updateProject(project.copyWith(name: newName));
  }

  void deleteProject(String projectId) {
    state = state.where((project) => project.id != projectId).toList();
    _deleteProjectFromHive(projectId);
  }

  // --- REQUIREMENT MANAGEMENT ---
  void addRequirement(String projectId, String text) {
    final newRequirement = Requirement(id: _uuid.v4(), text: text);
    final project = state.firstWhere((p) => p.id == projectId);
    
    final updatedProject = project.copyWith(
      requirements: [newRequirement, ...project.requirements],
      initialRequirements: [newRequirement, ...project.initialRequirements],
    );
    _updateProject(updatedProject);
  }

  void editRequirementText(
      String projectId, String requirementId, String newText) {
    final project = state.firstWhere((p) => p.id == projectId);
    Requirement update(Requirement req) =>
        req.id == requirementId ? req.copyWith(text: newText) : req;
    final updatedProject = project.copyWith(
      requirements: project.requirements.map(update).toList(),
      initialRequirements: project.initialRequirements.map(update).toList(),
    );
    _updateProject(updatedProject);
  }

  void deleteRequirement(String projectId, String requirementId) {
    final project = state.firstWhere((p) => p.id == projectId);
    final updatedProject = project.copyWith(
      requirements:
          project.requirements.where((r) => r.id != requirementId).toList(),
      initialRequirements:
          project.initialRequirements.where((r) => r.id != requirementId).toList(),
    );
    _updateProject(updatedProject);
  }

  void toggleRequirementDone(String projectId, String requirementId) {
    final project = state.firstWhere((p) => p.id == projectId);
    Requirement toggle(Requirement req) => req.id == requirementId
        ? req.copyWith(isDone: !req.isDone)
        : req;
    final updatedProject = project.copyWith(
      requirements: project.requirements.map(toggle).toList(),
      initialRequirements: project.initialRequirements.map(toggle).toList(),
    );
    _updateProject(updatedProject);
  }

  // --- SORTING & WORKFLOW LOGIC (Corrected) ---
  void _updateProject(Project updatedProject) {
    state = [
      for (final project in state)
        if (project.id == updatedProject.id) updatedProject else project,
    ];
    _saveProjectToHive(updatedProject);
  }

  void startSorting(String projectId) {
    final project = state.firstWhere((p) => p.id == projectId);
    final undoneReqs =
        project.initialRequirements.where((r) => !r.isDone).toList();
    final doneReqs = project.initialRequirements.where((r) => r.isDone).toList();

    final sortingProject = project.copyWith(
      requirements: undoneReqs,
      parkedRequirements: doneReqs,
      comparisonWinners: const {},
      isSorting: true,
      isFinished: false,
      pass: 0,
      comparison: 0,
    );

    _advanceSorting(
      sortingProject,
      List<Requirement>.from(undoneReqs),
      pass: 0,
      comparison: 0,
      comparisonWinners: const {},
    );
  }
  
  void resetProject(String projectId) {
    final project = state.firstWhere((p) => p.id == projectId);
    _updateProject(project.copyWith(
      requirements: project.initialRequirements,
      parkedRequirements: [],
      comparisonWinners: const {},
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
      parkedRequirements: [],
      comparisonWinners: const {},
      isSorting: false,
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
    if (chosenRequirement.id != item1.id && chosenRequirement.id != item2.id) {
      return;
    }

    final comparisonWinners = {
      ...project.comparisonWinners,
      _comparisonKey(item1.id, item2.id): chosenRequirement.id,
    };

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

    _advanceSorting(
      project,
      currentList,
      pass: nextPass,
      comparison: nextComparison,
      comparisonWinners: comparisonWinners,
    );
  }

  void _advanceSorting(
    Project project,
    List<Requirement> currentList, {
    required int pass,
    required int comparison,
    required Map<String, String> comparisonWinners,
  }) {
    var nextPass = pass;
    var nextComparison = comparison;

    while (currentList.length >= 2 && nextPass < currentList.length - 1) {
      if (nextComparison + 1 >= currentList.length) {
        break;
      }

      final item1 = currentList[nextComparison];
      final item2 = currentList[nextComparison + 1];
      final cachedWinnerId =
          comparisonWinners[_comparisonKey(item1.id, item2.id)];

      if (cachedWinnerId == null ||
          (cachedWinnerId != item1.id && cachedWinnerId != item2.id)) {
        _updateProject(project.copyWith(
          requirements: currentList,
          pass: nextPass,
          comparison: nextComparison,
          comparisonWinners: comparisonWinners,
          isSorting: true,
        ));
        return;
      }

      if (cachedWinnerId == item2.id) {
        currentList[nextComparison] = item2;
        currentList[nextComparison + 1] = item1;
      }

      nextComparison++;
      if (nextComparison >= currentList.length - nextPass - 1) {
        nextPass++;
        nextComparison = 0;
      }
    }

    _finishSorting(project, currentList);
  }

  void _finishSorting(Project project, List<Requirement> sortedList) {
    final doneItems = project.parkedRequirements;
    final finalFullList = [...sortedList, ...doneItems];
    
    _updateProject(project.copyWith(
      requirements: finalFullList,
      initialRequirements: finalFullList,
      parkedRequirements: [],
      comparisonWinners: const {},
      isSorting: false,
      isFinished: true,
      pass: 0,
      comparison: 0,
    ));
  }
}

// NOTE: This provider initialization is the source of the "flash" on app start.
// While it works, the ideal solution would be to use an AsyncNotifier or
// override the provider in main.dart as discussed previously.
final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier();
});
