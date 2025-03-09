import 'package:hive_ce/hive.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final double amount;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final DateTime date;
  
  @HiveField(4)
  final bool isExpense;
  
  @HiveField(5)
  final String description;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.isExpense,
    required this.description,
  });
}
