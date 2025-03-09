import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/completed_goals_widget.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction.dart';
import '../models/goal.dart'; // Ensure Goal is imported

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAscending = true; // Track sorting order

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    List<Transaction> transactions = walletProvider.transactions;
    List<Goal> completedGoals = List.from(walletProvider.completedGoals); // Assuming this exists

    // Sort transactions based on the current sorting order
    transactions.sort((a, b) => _isAscending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));

    // Sort completed goals based on the current sorting order
    completedGoals.sort((a, b) => _isAscending 
      ? (a.targetAmount).compareTo(b.targetAmount) 
      : (b.targetAmount).compareTo(a.targetAmount));

    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Historial'),
            Tab(text: 'Metas Completadas'),
          ],
        ),
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement date filtering logic here
              _showDateFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.swap_vert), // Changed icon to swap_vert
            onPressed: () {
              // Toggle sorting logic
              setState(() {
                _isAscending = !_isAscending; // Toggle the sorting state
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Increased margin for spacing
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Increased border radius
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Added padding for spacing
                  title: Text(
                    transaction.category,
                    style: TextStyle(
                      color: transaction.isExpense ? Colors.red : Colors.green, // Set color based on transaction type
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    transaction.date.toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  tileColor: Colors.lightBlue[50],
                  trailing: Text('\$${transaction.amount.toStringAsFixed(2)}', style: TextStyle(color: transaction.isExpense ? Colors.red : Colors.green)),
                  onTap: () {
                    // Show transaction description in a dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(transaction.category),
                        content: Text(transaction.description), // Display the description
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          CompletedGoalsWidget(isAscending: _isAscending), // Pass sorting state to completed goals
        ],
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    // Show a dialog to select date range for filtering
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por fecha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add date picker widgets here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Implement filtering logic based on selected dates
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }
}
