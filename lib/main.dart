import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/umum_home_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_bottom_nav_bar.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'screens/admin/admin_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const FilmFestAdminApp());
}

class FilmFestAdminApp extends StatelessWidget {
  const FilmFestAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Festival Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.all(8),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/umum-home': (context) => const MainNavScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _opacity = 0.0;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Sudah login, cek status
      final authService = AuthService();
      final userModel = await authService.getCurrentUserModel();
      if (userModel != null && userModel.status == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin-home');
      } else {
        Navigator.of(context).pushReplacementNamed('/umum-home');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/Film Fest Title.png',
                width: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  color: Color(0xFF64B9F2),
                  backgroundColor: Colors.white12,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;

  final List<Widget> _pages = [
    const UmumHomeScreen(),
    const MyTicketsScreen(),
    const ProfileScreen(),
  ];

  void _onTabChange(int index) async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _currentIndex = index;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF181A20).withOpacity(0.7),
                child: const Center(
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      color: Color(0xFF64B9F2),
                      strokeWidth: 5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
