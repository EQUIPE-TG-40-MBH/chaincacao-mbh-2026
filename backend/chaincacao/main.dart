import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const ChainCacaoMobile());

class ChainCacaoMobile extends StatelessWidget {
  const ChainCacaoMobile({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.brown, useMaterial3: true),
      home: const FarmerRecordPage(),
    );
  }
}

class FarmerRecordPage extends StatefulWidget {
  const FarmerRecordPage({super.key});
  @override
  State<FarmerRecordPage> createState() => _FarmerRecordPageState();
}

class _FarmerRecordPageState extends State<FarmerRecordPage> {
  final _weightController = TextEditingController();
  final _tts = FlutterTts();
  String? _generatedLotId;
  bool _isLoading = false;

  Future<void> _speak(String text) async {
    await _tts.setLanguage("fr-FR");
    await _tts.speak(text);
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _speak("Veuillez activer le GPS sur votre téléphone.");
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _speak("L'accès au GPS est nécessaire pour prouver l'origine du cacao.");
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _speak("Le GPS est bloqué. Veuillez l'activer dans les réglages.");
      return false;
    }
    return true;
  }

  Future<void> _registerLot() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    setState(() => _isLoading = true);
    try {
      Position pos = await Geolocator.getCurrentPosition();
      
      // 2. Envoyer au Backend Render
      final response = await http.post(
        Uri.parse('https://chaincacao-api.onrender.com/api/lots/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'farmer_id': '1', // ID de test
          'cooperative_id': 'COOP-PAL-001',
          'weight_declared': double.parse(_weightController.text),
          'culture_type': 'Cacao Forastero',
          'gps_latitude': pos.latitude,
          'gps_longitude': pos.longitude,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() => _generatedLotId = data['lot_id']);
        _speak("Lot enregistré avec succès. Voici votre code QR.");
      }
    } catch (e) {
      _speak("Erreur de connexion. Vérifiez votre réseau.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Lot Cacao')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_generatedLotId == null) ...[
              const Text('Combien de kilos avez-vous récolté ?', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Poids (kg)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _registerLot,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('ENREGISTRER MA RÉCOLTE'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60)),
              ),
            ] else ...[
              const Text('Lot enregistré sur la Blockchain !', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              QrImageView(data: _generatedLotId!, size: 250),
              const SizedBox(height: 20),
              Text('ID: $_generatedLotId', style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 32),
              TextButton(onPressed: () => setState(() => _generatedLotId = null), child: const Text('Enregistrer un autre lot'))
            ],
          ],
        ),
      ),
    );
  }
}