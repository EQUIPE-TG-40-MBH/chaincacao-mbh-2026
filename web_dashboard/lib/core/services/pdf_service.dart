import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ChainCacaoPdfService {
  static Future<void> downloadDailyReport({
    required List<Map<String, dynamic>> lots,
  }) async {
    final pdf = pw.Document();
    final totalKg = lots.fold<double>(
      0,
      (sum, lot) => sum + ((lot['weightDeclared'] ?? 0) as num).toDouble(),
    );
    final alerts = lots.where((lot) => lot['status'] == 'FRAUD_ALERT').length;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        build: (context) => [
          _header('Rapport journalier cooperative', 'CAPRK Kpalime'),
          pw.SizedBox(height: 18),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _metric('Lots recus', '${lots.length}'),
              _metric('Volume total', '${totalKg.toInt()} kg'),
              _metric('Alertes fraude', '$alerts'),
            ],
          ),
          pw.SizedBox(height: 22),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Lot',
              'Agriculteur',
              'Culture',
              'Declare',
              'Verifie',
              'Statut',
            ],
            data: lots
                .map(
                  (lot) => [
                    lot['lotId'],
                    lot['farmerName'],
                    lot['cultureType'],
                    '${(lot['weightDeclared'] as num).toInt()} kg',
                    '${((lot['weightVerified'] ?? 0) as num).toInt()} kg',
                    lot['status'],
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor(0.239, 0.11, 0.008),
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.all(7),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'rapport-journalier-chaincacao.pdf',
    );
  }

  static Future<void> downloadEudrCertificate({
    required String certificateId,
    required List<Map<String, dynamic>> lots,
    required double totalKg,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        build: (context) => [
          _header('Certificat de conformite EUDR', certificateId),
          pw.SizedBox(height: 12),
          pw.Text(
            'Declaration: les lots ci-dessous sont traces depuis les parcelles '
            'jusqu a l exportateur, avec preuves GPS, poids verifies et hashs blockchain.',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 18),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _metric('Lots consolides', '${lots.length}'),
              _metric('Poids total', '${totalKg.toInt()} kg'),
              _metric('Destination', 'UE'),
            ],
          ),
          pw.SizedBox(height: 22),
          ...lots.map(
            (lot) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: const PdfColor(0.831, 0.773, 0.690),
                ),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    lot['lotId'],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('Agriculteur: ${lot['farmerName']}'),
                  pw.Text('GPS parcelle: ${lot['gps']}'),
                  pw.Text(
                    'Poids verifie: ${((lot['weightVerified'] ?? 0) as num).toInt()} kg',
                  ),
                  pw.Text('Hash blockchain: ${lot['blockchainHash']}'),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor(0.941, 0.980, 0.957),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'Signature numerique MVP: CHAINCACAO-$certificateId. '
              'Document genere automatiquement par la plateforme ChainCacao.',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '$certificateId.pdf',
    );
  }

  static pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      margin: const pw.EdgeInsets.all(36),
      theme: pw.ThemeData.withFont(),
    );
  }

  static pw.Widget _header(String title, String subtitle) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor(0.239, 0.11, 0.008),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ChainCacao',
            style: pw.TextStyle(
              color: const PdfColor(0.914, 0.690, 0.294),
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            title,
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 16),
          ),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _metric(String label, String value) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: const PdfColor(0.831, 0.773, 0.690)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
}
