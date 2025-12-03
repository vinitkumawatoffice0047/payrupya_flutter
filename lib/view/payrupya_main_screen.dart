import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:payrupya/view/payrupya_home_screen.dart';

import 'payment_screen.dart';
import 'profile_screen.dart';
import 'transaction_screen.dart';
import 'wallet_screen.dart';

// ============================================
// MAIN SCREEN WITH BOTTOM NAVIGATION
// ============================================
class PayrupyaMainScreen extends StatefulWidget {
  const PayrupyaMainScreen({super.key});

  @override
  State<PayrupyaMainScreen> createState() => _PayrupyaMainScreenState();
}

class _PayrupyaMainScreenState extends State<PayrupyaMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    PayrupyaHomeScreen(),
    PaymentScreen(),
    TransactionScreen(),
    WalletScreen(),
    ProfileScreen(),
    // HomeScreen(),
    // PaymentScreen(),
    // TransactionScreen(),
    // WalletScreen(),
    // ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.credit_card, 'Payment', 1),
              _buildNavItem(Icons.swap_horiz_rounded, 'Transactions', 2),
              _buildNavItem(Icons.account_balance_wallet_rounded, 'Wallet', 3),
              _buildNavItem(Icons.person_rounded, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4A90E2).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF4A90E2) : Colors.grey,
              size: 24,
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}