import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ChisProApp());
}

class ChisProApp extends StatelessWidget {
  const ChisProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chis Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
