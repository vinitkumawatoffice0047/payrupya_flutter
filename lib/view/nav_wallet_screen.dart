// ============================================
// TRANSACTION SCREEN
// ============================================
import 'package:flutter/material.dart';

class NavWalletScreen extends StatelessWidget {
  const NavWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        backgroundColor: Color(0xFF4A90E2),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Wallet Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
