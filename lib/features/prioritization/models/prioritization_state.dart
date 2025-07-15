import 'package:flutter/foundation.dart';
import 'package:prioritize_requirements/features/prioritization/models/requirement_model.dart';

@immutable
class PrioritizationState {
  final List<Requirement> requirements;
  final bool isSorting;
  final bool isFinished;
  final int pass; // i in bubble sort
  final int comparison; // j in bubble sort

  const PrioritizationState({
    required this.requirements,
    this.isSorting = false,
    this.isFinished = false,
    this.pass = 0,
    this.comparison = 0,
  });

  PrioritizationState copyWith({
    List<Requirement>? requirements,
    bool? isSorting,
    bool? isFinished,
    int? pass,
    int? comparison,
  }) {
    return PrioritizationState(
      requirements: requirements ?? this.requirements,
      isSorting: isSorting ?? this.isSorting,
      isFinished: isFinished ?? this.isFinished,
      pass: pass ?? this.pass,
      comparison: comparison ?? this.comparison,
    );
  }
}