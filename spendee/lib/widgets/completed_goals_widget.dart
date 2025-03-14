import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/goal.dart';

class CompletedGoalsWidget extends StatefulWidget {
  final bool isAscending; // Accept sorting state from HistoryScreen

  const CompletedGoalsWidget({super.key, required this.isAscending});

  @override
  _CompletedGoalsWidgetState createState() => _CompletedGoalsWidgetState();
}

class _CompletedGoalsWidgetState extends State<CompletedGoalsWidget> {
  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    List<Goal> completedGoals = walletProvider.completedGoals; // Assuming this exists
    if (completedGoals.isEmpty) { // Check if there are no completed goals
      return Center(child: Text('No completed goals available.')); // Display message if no goals
    }

    // Sort the completed goals based on the current sorting order
    completedGoals.sort((a, b) => widget.isAscending // Sort completed goals based on the selected order
        ? a.targetAmount.compareTo(b.targetAmount) 
        : b.targetAmount.compareTo(a.targetAmount));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: completedGoals.length,
            itemBuilder: (context, index) {
              final goal = completedGoals[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Increased margin for spacing
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Increased border radius
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Added padding for spacing
                  leading: const Icon(Icons.emoji_events), // Trophy icon
                  title: Text(
                    goal.name ?? 'Unnamed Goal', // Handle null name
                    style: TextStyle(
                      color: Colors.blue, // Set color for the goal name
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target: \$${goal.targetAmount.toStringAsFixed(2) ?? '0.00'}'), // Display target amount
                      Text('Current: \$${goal.currentAmount.toStringAsFixed(2) ?? '0.00'}'), // Display current amount
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
