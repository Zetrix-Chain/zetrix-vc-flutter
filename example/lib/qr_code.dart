import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatelessWidget {
  final String data;

  const QrCodeScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code VP")),
      body: Center(
        child: QrImageView(
          data: data, // minified VP string
          version: QrVersions.auto,
          size: 300.0,
        ),
      ),
    );
  }
}
