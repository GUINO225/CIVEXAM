import 'dart:async';
import 'package:flutter/material.dart';
import '../services/scoring.dart';
import '../models/design_config.dart';
import '../services/design_bus.dart';
import 'multi_exam_flow.dart';

class OfficialIntroScreen extends StatefulWidget {
  const OfficialIntroScreen({super.key});

  @override
  State<OfficialIntroScreen> createState() => _OfficialIntroScreenState();
}

class _OfficialIntroScreenState extends State<OfficialIntroScreen> with SingleTickerProviderStateMixin {
  bool _accepted = false;
  bool _starting = false;
  int _count = 3;
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      _starting = true;
      _count = 3;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_count <= 1) {
        t.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MultiExamFlowScreen()),
        );
      } else {
        setState(() => _count--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DesignConfig>(
      valueListenable: DesignBus.notifier,
      builder: (context, cfg, _) {
        final overlayTextColor = Theme.of(context).colorScheme.onSurface;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar:
              AppBar(title: const Text('Concours officiel — Consignes')),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Simulation du concours ENA (pré‑sélection)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vous allez enchaîner 4 épreuves :\n'
                    '1) Culture Générale (Côte d’Ivoire)\n'
                    '2) Aptitude Verbale (Vocabulaire & règles)\n'
                    '3) Organisation & Logique (Classements & déductions)\n'
                    '4) Aptitude Numérique (Bases & proportionnalité)\n',
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Durée & barème',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text('• Durée : 60 minutes par épreuve (total ~4h).'),
                          Text(
                              '• Barème : +1 bonne, 0 blanc, −1 mauvaise (barème négatif).'),
                          Text(
                              '• Coefficient : ×2 par épreuve (pondération finale).'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Règles',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text(
                              '• Une fois le chrono lancé, vous ne pouvez pas revenir en arrière.'),
                          Text(
                              '• À la fin du temps, l’épreuve est automatiquement soumise.'),
                          Text('• Évitez de quitter l’app pendant une épreuve.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _accepted,
                        onChanged: (v) =>
                            setState(() => _accepted = v ?? false),
                      ),
                      const Expanded(
                          child: Text(
                              'Je comprends les règles et je suis prêt(e) à commencer.')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _accepted && !_starting ? _startCountdown : null,
                      icon: const Icon(Icons.flag),
                      label:
                          const Text('Démarrer la simulation officielle'),
                    ),
                  ),
                ],
              ),
              if (_starting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        '$_count',
                        style: TextStyle(
                            fontSize: 96,
                            color: overlayTextColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
