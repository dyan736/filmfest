import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color bgDark = Color(0xFF181A20);
  static const Color blue = Color(0xFF64B9F2);
  static const Color gray = Color(0xFFE9E9E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Header Jersey10 putih
                  Center(
                    child: Text(
                      'PROFILE',
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
                  // Foto profil dengan tombol edit
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: gray,
                          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                showEditProfileDialog(context);
                              },
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
                  _buildProfileField(Icons.person_outline, 'Name', 'Dian satriani', blue),
                  const SizedBox(height: 16),
                  _buildProfileField(Icons.email_outlined, 'Email', 'dian@gmail.com', blue),
                  const SizedBox(height: 16),
                  _buildProfileField(Icons.phone_outlined, 'Telephone Number', '+628315091050', blue),
                  const SizedBox(height: 16),
                  _buildProfileField(Icons.calendar_today_outlined, 'Birth Date', '25/05/2005', blue),
                  const SizedBox(height: 16),
                  _buildProfileField(Icons.location_on_outlined, 'Address', 'jln. veteran singaraja', blue),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('SIGN OUT', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  void showEditProfileDialog(BuildContext context) {
    final Color blue = ProfileScreen.blue;
    final Color gray = ProfileScreen.gray;
    final TextEditingController nameController = TextEditingController(text: 'Dian satriani');
    final TextEditingController emailController = TextEditingController(text: 'dian@gmail.com');
    final TextEditingController phoneController = TextEditingController(text: '+628315091050');
    final TextEditingController birthController = TextEditingController(text: '25/05/2005');
    final TextEditingController addressController = TextEditingController(text: 'jln. veteran singaraja');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 120),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: blue, width: 2),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios_new, color: blue, size: 22),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'EDIT PROFILE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blue,
                                fontFamily: 'Jersey10',
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 34),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: gray,
                              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  _showPickImageSheet(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: blue, width: 2),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(Icons.camera_alt, color: blue, size: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildEditField(Icons.person_outline, 'Name', nameController, blue),
                      const SizedBox(height: 16),
                      _buildEditField(Icons.email_outlined, 'Email', emailController, blue),
                      const SizedBox(height: 16),
                      _buildEditField(Icons.phone_outlined, 'Telephone Number', phoneController, blue),
                      const SizedBox(height: 16),
                      _buildEditField(Icons.calendar_today_outlined, 'Birth Date', birthController, blue, isDate: true, setState: setState, context: context),
                      const SizedBox(height: 16),
                      _buildEditField(Icons.location_on_outlined, 'Address', addressController, blue, isMultiline: true),
                      const SizedBox(height: 32),
                      Center(
                        child: SizedBox(
                          width: 140,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEditField(IconData icon, String label, TextEditingController controller, Color iconColor, {bool isDate = false, bool isMultiline = false, void Function(void Function())? setState, BuildContext? context}) {
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
        isDate
            ? TextFormField(
                controller: controller,
                readOnly: true,
                style: const TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE9E9E9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.transparent, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: iconColor, width: 1.5),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: iconColor, size: 20),
                ),
                onTap: () async {
                  if (context != null && setState != null) {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_dateFromString(controller.text)) ?? DateTime(2005, 5, 25),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        controller.text = _stringFromDate(picked);
                      });
                    }
                  }
                },
              )
            : TextFormField(
                controller: controller,
                minLines: isMultiline ? 3 : 1,
                maxLines: isMultiline ? 4 : 1,
                style: const TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 15),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE9E9E9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.transparent, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: iconColor, width: 1.5),
                  ),
                ),
              ),
      ],
    );
  }

  String _dateFromString(String s) {
    final parts = s.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
    }
    return s;
  }

  String _stringFromDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _showPickImageSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: ProfileScreen.blue),
                title: const Text('Ambil Foto', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final status = await Permission.camera.request();
                  if (status.isGranted) {
                    final picker = ImagePicker();
                    await picker.pickImage(source: ImageSource.camera);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Izin kamera diperlukan untuk mengambil foto.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: ProfileScreen.blue),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  await picker.pickImage(source: ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 