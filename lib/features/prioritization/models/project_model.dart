import 'package:hive_flutter/hive_flutter.dart';
import 'package:prioritize_requirements/features/prioritization/models/requirement_model.dart';
part 'project_model.g.dart'; 

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

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

  Project({
    required this.id,
    required this.name,
    required this.requirements,
    required this.initialRequirements,
    this.isSorting = false,
    this.isFinished = false,
    this.pass = 0,
    this.comparison = 0,
  });

  Project copyWith({
    String? id,
    String? name,
    List<Requirement>? requirements,
    List<Requirement>? initialRequirements,
    bool? isSorting,
    bool? isFinished,
    int? pass,
    int? comparison,
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
    );
  }
}