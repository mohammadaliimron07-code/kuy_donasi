import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/auth_provider.dart';
import 'package:kuydonasi/screens/dashboard_screen.dart';
import 'package:kuydonasi/screens/login_screen.dart';
import 'package:kuydonasi/screens/register_screen.dart';
import 'package:kuydonasi/screens/welcome_screen.dart';

void main() {
  runApp(const KuyDonasiApp());
}

class KuyDonasiApp extends StatefulWidget {
  const KuyDonasiApp({super.key});

  @override
  State<KuyDonasiApp> createState() => _KuyDonasiAppState();
}

class _KuyDonasiAppState extends State<KuyDonasiApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final auth = AuthProvider();
        auth.init(); // Initialize shared preferences
        return auth;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KuyDonasi',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const WelcomeScreen(),
          '/register': (_) => const RegisterScreen(),
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const AuthGuard(child: DashboardScreen()),
        },
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }
    return child;
  }
}   