import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_rounded, size: 64, color: Colors.red),
            SizedBox(height: 12),
            Text(
              'Dashboard',
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
