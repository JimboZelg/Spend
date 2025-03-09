import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'goal.dart';

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 1; // Ensure the typeId is set correctly

  @override
  Goal read(BinaryReader reader) {
    // Read the fields in the same order they were written


    return Goal(
      id: reader.read(),
      name: reader.read(),
      currentAmount: reader.read(),
      targetAmount: reader.read(),
      frequency: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    // Write the fields in the same order they were read


    writer
      ..write(obj.id)
      ..write(obj.name)
      ..write(obj.currentAmount)
      ..write(obj.targetAmount)
      ..write(obj.frequency);
  }
}
