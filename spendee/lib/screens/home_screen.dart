import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/goals_section.dart';
import '../widgets/mascot_feedback.dart';
import 'history_screen.dart';
import 'juegos_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la meta',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cantidad objetivo',
                prefixText: '\$',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text);
              
              if (name.isNotEmpty && amount != null && amount > 0) {
                context.read<WalletProvider>().addNewGoal(
                  name,
                  amount,
                  DateTime.now(), // Default start date
                  DateTime.now().add(const Duration(days: 30)), // Default end date
                );

                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Divisa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Dólares (USD)'),
                onTap: () {
                  // Implement conversion logic for USD
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Euros (EUR)'),
                onTap: () {
                  // Implement conversion logic for EUR
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Pesos Mexicanos (MXN)'),
                onTap: () {
                  // Implement conversion logic for MXN
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Spendee',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              context.read<WalletProvider>().toggleTheme(); // Toggle theme on button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.monetization_on, color: Colors.white), // Currency selection button
            onPressed: () => _showCurrencyDialog(context),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Spendee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gestiona tus finanzas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history), // Icon for Historial
              title: const Text('Historial'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.games), // Icon for Juegos
              title: const Text('Juegos'), // New button for Juegos
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JuegosScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SummaryCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TransactionCard(
                      title: 'Gastos',
                      amount: context.watch<WalletProvider>().totalExpenses,
                      isExpense: true,
                      description: 'Total Expenses', // Added description
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TransactionCard(
                      title: 'Ingresos',
                      amount: context.watch<WalletProvider>().totalIncome,
                      isExpense: false,
                      description: 'Total Income', // Added description
                    ),
                  ),
                ],
              ),
            ),
            const GoalsSection(),
            const MascotFeedback(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
