import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/auth_provider.dart';
import 'package:kuydonasi/screens/donor_dashboard_screen.dart';
import 'package:kuydonasi/screens/admin_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Redirect donatur ke donor dashboard
    if (!auth.isAdmin) {
      return const DonorDashboardScreen();
    }

    // Admin Panel
    return const AdminDashboardScreen();
  }
}

