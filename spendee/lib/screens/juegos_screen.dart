import 'package:flutter/material.dart';

class JuegosScreen extends StatelessWidget {
  const JuegosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juegos'),
      ),
      body: Center(
        child: const Text('Bienvenido a la pantalla de Juegos!'),
      ),
    );
  }
}
