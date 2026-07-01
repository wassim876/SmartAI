import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/supabase_config.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/history_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_layout.dart';
import 'screens/admin/users/user_management_screen.dart';
import 'screens/admin/ai_services/ai_services_screen.dart';
import 'screens/admin/analystic/analytics_screen.dart';
import 'screens/admin/chat_logs/chat_logs_screen.dart';
import 'screens/admin/reports/reports_screen.dart';
import 'screens/admin/notifications/notifications_screen.dart';
import 'screens/admin/setting/settings_screen.dart';
import 'screens/admin/reviews/reviews_screen.dart';
import 'screens/user/about_screen.dart';
import 'screens/user/user_settings_screen.dart';
import 'screens/user/help_center_screen.dart';
import 'screens/user/profile_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase is the primary backend (auth, database, storage, realtime).
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  // Firebase is retained solely for push notifications (FCM).
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
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
    final languageProvider = context.watch<LanguageProvider>();
    return MaterialApp(
      title: 'SmartAi',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: languageProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const _AuthGate(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/settings': (context) => const UserSettingsScreen(),
        '/about': (context) => const AboutScreen(),
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
        '/admin/reports': (context) =>
            const AdminLayout(child: ReportsScreen()),
        '/admin/notifications': (context) =>
            const AdminLayout(child: NotificationsScreen()),
        '/admin/settings': (context) =>
            const AdminLayout(child: SettingsScreen()),
        '/admin/reviews': (context) =>
            const AdminLayout(child: ReviewsScreen()),
        '/help': (context) => const HelpCenterScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.resolveUser();
    if (!mounted) return;

    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(
        context,
        auth.isAdmin ? '/admin/dashboard' : '/home',
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      ),
    );
  }
}
