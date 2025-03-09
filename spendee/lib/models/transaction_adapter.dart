import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0; // Ensure the typeId is set correctly

  @override
  Transaction read(BinaryReader reader) {
    return Transaction(
      id: reader.read(),
      amount: reader.read(),
      category: reader.read(),
      date: reader.read(),
      isExpense: reader.read(),
      description: reader.read(),
      goalId: reader.read(), // Read the optional goalId
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..write(obj.id)
      ..write(obj.amount)
      ..write(obj.category)
      ..write(obj.date)
      ..write(obj.isExpense)
      ..write(obj.description)
      ..write(obj.goalId); // Write the optional goalId
  }
}
