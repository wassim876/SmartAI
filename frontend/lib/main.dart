import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/storage_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/history_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_layout.dart';
import 'screens/admin/users/user_management_screen.dart';
import 'screens/admin/ai_services/ai_services_screen.dart';
import 'screens/admin/analystic/analytics_screen.dart';
import 'screens/admin/chat_logs/chat_logs_screen.dart';
import 'screens/admin/transactions/transactions_screen.dart';
import 'screens/admin/reports/reports_screen.dart';
import 'screens/admin/notifications/notifications_screen.dart';
import 'screens/admin/setting/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize storage service
  await StorageService().init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SmartAIApp(),
    ),
  );
}

class SmartAIApp extends StatelessWidget {
  const SmartAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'SmartAi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/history': (context) => const HistoryScreen(),
        '/admin/dashboard': (context) =>
            const AdminLayout(child: AdminDashboard()),
        '/admin/users': (context) =>
            const AdminLayout(child: UserManagementScreen()),
        '/admin/ai-services': (context) =>
            const AdminLayout(child: AIServicesScreen()),
        '/admin/analytics': (context) =>
            const AdminLayout(child: AnalyticsScreen()),
        '/admin/chat-logs': (context) =>
            const AdminLayout(child: ChatLogsScreen()),
        '/admin/transactions': (context) =>
            const AdminLayout(child: TransactionsScreen()),
        '/admin/reports': (context) =>
            const AdminLayout(child: ReportsScreen()),
        '/admin/notifications': (context) =>
            const AdminLayout(child: NotificationsScreen()),
        '/admin/settings': (context) =>
            const AdminLayout(child: SettingsScreen()),
      },
    );
  }
}
