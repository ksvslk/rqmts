import 'package:hive/hive.dart';
import 'package:rqmts/features/prioritization/models/requirement_model.dart';

part 'project_model.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  final List<Requirement> requirements;
  @HiveField(3)
  final List<Requirement> initialRequirements;
  @HiveField(4)
  final bool isSorting;
  @HiveField(5)
  final bool isFinished;
  @HiveField(6)
  final int pass;
  @HiveField(7)
  final int comparison;
  @HiveField(8)
  final List<Requirement> parkedRequirements;
  @HiveField(9)
  final Map<String, String> comparisonWinners;

  Project({
    required this.id,
    required this.name,
    this.requirements = const [],
    this.initialRequirements = const [],
    this.isSorting = false,
    this.isFinished = false,
    this.pass = 0,
    this.comparison = 0,
    this.parkedRequirements = const [],
    this.comparisonWinners = const {},
  });
  
  // =======================================================
  // THE FIX IS HERE: Add a computed property (getter) to the model.
  // =======================================================
  bool get isFullyComplete {
    // A project is only "fully complete" if it actually has requirements
    // and every single one of them is marked as done.
    if (requirements.isEmpty) {
      return false;
    }
    return requirements.every((req) => req.isDone);
  }

  Project copyWith({
    String? id,
    String? name,
    List<Requirement>? requirements,
    List<Requirement>? initialRequirements,
    bool? isSorting,
    bool? isFinished,
    int? pass,
    int? comparison,
    List<Requirement>? parkedRequirements,
    Map<String, String>? comparisonWinners,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      requirements: requirements ?? this.requirements,
      initialRequirements: initialRequirements ?? this.initialRequirements,
      isSorting: isSorting ?? this.isSorting,
      isFinished: isFinished ?? this.isFinished,
      pass: pass ?? this.pass,
      comparison: comparison ?? this.comparison,
      parkedRequirements: parkedRequirements ?? this.parkedRequirements,
      comparisonWinners: comparisonWinners ?? this.comparisonWinners,
    );
  }
}
