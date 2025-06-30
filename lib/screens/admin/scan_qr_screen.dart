import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({Key? key}) : super(key: key);

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ticket QR'),
        backgroundColor: const Color(0xFF64B9F2),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final barcode = capture.barcodes.first;
          if (!scanned && barcode.rawValue != null) {
            scanned = true;
            Navigator.pop(context, barcode.rawValue);
          }
        },
      ),
    );
  }
} 