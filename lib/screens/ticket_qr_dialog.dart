import 'package:flutter/material.dart';
import 'buy_ticket_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

void showTicketQrDialog({
  required BuildContext context,
  required String ticketId,
  double maxWidth = 400,
}) {
  final Color blue = const Color(0xFF64B9F2);
  final Color grayText = const Color(0xFF787878);

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: const TicketShapeBorder(radius: 24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        icon: Icon(Icons.arrow_back_ios_new_outlined, color: blue, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'TICKET',
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
                    const SizedBox(width: 48), // Spacer kanan agar judul tetap di tengah
                  ],
                ),
                const SizedBox(height: 18),
                // QR/barcode (ganti icon dengan QrImageView)
                QrImageView(
                  data: ticketId,
                  version: QrVersions.auto,
                  size: maxWidth * 0.6,
                ),
                const SizedBox(height: 18),
                // Ticket id
                Text(
                  'Ticket id',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ticketId,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'show this ticket to the attendant\nbefore you enter the studio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF787878),
                    fontFamily: 'Poppins',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
} 