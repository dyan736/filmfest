import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'film_detail_screen.dart';
import 'my_tickets_screen.dart';

class UmumHomeScreen extends StatefulWidget {
  const UmumHomeScreen({super.key});

  @override
  State<UmumHomeScreen> createState() => _UmumHomeScreenState();
}

class _UmumHomeScreenState extends State<UmumHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'All';

  List<Map<String, dynamic>> _films = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchFilms();
  }

  Future<void> fetchFilms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final url = Uri.parse('https://filmfest-218c4-default-rtdb.firebaseio.com/film.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          _films = [];
          data.forEach((key, value) {
            _films.add({...value, 'id': key});
          });
        } else {
          _films = [];
        }
      } else {
        _error = 'Gagal mengambil data film';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: $e';
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil semua genre unik dari data
    final List<String> genres = [
      'All',
      ...{
        for (final film in _films)
          (film['genre'] ?? '').toString().trim()
      }..remove('')
    ]..sort((a, b) => a == 'All' ? -1 : a.compareTo(b));
    // Filter berdasarkan search dan genre
    List<Map<String, dynamic>> filteredFilms = _films.where((film) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch = (film['title'] ?? '').toString().toLowerCase().contains(query);
      final matchesGenre = _selectedGenre == 'All' ||
        (film['genre'] ?? '').toString().toLowerCase().split(',').map((g) => g.trim()).contains(_selectedGenre.toLowerCase());
      return matchesSearch && matchesGenre;
    }).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Header logo pakai gambar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Image.asset(
                'assets/Film Fest Title.png',
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 24),
            // Filter genre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final genre = genres[i];
                    final isSelected = genre.toLowerCase() == _selectedGenre.toLowerCase();
                    return ChoiceChip(
                      label: Text(genre, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      selected: isSelected,
                      selectedColor: const Color(0xFF64B9F2),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      onSelected: (_) {
                        setState(() {
                          _selectedGenre = genre;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ListView daftar film (card horizontal)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF64B9F2)))
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
                        : filteredFilms.isEmpty
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
                                itemCount: filteredFilms.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 20),
                                itemBuilder: (context, index) {
                                  final film = filteredFilms[index];
                                  Widget imageWidget;
                                  if (film['thumbnailBase64'] != null && film['thumbnailBase64'].toString().isNotEmpty) {
                                    try {
                                      Uint8List bytes = base64Decode(film['thumbnailBase64']);
                                      imageWidget = Image.memory(bytes, width: 130, height: 180, fit: BoxFit.cover);
                                    } catch (e) {
                                      imageWidget = Container(
                                        width: 130,
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                      );
                                    }
                                  } else if (film['thumbnailUrl'] != null && film['thumbnailUrl'].toString().isNotEmpty) {
                                    imageWidget = Image.network(film['thumbnailUrl'], width: 130, height: 180, fit: BoxFit.cover);
                                  } else {
                                    imageWidget = Container(
                                      width: 130,
                                      height: 180,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                                    );
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FilmDetailScreen(
                                            id: film['id'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(24),
                                              bottomLeft: Radius.circular(24),
                                            ),
                                            child: imageWidget,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    film['title'] ?? '',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    film['duration'] ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    film['genre'] ?? '',
                                                    style: const TextStyle(
                                                      color: Color(0xFF64B9F2),
                                                      fontSize: 13,
                                                      fontFamily: 'Poppins',
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    film['description'] ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        film['date'] ?? '',
                                                        style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Icon(Icons.access_time, size: 16, color: Colors.blueGrey),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        film['time'] ?? '',
                                                        style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'RP. ${film['price'] ?? ''}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF5EC6F0),
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 