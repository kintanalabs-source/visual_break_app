import 'package:flutter/material.dart';
import 'package:visual_break_app/application/timer_service/break_timer_service.dart';
import 'package:visual_break_app/core/service_locator.dart';

class VisualBreakPopup extends StatelessWidget {
  const VisualBreakPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = getIt<BreakTimerService>();

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95), // Deeper block effect
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.blue.withOpacity(0.2),
              Colors.black,
            ],
            radius: 1.5,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.remove_red_eye, size: 60, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Temps de pause visuelle !',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Regardez à 20 pieds (6 mètres) pendant 20 secondes.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ListenableBuilder(
                  listenable: timerService,
                  builder: (context, child) {
                    return Text(
                      '${timerService.remainingSeconds}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => timerService.skipBreak(),
                  child: const Text(
                    'Passer la pause',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
