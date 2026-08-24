import 'package:flutter/material.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_rounded, size: 64, color: Colors.red),
            SizedBox(height: 12),
            Text(
              'Simulation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
