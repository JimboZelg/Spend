import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/wallet_provider.dart';
import 'models/transaction_adapter.dart';
import 'models/goal_adapter.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with Flutter
  await Hive.initFlutter();
  
  // Register our custom adapters only if they are not already registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GoalAdapter());
  }

  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WalletProvider(), // Initialize WalletProvider and call initHive
      child: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return MaterialApp( 
            title: 'Spenly',
            theme: walletProvider.isDarkMode
                ? ThemeData.dark() // Use dark theme
                : ThemeData(
                    primaryColor: const Color.fromARGB(255, 83, 198, 244), // Reverted to blue
                    scaffoldBackgroundColor: const Color(0xFFE0F7FA), // Light background color
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color.fromARGB(255, 72, 163, 199),
                      primary: const Color.fromARGB(255, 72, 163, 199),
                      secondary: const Color(0xFFFFEB3B),
                      error: const Color(0xFFFF0000),
                      tertiary: const Color(0xFF4CAF50),
                    ),
                    useMaterial3: true,
                  ), // Use light theme
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
