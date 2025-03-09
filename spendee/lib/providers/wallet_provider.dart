import 'package:flutter/material.dart';
import '../models/goal.dart'; // Ensure the Goal model is imported
import '../models/transaction.dart'; // Ensure the Transaction model is imported

class WalletProvider with ChangeNotifier {
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _totalGoals = 0.0;
  String _selectedCurrency = 'MXN'; // Default currency
  final Map<String, double> _conversionRates = {
    'USD': 20.0, // 1 USD = 20 MXN
    'EUR': 22.0, // 1 EUR = 22 MXN
    'MXN': 1.0,  // 1 MXN = 1 MXN
  };

  List<Goal> _goals = []; // List to store goals as Goal objects
  List<Transaction> _transactions = []; // Change to store transactions as Transaction objects
  bool _isDarkMode = false; // Theme state

  double get totalIncome => _convertAmount(_totalIncome);
  double get totalExpenses => _convertAmount(_totalExpenses);
  double get totalGoals => _convertAmount(_totalGoals);
  String get selectedCurrency => _selectedCurrency;
  List<Goal> get goals => _goals; // Getter for goals
  List<Transaction> get transactions => _transactions; // Change to return Transaction objects
  bool get isDarkMode => _isDarkMode; // Getter for theme state
  double get totalBalance => totalIncome - totalExpenses; // Getter for total balance

  List<Goal> get completedGoals => _goals.where((goal) => goal.isCompleted).toList(); // Getter for completed goals

  void addNewGoal(String name, double amount, DateTime startDate, DateTime endDate) {
    // Logic to add a new goal
    _goals.add(Goal(id: UniqueKey().toString(), name: name, currentAmount: 0, targetAmount: amount, frequency: 'Monthly')); // Create a Goal object
    _totalGoals += amount;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) {
    if (transaction.isExpense) {
        _totalExpenses += transaction.amount; // Update total expenses
    } else {
        _totalIncome += transaction.amount; // Update total income
    }
    _transactions.add(transaction); // Logic to add a transaction


    notifyListeners();
  }

  void addToGoal(String goalId, double amount) {
    // Logic to add amount to a specific goal
    notifyListeners();
  }

  void toggleTheme() {
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
