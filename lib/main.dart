import 'package:flutter/material.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chis Pro'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Welcome to Chis Pro!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Your app is working!'),
          ],
        ),
      ),
    );
  }
}
