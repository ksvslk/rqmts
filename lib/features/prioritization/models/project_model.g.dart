// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectAdapter extends TypeAdapter<Project> {
  @override
  final int typeId = 0;

  @override
  Project read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Project(
      id: fields[0] as String,
      name: fields[1] as String,
      requirements: (fields[2] as List).cast<Requirement>(),
      initialRequirements: (fields[3] as List).cast<Requirement>(),
      isSorting: fields[4] as bool,
      isFinished: fields[5] as bool,
      pass: fields[6] as int,
      comparison: fields[7] as int,
      parkedRequirements: (fields[8] as List).cast<Requirement>(),
    );
  }

  @override
  void write(BinaryWriter writer, Project obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.requirements)
      ..writeByte(3)
      ..write(obj.initialRequirements)
      ..writeByte(4)
      ..write(obj.isSorting)
      ..writeByte(5)
      ..write(obj.isFinished)
      ..writeByte(6)
      ..write(obj.pass)
      ..writeByte(7)
      ..write(obj.comparison)
      ..writeByte(8)
      ..write(obj.parkedRequirements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
