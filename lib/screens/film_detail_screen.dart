import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'buy_ticket_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin/scan_qr_screen.dart';

class FilmDetailScreen extends StatefulWidget {
  final String? id;
  final String? title;
  final String? thumbnailUrl;
  final String? duration;
  final String? date;
  final String? time;
  final String? price;
  final String? location;
  final String? description;
  final String? genre;
  final bool isAdmin;

  const FilmDetailScreen({
    super.key,
    this.id,
    this.title,
    this.thumbnailUrl,
    this.duration,
    this.date,
    this.time,
    this.price,
    this.location,
    this.description,
    this.genre,
    this.isAdmin = false,
  });

  @override
  State<FilmDetailScreen> createState() => _FilmDetailScreenState();
}

class _FilmDetailScreenState extends State<FilmDetailScreen> {
  Map<String, dynamic>? filmData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      fetchFilmDetail(widget.id!);
    } else {
      filmData = {
        'title': widget.title,
        'thumbnailUrl': widget.thumbnailUrl,
        'duration': widget.duration,
        'date': widget.date,
        'time': widget.time,
        'price': widget.price,
        'location': widget.location,
        'description': widget.description,
        'genre': widget.genre,
      };
    }
  }

  Future<void> fetchFilmDetail(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final url = Uri.parse('https://filmfest-218c4-default-rtdb.firebaseio.com/film/$id.json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          setState(() {
            filmData = data;
          });
        } else {
          setState(() {
            _error = 'Film tidak ditemukan.';
          });
        }
      } else {
        setState(() {
          _error = 'Gagal mengambil data film.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF181A20),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF64B9F2))),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF181A20),
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
      );
    }
    final data = filmData;
    if (data == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF181A20),
        body: Center(child: Text('Film tidak ditemukan', style: TextStyle(color: Colors.white))),
      );
    }
    Widget imageWidget;
    if (data['thumbnailBase64'] != null && data['thumbnailBase64'].toString().isNotEmpty) {
      try {
        Uint8List bytes = base64Decode(
          data['thumbnailBase64'].toString().replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '')
        );
        imageWidget = Image.memory(
          bytes,
          width: double.infinity,
          height: size.height * 0.5,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        );
      } catch (e) {
        imageWidget = Container(
          width: double.infinity,
          height: size.height * 0.5,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
        );
      }
    } else if (data['thumbnailUrl'] != null && data['thumbnailUrl'].toString().isNotEmpty) {
      imageWidget = Image.network(data['thumbnailUrl'], width: double.infinity, height: size.height * 0.5, fit: BoxFit.cover);
    } else {
      imageWidget = Container(
        width: double.infinity,
        height: size.height * 0.5,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 48, color: Colors.grey),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B9F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: widget.isAdmin
                ? () async {
                    // Buka scan QR
                    final ticketId = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (context) => const ScanQrScreen()),
                    );
                    if (ticketId != null && ticketId.isNotEmpty) {
                      // Cari dan update status tiket di database
                      try {
                        final ref = FirebaseDatabase.instance.ref().child('tickets');
                        final snapshot = await ref.get();
                        bool found = false;
                        for (final userSnap in snapshot.children) {
                          final userId = userSnap.key;
                          for (final ticketSnap in userSnap.children) {
                            if (ticketSnap.key == ticketId) {
                              await ref.child('$userId/$ticketId/status').set('terpakai');
                              found = true;
                              break;
                            }
                          }
                          if (found) break;
                        }
                        if (found) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tiket berhasil diverifikasi dan status diubah menjadi terpakai!')),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ticket ID tidak ditemukan!')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal verifikasi tiket: $e')),
                          );
                        }
                      }
                    }
                  }
                : () {
                    final user = FirebaseAuth.instance.currentUser;
                    final userId = user?.uid ?? '';
                    showBuyTicketDialog(
                      context: context,
                      idFilm: widget.id ?? filmData?['id'] ?? '',
                      userId: userId,
                    );
                  },
            child: Text(
              widget.isAdmin ? 'VERIFICATION TICKET' : 'BUY TICKET',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar film 50% layar
            SizedBox(
              width: double.infinity,
              height: size.height * 0.5,
              child: Stack(
                children: [
                  imageWidget,
                  // Gradient blend ke bawah
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 120,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xFF181A20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Header judul film & back button
                  Positioned(
                    top: 36,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFF64B9F2), width: 2),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Color(0xFF64B9F2), size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data['title'] ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Jersey10',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 36), // Spacer agar judul tetap di tengah
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info film overlay di bawah gambar (blend area)
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Harga
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data['duration'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF787878),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data['genre'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF64B9F2),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          data['price'] != null ? 'RP. ${data['price']}' : '',
                          style: const TextStyle(
                            color: Color(0xFF64B9F2),
                            fontFamily: 'Jersey10',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tanggal, Jam, Lokasi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF64B9F2), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                data['date'] ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFF64B9F2), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                data['time'] ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF64B9F2), size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data['location'] ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Deskripsi
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['description'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF787878),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            const SizedBox(height: 12), // Tambah jarak bawah agar tombol tidak terlalu menempel
          ],
        ),
      ),
    );
  }
} 