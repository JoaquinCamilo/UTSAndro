import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final int currentIndex;
  final Widget child;
  final List<Widget>? actions;

  const BaseScreen({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/transactions');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/wallet');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/goals');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dasbor',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.wallet),
            label: 'Dompet',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings),
            label: 'Tujuan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add-transaction');
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 