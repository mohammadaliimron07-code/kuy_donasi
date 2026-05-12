import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuydonasi/providers/auth_provider.dart';
import 'package:kuydonasi/providers/donation_provider.dart';
import 'package:kuydonasi/providers/campaign_provider.dart';
import 'package:kuydonasi/screens/dashboard_screen.dart';
import 'package:kuydonasi/screens/login_screen.dart';
import 'package:kuydonasi/screens/register_screen.dart';
import 'package:kuydonasi/screens/welcome_screen.dart';
import 'package:kuydonasi/screens/donor_dashboard_screen.dart';
import 'package:kuydonasi/screens/feedback_screen.dart';
import 'package:kuydonasi/screens/transaction_history_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(title: const Text('Render Error!')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${details.exceptionAsString()}\n\n${details.stack.toString()}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
      ),
    );
  };

  final authProvider = AuthProvider();
  await authProvider.init();

  final donationProvider = DonationProvider();
  await donationProvider.init();

  final campaignProvider = CampaignProvider();
  await campaignProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: donationProvider),
        ChangeNotifierProvider.value(value: campaignProvider),
      ],
      child: const KuyDonasiApp(),
    ),
  );
}

class KuyDonasiApp extends StatefulWidget {
  const KuyDonasiApp({super.key});

  @override
  State<KuyDonasiApp> createState() => _KuyDonasiAppState();
}

class _KuyDonasiAppState extends State<KuyDonasiApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          '/': (_) => const _RootNavigator(),
          '/register': (_) => const RegisterScreen(),
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/donor-dashboard': (_) => const AuthGuard(child: DonorDashboardScreen()),
          '/feedback': (_) => const AuthGuard(child: FeedbackScreen()),
          '/transaction-history': (_) => const AuthGuard(child: TransactionHistoryScreen()),
        },
      );
  }
}

class _RootNavigator extends StatelessWidget {
  const _RootNavigator();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // If user is already authenticated, go to dashboard
        if (auth.isAuthenticated) {
          return const DashboardScreen();
        }
        // Otherwise show welcome screen
        return const WelcomeScreen();
      },
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