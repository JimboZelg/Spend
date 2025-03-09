import 'package:flutter/material.dart';
import '../models/goal.dart'; // Ensure the Goal model is imported
import '../models/transaction.dart'; // Ensure the Transaction model is imported

class WalletProvider with ChangeNotifier {
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _totalGoals = 0.0; // Total goals amount

  String _selectedCurrency = 'MXN'; // Default currency
  final Map<String, double> _conversionRates = {
    'USD': 20.0, // 1 USD = 20 MXN
    'EUR': 22.0, // 1 EUR = 22 MXN
    'MXN': 1.0,  // 1 MXN = 1 MXN
  };

  final List<Goal> _goals = []; // List to store goals as Goal objects
  final List<Goal> _completedGoals = []; // List to store completed goals
  final List<Transaction> _transactions = []; // Change to store transactions as Transaction objects

  bool _isDarkMode = false; // Theme state

  double get totalIncome => _convertAmount(_totalIncome);
  double get totalExpenses => _convertAmount(_totalExpenses);
  double get totalGoals => _convertAmount(_totalGoals);
  String get selectedCurrency => _selectedCurrency;
  List<Goal> get goals => _goals; // Getter for goals list
  List<Goal> get completedGoals => _completedGoals; // Getter for completed goals

  List<Transaction> get transactions => _transactions; // Change to return Transaction objects
  bool get isDarkMode => _isDarkMode; // Getter for theme state
  double get totalBalance => totalIncome - totalExpenses; // Getter for total balance

  void addNewGoal(String name, double amount, DateTime startDate, DateTime endDate) { // Method to add a new goal

    // Logic to add a new goal
    _goals.add(Goal(id: UniqueKey().toString(), name: name, currentAmount: 0, targetAmount: amount, frequency: 'Monthly')); // Create a Goal object
    _totalGoals += amount;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) { // Method to add a transaction

    if (transaction.isExpense) {
        _totalExpenses += transaction.amount; // Update total expenses
    } else {
        _totalIncome += transaction.amount; // Update total income
    }
    _transactions.add(transaction); // Logic to add a transaction
    if (transaction.goalId != null) { // Check if the transaction is related to a goal
        addToGoal(transaction.goalId!, transaction.amount); // Update the goal with the transaction amount
    }



    notifyListeners();
  }

  void addToGoal(String goalId, double amount) {
    // Logic to add amount to a specific goal
    final goal = _goals.firstWhere((g) => g.id == goalId); // Find the goal by ID
    final updatedAmount = goal.currentAmount + amount; // Calculate the updated amount
    if (updatedAmount > goal.targetAmount) { // Check if the updated amount exceeds the target
        _totalIncome += updatedAmount - goal.targetAmount; // Add the excess to total income
        amount = goal.targetAmount - goal.currentAmount; // Adjust the amount to only reach the target
    }
    final transaction = Transaction(
        id: UniqueKey().toString(),
        amount: amount,
        category: goal.name, // Use the name of the goal as the category

        date: DateTime.now(),
        isExpense: false,
        description: 'Contribution to goal: ${goal.name}',
    );
    _transactions.add(transaction); // Add the transaction to the history
    // Check if the goal is completed after updating
    final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + amount); // Create a new goal instance with updated amount
    if (updatedGoal.currentAmount >= updatedGoal.targetAmount) {
        _completedGoals.add(updatedGoal); // Add to completed goals
        _goals.removeWhere((g) => g.id == goalId); // Remove the goal from active goals
    } else {
        _goals[_goals.indexOf(goal)] = updatedGoal; // Replace the old goal with the updated one
    }
    notifyListeners();
  }

  void toggleTheme() { // Method to toggle theme

    _isDarkMode = !_isDarkMode; // Toggle theme state
    notifyListeners();
  }

  void changeCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  double _convertAmount(double amount) {
    return amount / _conversionRates[_selectedCurrency]!;
  }
}
