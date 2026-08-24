import 'package:flutter/material.dart';
import 'screen/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Pulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red.shade700,
          primary: Colors.red.shade700,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50, 
      ),
      home: const MainScreen(), 
    );
  }
}