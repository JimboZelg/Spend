import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart'; // Importar hive_ce
import 'package:hive_ce_flutter/hive_flutter.dart'; // Importar hive_ce Flutter
import '../models/goal.dart'; // Asegurarse de que se importe el modelo Goal
import '../models/transaction.dart'; // Asegurarse de que se importe el modelo Transaction

class WalletProvider with ChangeNotifier {
  // Inicializar Hive
  Future<void> initHive() async {
    await Hive.openBox<Goal>('goals'); // Abrir caja de metas
    await Hive.openBox<Transaction>('transactions'); // Abrir caja de transacciones
    await loadExistingData(); // Cargar datos existentes de Hive
  }

  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _totalGoals = 0.0; // Monto total de metas

  String _selectedCurrency = 'MXN'; // Moneda predeterminada
  final Map<String, double> _conversionRates = {
    'USD': 20.0, // 1 USD = 20 MXN
    'EUR': 22.0, // 1 EUR = 22 MXN
    'MXN': 1.0,  // 1 MXN = 1 MXN
  };

  final List<Goal> _goals = []; // Lista para almacenar metas como objetos Goal
  final List<Goal> _completedGoals = []; // Lista para almacenar metas completadas
  final List<Transaction> _transactions = []; // Lista para almacenar transacciones como objetos Transaction

  bool _isDarkMode = false; // Estado del tema

  double get totalIncome => _convertAmount(_totalIncome);
  double get totalExpenses => _convertAmount(_totalExpenses);
  double get totalGoals => _convertAmount(_totalGoals);
  String get selectedCurrency => _selectedCurrency;
  List<Goal> get goals => _goals; // Getter para la lista de metas
  List<Goal> get completedGoals => _completedGoals; // Getter para las metas completadas

  List<Transaction> get transactions => _transactions; // Cambiar para devolver objetos Transaction
  bool get isDarkMode => _isDarkMode; // Getter para el estado del tema
  double get totalBalance => totalIncome - totalExpenses; // Getter para el saldo total

  Future<void> loadExistingData() async {
    final goalsBox = Hive.box<Goal>('goals');
    final transactionsBox = Hive.box<Transaction>('transactions');

    _goals.addAll(goalsBox.values.toList()); // Cargar metas existentes
    _transactions.addAll(transactionsBox.values.toList()); // Cargar transacciones existentes

    // Calcular ingresos, gastos y metas totales a partir de los datos cargados
    _totalGoals = _goals.fold(0, (sum, goal) => sum + goal.targetAmount);
    _totalIncome = _transactions.where((t) => !t.isExpense).fold(0, (sum, t) => sum + t.amount);
    _totalExpenses = _transactions.where((t) => t.isExpense).fold(0, (sum, t) => sum + t.amount);

    notifyListeners(); // Notificar a los oyentes sobre los cambios
  }

  void addNewGoal(String name, double amount, DateTime startDate, DateTime endDate) { // Método para agregar una nueva meta
    // Guardar la nueva meta en Hive
    final goal = Goal(id: UniqueKey().toString(), name: name, currentAmount: 0, targetAmount: amount, frequency: 'Monthly');
    _goals.add(goal);
    final goalsBox = Hive.box<Goal>('goals');
    goalsBox.add(goal);

    _totalGoals += amount;
    notifyListeners();
  }

  void addTransaction(Transaction transaction) { // Método para agregar una transacción
    // Guardar la transacción en Hive
    final transactionsBox = Hive.box<Transaction>('transactions');
    try {
        transactionsBox.add(transaction);
    } catch (e) {
        // Manejar el error (por ejemplo, registrarlo o mostrar un mensaje al usuario)
        print('Error al agregar transacción: $e');
    }

    if (transaction.isExpense) {
        _totalExpenses += transaction.amount; // Actualizar gastos totales
    } else {
        _totalIncome += transaction.amount; // Actualizar ingresos totales
    }
    _transactions.add(transaction); // Lógica para agregar una transacción
    if (transaction.goalId != null) { // Verificar si la transacción está relacionada con una meta
        addToGoal(transaction.goalId!, transaction.amount); // Actualizar la meta con el monto de la transacción
    }

    notifyListeners();
  }

  void addToGoal(String goalId, double amount) {
    // Lógica para agregar monto a una meta específica
    final goal = _goals.firstWhere((g) => g.id == goalId); // Encontrar la meta por ID
    final updatedAmount = goal.currentAmount + amount; // Calcular el monto actualizado
    final transaction = Transaction(
        id: UniqueKey().toString(),
        amount: amount,
        category: goal.name, // Usar el nombre de la meta como categoría
        date: DateTime.now(),
        isExpense: false,
        description: 'Contribución a la meta: ${goal.name}',
    );
    _transactions.add(transaction); // Agregar la transacción a la historia

    // Actualizar el monto actual de la meta y guardarlo de nuevo en Hive
    final updatedGoal = goal.copyWith(currentAmount: updatedAmount); // Crear una nueva instancia de meta con el monto actualizado
    final goalsBox = Hive.box<Goal>('goals');
    
    // Verificar si la meta se completa después de actualizar
    if (updatedGoal.currentAmount >= updatedGoal.targetAmount) {
        // Solo agregar a metas completadas si no está ya allí
        if (!_completedGoals.any((g) => g.id == updatedGoal.id)) {
            _completedGoals.add(updatedGoal); // Agregar a metas completadas
            goalsBox.delete(goalId); // Eliminar la meta de las metas activas en Hive
        }
    } else {
        goalsBox.put(goalId, updatedGoal); // Guardar la meta actualizada de nuevo en Hive
        _goals[_goals.indexOf(goal)] = updatedGoal; // Reemplazar la antigua meta con la nueva
    }

    notifyListeners(); // Notificar a los oyentes para actualizar la interfaz de usuario
  }

  void toggleTheme() { // Método para alternar el tema
    _isDarkMode = !_isDarkMode; // Alternar el estado del tema
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
