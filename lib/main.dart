import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'providers/lead_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

bool isSupabaseInitialized = false;

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  try {
    if (supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
      isSupabaseInitialized = true;
    }
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }

  runApp(const MyApp());
}

// ─── Color Palette ───────────────────────────────────────────────
class NebulaColors {
  static const Color bgDeep = Color(0xFF0D1117);
  static const Color bgCard = Color(0xFF161B22);
  static const Color bgSurface = Color(0xFF1C2128);
  static const Color borderSubtle = Color(0xFF30363D);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeadProvider()),
      ],
      child: MaterialApp.router(
        title: 'Nebula v1',
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: NebulaColors.bgDeep,
          primaryColor: NebulaColors.accentPurple,
          colorScheme: const ColorScheme.dark(
            primary: NebulaColors.accentPurple,
            secondary: NebulaColors.accentCyan,
            surface: NebulaColors.bgCard,
            error: NebulaColors.accentRed,
          ),
          fontFamily: 'Inter',
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: NebulaColors.bgDeep,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: NebulaColors.textPrimary,
              letterSpacing: 0.5,
            ),
            iconTheme: IconThemeData(color: NebulaColors.textSecondary),
          ),
          cardTheme: CardTheme(
            color: NebulaColors.bgCard,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: NebulaColors.borderSubtle, width: 1),
            ),
          ),
          navigationRailTheme: const NavigationRailThemeData(
            backgroundColor: NebulaColors.bgDeep,
            selectedIconTheme: IconThemeData(color: NebulaColors.accentPurple),
            unselectedIconTheme: IconThemeData(color: NebulaColors.textMuted),
            selectedLabelTextStyle: TextStyle(
              color: NebulaColors.accentPurple,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: NebulaColors.textMuted,
              fontSize: 12,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: NebulaColors.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: NebulaColors.bgSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NebulaColors.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NebulaColors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: NebulaColors.accentPurple, width: 2),
            ),
            labelStyle: const TextStyle(color: NebulaColors.textSecondary),
            hintStyle: const TextStyle(color: NebulaColors.textMuted),
            prefixIconColor: NebulaColors.textMuted,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: NebulaColors.bgCard,
            contentTextStyle: const TextStyle(color: NebulaColors.textPrimary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
          ),
          dividerTheme: const DividerThemeData(
            color: NebulaColors.borderSubtle,
          ),
          dialogTheme: DialogTheme(
            backgroundColor: NebulaColors.bgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titleTextStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: NebulaColors.textPrimary,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: NebulaColors.accentCyan,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isSupabaseInitialized) {
      return const LoginScreen();
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<LeadProvider>(context, listen: false).fetchLeads();
          });
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
