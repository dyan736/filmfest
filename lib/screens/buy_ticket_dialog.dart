import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketShapeBorder extends ShapeBorder {
  final double radius;
  const TicketShapeBorder({this.radius = 24});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final r = radius;
    final notch = 18.0;
    // Start top left
    path.moveTo(rect.left + r, rect.top);
    path.arcToPoint(Offset(rect.left, rect.top + r), radius: Radius.circular(r));
    // Left side
    path.lineTo(rect.left, rect.center.dy - notch);
    path.arcToPoint(
      Offset(rect.left, rect.center.dy + notch),
      radius: Radius.circular(notch),
      clockwise: false,
    );
    path.lineTo(rect.left, rect.bottom - r);
    path.arcToPoint(Offset(rect.left + r, rect.bottom), radius: Radius.circular(r));
    // Bottom
    path.lineTo(rect.right - r, rect.bottom);
    path.arcToPoint(Offset(rect.right, rect.bottom - r), radius: Radius.circular(r));
    // Right side
    path.lineTo(rect.right, rect.center.dy + notch);
    path.arcToPoint(
      Offset(rect.right, rect.center.dy - notch),
      radius: Radius.circular(notch),
      clockwise: false,
    );
    path.lineTo(rect.right, rect.top + r);
    path.arcToPoint(Offset(rect.right - r, rect.top), radius: Radius.circular(r));
    // Top
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

Future<Map<String, dynamic>?> fetchFilmDetail(String idFilm) async {
  final url = Uri.parse('https://filmfest-218c4-default-rtdb.firebaseio.com/film/$idFilm.json');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data != null) return data;
  }
  return null;
}

Future<void> uploadTicket({
  required String userId,
  required String filmId,
  required int ticketCount,
  required int totalPayment,
  required Map<String, dynamic> filmData,
}) async {
  final url = Uri.parse('https://filmfest-218c4-default-rtdb.firebaseio.com/tickets/$userId.json');
  final ticketData = {
    'filmId': filmId,
    'title': filmData['title'],
    'date': filmData['date'],
    'time': filmData['time'],
    'location': filmData['location'],
    'price': filmData['price'],
    'quantity': ticketCount,
    'total': totalPayment,
    'timestamp': DateTime.now().toIso8601String(),
  };
  await http.post(url, body: json.encode(ticketData));
}

void showBuyTicketDialog({
  required BuildContext context,
  required String idFilm,
  required String userId,
}) {
  final Color blue = const Color(0xFF64B9F2);
  final Color grayText = const Color(0xFF787878);
  final Color whiteBox = const Color(0xFFE9E9E9);
  final Color bgDark = const Color(0xFF181A20);
  int ticketCount = 1;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: fetchFilmDetail(idFilm),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Dialog(
              backgroundColor: Colors.white,
              child: SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Dialog(
              backgroundColor: Colors.white,
              child: SizedBox(height: 200, child: Center(child: Text('Film not found'))),
            );
          }
          final film = snapshot.data!;
          int priceInt = int.tryParse(film['price'].toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          int total = priceInt * ticketCount;
          return StatefulBuilder(
            builder: (context, setState) {
              total = priceInt * ticketCount;
              return Dialog(
                backgroundColor: Colors.white,
                shape: const TicketShapeBorder(radius: 24),
                insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: blue, width: 2),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios_new_outlined, color: blue, size: 22),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'BUY TICKET',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: blue,
                                  fontFamily: 'Jersey10',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 34),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Detail film
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: film['thumbnailBase64'] != null && film['thumbnailBase64'].toString().isNotEmpty
                                  ? Image.memory(
                                      base64Decode(film['thumbnailBase64'].toString().replaceAll('\n', '').replaceAll('\r', '').replaceAll(' ', '')),
                                      width: 110,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    )
                                  : (film['thumbnailUrl'] != null && film['thumbnailUrl'].toString().isNotEmpty
                                      ? Image.network(film['thumbnailUrl'], width: 110, height: 140, fit: BoxFit.cover)
                                      : Container(
                                          width: 110,
                                          height: 140,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 48, color: Colors.grey),
                                        )),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    film['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    film['duration'] ?? '',
                                    style: TextStyle(
                                      color: grayText,
                                      fontSize: 13,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    film['description'] ?? '',
                                    style: TextStyle(
                                      color: grayText,
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: blue, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        film['date'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: blue, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        film['time'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: blue, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          film['location'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontFamily: 'Poppins',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Amount of ticket
                        Text(
                          'Amount of ticket',
                          style: TextStyle(
                            color: blue,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: whiteBox,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: ticketCount > 1 ? () => setState(() => ticketCount--) : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: blue,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(Icons.remove, color: Colors.white, size: 20),
                                ),
                              ),
                              Text(
                                '$ticketCount',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => ticketCount++),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: blue,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(Icons.add, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Harga
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ticket price', style: TextStyle(color: grayText, fontFamily: 'Poppins', fontSize: 13)),
                            Text('Rp. ${priceInt.toStringAsFixed(0)}', style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ticket Quantity', style: TextStyle(color: grayText, fontFamily: 'Poppins', fontSize: 13)),
                            Text('$ticketCount', style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: grayText.withOpacity(0.2)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Payment', style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Rp. ${total.toStringAsFixed(0)}', style: TextStyle(color: blue, fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              await uploadTicket(
                                userId: userId,
                                filmId: idFilm,
                                ticketCount: ticketCount,
                                totalPayment: total,
                                filmData: film,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tiket berhasil dibeli!')),
                              );
                            },
                            child: const Text(
                              'BUY NOW',
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
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
} 