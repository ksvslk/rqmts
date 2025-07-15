import 'package:hive/hive.dart';

part 'requirement_model.g.dart';

@HiveType(typeId: 1)
class Requirement extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String text;

  @HiveField(2) // NEW HIVE FIELD
  final bool isDone;

  Requirement({
    required this.id,
    required this.text,
    this.isDone = false, // Defaults to not done
  });

  Requirement copyWith({
    String? id,
    String? text,
    bool? isDone,
  }) {
    return Requirement(
      id: id ?? this.id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }
}