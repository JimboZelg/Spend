import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import '../models/transaction.dart';
import '../models/goal.dart';

class WalletProvider with ChangeNotifier {
  bool _isDarkMode = false; // Added variable to manage theme mode

  bool get isDarkMode => _isDarkMode; // Getter for theme mode

  static const String transactionsBoxName = 'transactions';
  static const String goalsBoxName = 'goals';
  static const String completedGoalsBoxName = 'completed_goals';
  
  late final Box<Transaction> _transactionsBox; // Marked as final
  late final Box<Goal> _goalsBox; // Marked as final
  late final Box<Goal> _completedGoalsBox; 
  
  List<Transaction> _transactions = [];
  List<Goal> _goals = [];
  List<Goal> _completedGoals = [];

  WalletProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      _transactionsBox = await Hive.openBox<Transaction>(transactionsBoxName);
      _goalsBox = await Hive.openBox<Goal>(goalsBoxName);
      _completedGoalsBox = await Hive.openBox<Goal>(completedGoalsBoxName);
      
      await loadData();
    } catch (e) {
      // Replace print with a logging mechanism
      debugPrint('Error initializing Hive: $e');
      _initializeDefaultData();
    }
  }

  void _initializeDefaultData() {
    _goals = [
      Goal(
        id: '1',
        name: 'Vacaciones',
        currentAmount: 10500,
        targetAmount: 15000,
        frequency: 'Mensual',
      ),
      Goal(
        id: '2',
        name: 'Titulación',
        currentAmount: 1000,
        targetAmount: 4000,
        frequency: 'Semanal',
      ),
      Goal(
        id: '3',
        name: 'GTA VI',
        currentAmount: 1260,
        targetAmount: 1400,
        frequency: 'Semanal',
      ),
    ];
  }

  Future<void> loadData() async {
    try {
      _transactions = _transactionsBox.values.toList();
      _goals = _goalsBox.values.toList();
      _completedGoals = _completedGoalsBox.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveTransactions() async {
    try {
      await _transactionsBox.clear();
      await _transactionsBox.addAll(_transactions);
    } catch (e) {
      debugPrint('Error saving transactions: $e');
    }
  }

  Future<void> _saveGoals() async {
    try {
      await _goalsBox.clear();
      await _goalsBox.addAll(_goals);
    } catch (e) {
      debugPrint('Error saving goals: $e');
    }
  }

  Future<void> _saveCompletedGoals() async {
    try {
      await _completedGoalsBox.clear();
      await _completedGoalsBox.addAll(_completedGoals);
    } catch (e) {
      debugPrint('Error saving completed goals: $e');
    }
  }

  List<Transaction> get transactions => _transactions;
  List<Goal> get goals => _goals;
  List<Goal> get completedGoals => _completedGoals;

  double get totalBalance {
    return _transactions.fold(0, (sum, transaction) {
      if (transaction.description != 'goal') {
        return sum + (transaction.isExpense ? -transaction.amount : transaction.amount);
      }
      return sum;
    });
  }

  double get totalIncome {
    return _transactions
        .where((t) => !t.isExpense && t.description != 'goal')
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  Future<void> toggleTheme() async { // Method to toggle theme
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> addTransaction(String description, Transaction transaction) async {


    final newTransaction = Transaction(
      id: transaction.id,
      amount: transaction.amount,
      category: transaction.category,
      date: transaction.date,
      isExpense: transaction.isExpense,
      description: description,
    );
    _transactions.add(newTransaction);

    await _saveTransactions();
    notifyListeners();
  }

  Future<void> addToGoal(String goalId, double amount) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final oldGoal = _goals[goalIndex];
      final newAmount = oldGoal.currentAmount + amount;
      
      if (newAmount >= oldGoal.targetAmount) {
        final completedGoal = oldGoal.copyWith(
          currentAmount: newAmount,
        );
        _completedGoals.add(completedGoal);
        _goals.removeAt(goalIndex);
        await _saveCompletedGoals();
        await _saveGoals();
      } else {
        _goals[goalIndex] = oldGoal.copyWith(
          currentAmount: newAmount,
        );
        await _saveGoals();
      }
      
      await addTransaction(
        'Meta: ${oldGoal.name}', // Provide a description for the transaction
        Transaction(
          id: DateTime.now().toString(),
          amount: amount,
          category: 'Meta: ${oldGoal.name}',
          date: DateTime.now(),
          isExpense: false,
          description: 'goal',
        ),
      );

      
      notifyListeners();
    }
  }

  Future<void> addNewGoal(String name, double targetAmount, DateTime startDate, DateTime endDate) async {

    final newGoal = Goal(
      id: DateTime.now().toString(),
      name: name,
      currentAmount: 0,
      targetAmount: targetAmount,
      frequency: 'Personalizado',
    );
    
    _goals.add(newGoal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _saveGoals();
      notifyListeners();
    }
  }
}
