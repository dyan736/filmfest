import 'package:flutter/material.dart';
import 'package:film_fest_tiket/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAdmin = false;

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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Jersey10',
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Name',
                        style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontSize: 15)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE9E9E9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Your name',
                      hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email',
                        style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontSize: 15)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE9E9E9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'example@gmail.com',
                      hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: TextStyle(
                            color: blue,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontSize: 15)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE9E9E9),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: blue),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    value: _isAdmin,
                    onChanged: (val) {
                      setState(() {
                        _isAdmin = val ?? false;
                      });
                    },
                    title: const Text(
                      'Login sebagai admin',
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: blue,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  displayError(),
                  displayLoading(),

                  // Button
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
                      onPressed: _register,
                      child: const Text(
                        'REGISTER',
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

                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Sign In',
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

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "All fields are required";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.register(
      email,
      password,
      name,
      status: _isAdmin ? 'admin' : 'reguler',
    );

    setState(() {
      _isLoading = false;
      _errorMessage = result;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful. Please login.')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget displayError() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: 'Poppins'),
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
