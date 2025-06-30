import 'package:flutter/material.dart';
import 'admin_add_page.dart';
import 'admin_profile_page.dart';
import '../film_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    _AdminHomeTab(),
    AdminAddPage(),
    AdminProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF64B9F2),
          unselectedItemColor: Colors.black54,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

class _AdminHomeTab extends StatefulWidget {
  @override
  State<_AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<_AdminHomeTab> {
  List<Map<String, dynamic>> _films = [];
  bool _isLoading = true;
  String? _error;
  late final DatabaseReference _filmRef;
  StreamSubscription<DatabaseEvent>? _filmSub;

  @override
  void initState() {
    super.initState();
    _filmRef = FirebaseDatabase.instance.ref().child('film');
    _filmSub = _filmRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      final List<Map<String, dynamic>> films = [];
      if (data != null) {
        data.forEach((key, value) {
          films.add({...value, 'id': key});
        });
      }
      setState(() {
        _films = films;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _filmSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Image.asset(
            'assets/Film Fest Title.png',
            height: 48,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome, Admin!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF64B9F2)))
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                  : _films.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Icon(Icons.local_movies, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'No films found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _films.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final film = _films[index];
                            Widget imageWidget;
                            if (film['thumbnailBase64'] != null && film['thumbnailBase64'].toString().isNotEmpty) {
                              try {
                                Uint8List bytes = base64Decode(film['thumbnailBase64']);
                                imageWidget = Image.memory(bytes, width: 80, height: 110, fit: BoxFit.cover);
                              } catch (e) {
                                imageWidget = Container(
                                  width: 80,
                                  height: 110,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 28, color: Colors.grey),
                                );
                              }
                            } else if (film['thumbnailUrl'] != null && film['thumbnailUrl'].toString().isNotEmpty) {
                              imageWidget = Image.network(film['thumbnailUrl'], width: 80, height: 110, fit: BoxFit.cover);
                            } else {
                              imageWidget = Container(
                                width: 80,
                                height: 110,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 28, color: Colors.grey),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FilmDetailScreen(
                                      id: film['id'],
                                      isAdmin: true,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            bottomLeft: Radius.circular(16),
                                          ),
                                          child: imageWidget,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  film['title'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  film['duration'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  film['genre'] ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xFF64B9F2),
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  film['description'] ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 10,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.calendar_today, size: 11, color: Colors.blueGrey),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      film['date'] ?? '',
                                                      style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Icon(Icons.access_time, size: 11, color: Colors.blueGrey),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      film['time'] ?? '',
                                                      style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'RP. ${film['price'] ?? ''}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF5EC6F0),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AdminAddPage(
                                                    filmData: film,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Film'),
                                                  content: const Text('Are you sure you want to delete this film?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Delete'),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                try {
                                                  final url = Uri.parse('https://filmfest-218c4-default-rtdb.firebaseio.com/film/${film['id']}.json');
                                                  await http.delete(url);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Film deleted successfully!')),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to delete film: $e')),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
          ),
        ),
      ],
    );
  }
} 