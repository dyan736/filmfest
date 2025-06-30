import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminAddPage extends StatefulWidget {
  final Map<String, dynamic>? filmData;
  const AdminAddPage({Key? key, this.filmData}) : super(key: key);

  @override
  State<AdminAddPage> createState() => _AdminAddPageState();
}

class _AdminAddPageState extends State<AdminAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();

  XFile? _pickedImage;
  bool _isLoading = false;
  String? editingFilmId;

  @override
  void initState() {
    super.initState();
    if (widget.filmData != null) {
      final film = widget.filmData!;
      editingFilmId = film['id'];
      _titleController.text = film['title'] ?? '';
      _durationController.text = film['duration'] ?? '';
      _descController.text = film['description'] ?? '';
      _dateController.text = film['date'] ?? '';
      _timeController.text = film['time'] ?? '';
      _priceController.text = film['price'] ?? '';
      _locationController.text = film['location'] ?? '';
      _genreController.text = film['genre'] ?? '';
    }
  }

  Future<void> submitFilm(Map<String, dynamic> filmData) async {
    if (editingFilmId != null) {
      final url = Uri.parse('https://filmfest-218c4-default-rtdb.firebaseio.com/film/$editingFilmId.json');
      await http.patch(url, body: json.encode(filmData));
    } else {
      final url = Uri.parse('https://filmfest-218c4-default-rtdb.firebaseio.com/film.json');
      await http.post(url, body: json.encode(filmData));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day.toString().padLeft(2, '0')} ${_monthName(picked.month)} ${picked.year}';
      });
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<String?> _imageToBase64(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF232323),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          widget.filmData != null ? 'Edit Film' : 'Tambah Film',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(source: ImageSource.gallery);
                                if (picked != null) {
                                  setState(() {
                                    _pickedImage = picked;
                                  });
                                }
                              },
                              icon: const Icon(Icons.image),
                              label: const Text('Pilih Gambar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF64B9F2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (_pickedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_pickedImage!.path),
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildInput(_titleController, 'Judul Film'),
                      const SizedBox(height: 14),
                      _buildInput(_durationController, 'Durasi (menit)'),
                      const SizedBox(height: 14),
                      _buildInput(_descController, 'Deskripsi', maxLines: 3),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: _buildInput(_dateController, 'Tanggal (cth: 1 July 2025)'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _pickTime,
                        child: AbsorbPointer(
                          child: _buildInput(_timeController, 'Jam (cth: 14:00)'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildInput(_priceController, 'Harga (cth: 55000)', keyboardType: TextInputType.number),
                      const SizedBox(height: 14),
                      _buildInput(_locationController, 'Lokasi'),
                      const SizedBox(height: 14),
                      _buildInput(_genreController, 'Genre'),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64B9F2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : () async {
                            if (_formKey.currentState!.validate()) {
                              if (_pickedImage == null && widget.filmData == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gambar wajib dipilih!')),
                                );
                                return;
                              }
                              setState(() { _isLoading = true; });
                              String? base64Image;
                              if (_pickedImage != null) {
                                base64Image = await _imageToBase64(_pickedImage!);
                                if (base64Image == null) {
                                  setState(() { _isLoading = false; });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gagal konversi gambar!')),
                                  );
                                  return;
                                }
                              }
                              final filmData = {
                                'title': _titleController.text,
                                'duration': _durationController.text,
                                'date': _dateController.text,
                                'time': _timeController.text,
                                'price': _priceController.text,
                                'location': _locationController.text,
                                'description': _descController.text,
                                'genre': _genreController.text,
                              };
                              if (base64Image != null) {
                                filmData['thumbnailBase64'] = base64Image;
                              } else if (widget.filmData != null && widget.filmData!['thumbnailBase64'] != null) {
                                filmData['thumbnailBase64'] = widget.filmData!['thumbnailBase64'];
                              }
                              await submitFilm(filmData);
                              setState(() {
                                _isLoading = false;
                                _pickedImage = null;
                                _titleController.clear();
                                _durationController.clear();
                                _descController.clear();
                                _dateController.clear();
                                _timeController.clear();
                                _priceController.clear();
                                _locationController.clear();
                                _genreController.clear();
                              });
                              _formKey.currentState!.reset();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(widget.filmData != null ? 'Film berhasil diupdate!' : 'Film berhasil ditambahkan!')),
                              );
                              if (widget.filmData != null && context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : Text(widget.filmData != null ? 'Update Film' : 'Tambah Film', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (_pickedImage != null) ...[
                        const SizedBox(height: 24),
                        const Text('Preview Base64:', style: TextStyle(fontWeight: FontWeight.bold)),
                        FutureBuilder<String?>(
                          future: _imageToBase64(_pickedImage!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              try {
                                final bytes = base64Decode(snapshot.data!.replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', ''));
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(bytes, height: 120, fit: BoxFit.cover),
                                  ),
                                );
                              } catch (e) {
                                return const Text('Gagal decode base64', style: TextStyle(color: Colors.redAccent));
                              }
                            }
                            return const Text('Gagal konversi base64', style: TextStyle(color: Colors.redAccent));
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
    );
  }
} 