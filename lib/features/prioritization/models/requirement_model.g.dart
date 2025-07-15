// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequirementAdapter extends TypeAdapter<Requirement> {
  @override
  final int typeId = 1;

  @override
  Requirement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Requirement(
      id: fields[0] as String,
      text: fields[1] as String,
      isDone: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Requirement obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.isDone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequirementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
