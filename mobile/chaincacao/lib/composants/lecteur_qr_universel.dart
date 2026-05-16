import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class LecteurQrUniversel extends StatelessWidget {
  final Function(String) onScan;
  final String titre;

  const LecteurQrUniversel({super.key, required this.onScan, required this.titre});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(titre, style: Theme.of(context).textTheme.titleLarge),
        ),
        Expanded(
          child: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  onScan(barcode.rawValue!);
                }
              }
            },
          ),
        ),
      ],
    );
  }
}