import 'package:film_fest_tiket/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // INJEKSI AUTH SERVICE

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final Color blue = const Color(0xFF64B9F2);
    final Color bgDark = const Color(0xFF181A20);

    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 36),
                  Image.asset(
                    'assets/Film Fest Title.png',
                    width: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Buy your favorite movie tickets here,\nenjoy easy transactions and modern\nticketing with qr code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Jersey10',
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Username',
                      style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(
                        color: Colors.black, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE9E9E9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'example@gmail.com',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(
                        color: Colors.black, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE9E9E9),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  displayError(),
                  displayLoading(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _login,
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: Text(
                          'Register here',
                          style: TextStyle(
                            color: blue,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await _authService.login(email, password);

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      final userModel = await _authService.getCurrentUserModel();
      if (userModel != null && userModel.status == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin-home');
      } else {
        Navigator.pushReplacementNamed(context, '/umum-home');
      }
    }
  }

  Widget displayError() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        _errorMessage!,
        style: const TextStyle(
            color: Colors.redAccent, fontSize: 14, fontFamily: 'Poppins'),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget displayLoading() {
    if (!_isLoading) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: CircularProgressIndicator(color: Color(0xFF64B9F2)),
    );
  }
}
