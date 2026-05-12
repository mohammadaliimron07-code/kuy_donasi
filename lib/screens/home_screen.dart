import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/auth_provider.dart';
import 'package:kuydonasi/providers/donation_provider.dart';
import 'package:kuydonasi/screens/dashboard_screen.dart';
import 'package:kuydonasi/screens/donation_screen.dart';
import 'package:kuydonasi/screens/report_screen.dart';
import 'package:kuydonasi/screens/profile_screen.dart';
import 'package:kuydonasi/screens/feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DonationScreen(),
    const ReportScreen(),
    const FeedbackScreen(),
    const ProfileScreen(),
  ];

  void _onLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (shouldLogout != true) return;
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel KuyDonasi'),
          backgroundColor: const Color(0xFF17A2B8),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              onPressed: _onLogout,
            ),
          ],
        ),
        body: const DashboardScreen(),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Donasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            activeIcon: Icon(Icons.lightbulb),
            label: 'Bangun',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0D6E63),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onLogout,
        backgroundColor: const Color(0xFF0D6E63),
        child: const Icon(Icons.logout),
      ),
    );
  }
}
