import 'package:flutter/material.dart';
import 'package:smartai/theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_layout.dart';
import 'screens/admin/users/user_management_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartAIApp());
}

class SmartAIApp extends StatelessWidget {
  const SmartAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartAi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin/dashboard': (context) =>
            const AdminLayout(child: AdminDashboard()),
        '/admin/users': (context) =>
            const AdminLayout(child: UserManagementScreen()),
      },
    );
  }
}
