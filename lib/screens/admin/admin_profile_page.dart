import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = false;

  static const Color bgDark = Color(0xFF181A20);
  static const Color blue = Color(0xFF64B9F2);
  static const Color gray = Color(0xFFE9E9E9);

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    await AuthService().logout();
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'ADMIN PROFILE',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jersey10',
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: gray,
                              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {}, // Tidak perlu fungsi edit
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 150),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: blue, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: blue.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(Icons.edit, color: blue, size: 22),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildProfileField(Icons.person_outline, 'Name', 'Admin Film Fest', blue),
                      const SizedBox(height: 16),
                      _buildProfileField(Icons.email_outlined, 'Email', 'admin@email.com', blue),
                      const SizedBox(height: 16),
                      _buildProfileField(Icons.verified_user, 'Status', 'Admin', blue),
                      const SizedBox(height: 32),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _logout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : const Text('SIGN OUT', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          readOnly: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF23262F),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.transparent, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
} 