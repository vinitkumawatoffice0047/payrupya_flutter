// ============================================
// TRANSACTION SCREEN
// ============================================
import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Transaction Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
