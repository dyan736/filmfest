import 'package:flutter/material.dart';
import 'umum_home_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'ticket_qr_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui' show TextDirection;

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  int selectedTab = 0; // 0: Active, 1: Expired

  static const Color bgDark = Color(0xFF181A20);
  static const Color blue = Color(0xFF64B9F2);
  static const Color whiteBox = Color(0xFFE9E9E9);
  static const Color grayText = Color(0xFF787878);

  Stream<List<Map<String, dynamic>>> ticketStream() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) yield [];
    final ref = FirebaseDatabase.instance.ref().child('tickets').child(user!.uid);
    await for (final event in ref.onValue) {
      final snapshot = event.snapshot;
      if (!snapshot.exists) {
        yield [];
        continue;
      }
      final List<Map<String, dynamic>> tickets = [];
      for (final child in snapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        data['id'] = child.key ?? '';
        tickets.add(data);
      }
      yield tickets;
    }
  }

  bool isExpired(Map<String, dynamic> ticket) {
    final dateStr = ticket['date'] ?? '';
    final timeStr = ticket['time'] ?? '';
    try {
      // Gabungkan date dan time, contoh: '30 June 2025 12:00 AM'
      final combined = '$dateStr $timeStr';
      // Parsing manual: 30 June 2025 12:00 AM
      final regex = RegExp(r'^(\d{1,2}) ([A-Za-z]+) (\d{4}) (\d{1,2}):(\d{2}) (AM|PM)');
      final match = regex.firstMatch(combined);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final monthStr = match.group(2)!;
        final year = int.parse(match.group(3)!);
        final hourRaw = int.parse(match.group(4)!);
        final minute = int.parse(match.group(5)!);
        final ampm = match.group(6)!;
        final months = {
          'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5, 'June': 6,
          'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12
        };
        final month = months[monthStr] ?? 1;
        int hour = hourRaw;
        if (ampm == 'PM' && hour != 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
        final dateTime = DateTime(year, month, day, hour, minute);
        return dateTime.isBefore(DateTime.now());
      }
      // Jika parsing gagal, anggap tidak expired
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: ticketStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final tickets = snapshot.data ?? [];
            final activeTickets = tickets.where((t) => !isExpired(t)).toList();
            final expiredTickets = tickets.where((t) => isExpired(t)).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Header
                Center(
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'MY ',
                          style: TextStyle(
                            color: blue,
                            fontFamily: 'Jersey10',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        TextSpan(
                          text: 'TICKETS',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Jersey10',
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        // Active Ticket kiri
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Active Ticket',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activeTickets.length.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: blue,
                                  fontFamily: 'Jersey10',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Expired Ticket kanan
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Expired Ticket',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                expiredTickets.length.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Jersey10',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                // Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 0 ? blue : whiteBox,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Active',
                                style: TextStyle(
                                  color: selectedTab == 0 ? Colors.white : Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTab == 1 ? blue : whiteBox,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Expired',
                                style: TextStyle(
                                  color: selectedTab == 1 ? Colors.white : Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Ticket List or Empty State
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: selectedTab == 0
                        ? (activeTickets.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                itemCount: activeTickets.length,
                                itemBuilder: (context, index) {
                                  final ticket = activeTickets[index];
                                  return Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 340,
                                      child: _buildTicketCard(ticket, true),
                                    ),
                                  );
                                },
                              ))
                        : (expiredTickets.isEmpty
                            ? _buildEmptyState(isExpired: true)
                            : ListView.builder(
                                itemCount: expiredTickets.length,
                                itemBuilder: (context, index) {
                                  final ticket = expiredTickets[index];
                                  return Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: 340,
                                      child: _buildTicketCard(ticket, false),
                                    ),
                                  );
                                },
                              )),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket, bool isActive) {
    final isUsed = (ticket['status'] ?? '').toString().toLowerCase() == 'terpakai';
    return Material(
      color: Colors.white,
      shape: const TicketCardShapeBorder(radius: 12, notchRadius: 7),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, top: 2, left: 8, right: 8),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  ticket['date']?.toString() ?? '',
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: isUsed
                        ? Colors.grey
                        : (isActive ? blue : grayText),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUsed
                        ? 'Terpakai'
                        : (isActive ? 'Active' : 'Expired'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Film', style: TextStyle(color: grayText, fontFamily: 'Poppins', fontSize: 12)),
                      Text(
                        ticket['title']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Location', style: TextStyle(color: grayText, fontFamily: 'Poppins', fontSize: 12)),
                      Text(
                        ticket['location']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Ticket id', style: TextStyle(color: grayText, fontFamily: 'Poppins', fontSize: 12)),
                      Text(
                        ticket['id']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Time', style: TextStyle(color: grayText, fontFamily: 'Poppins', fontSize: 12)),
                    Text(
                      ticket['time']?.toString() ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Duration', style: TextStyle(color: grayText, fontFamily: 'Poppins', fontSize: 12)),
                    Text(
                      ticket['duration']?.toString() ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: (isActive && !isUsed)
                        ? () {
                            showTicketQrDialog(
                              context: context,
                              ticketId: ticket['id']?.toString() ?? '',
                              maxWidth: 340,
                            );
                          }
                        : null,
                    child: const Text(
                      'Show Tickets',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({bool isExpired = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_num_outlined, color: grayText, size: 64),
          const SizedBox(height: 16),
          Text(
            isExpired ? "You don't have an expired ticket" : "You don't have an active ticket",
            style: const TextStyle(
              color: grayText,
              fontFamily: 'Poppins',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketCardShapeBorder extends ShapeBorder {
  final double radius;
  final double notchRadius;
  const TicketCardShapeBorder({this.radius = 12, this.notchRadius = 7});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final r = radius;
    final notch = notchRadius;
    // Start top left
    path.moveTo(rect.left + r, rect.top);
    path.arcToPoint(Offset(rect.left, rect.top + r), radius: Radius.circular(r));
    path.lineTo(rect.left, rect.bottom - r);
    path.arcToPoint(Offset(rect.left + r, rect.bottom), radius: Radius.circular(r));
    // Bottom left to center
    path.lineTo(rect.center.dx - notch, rect.bottom);
    path.arcToPoint(
      Offset(rect.center.dx + notch, rect.bottom),
      radius: Radius.circular(notch),
      clockwise: false,
    );
    path.lineTo(rect.right - r, rect.bottom);
    path.arcToPoint(Offset(rect.right, rect.bottom - r), radius: Radius.circular(r));
    path.lineTo(rect.right, rect.top + r);
    path.arcToPoint(Offset(rect.right - r, rect.top), radius: Radius.circular(r));
    // Top right to center
    path.lineTo(rect.center.dx + notch, rect.top);
    path.arcToPoint(
      Offset(rect.center.dx - notch, rect.top),
      radius: Radius.circular(notch),
      clockwise: false,
    );
    path.lineTo(rect.left + r, rect.top);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }
} 