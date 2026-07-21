import 'dart:math';
import 'package:flutter/material.dart';

import '../../themes/esquema_color.dart';

class AudioVisualizer extends StatelessWidget {
  const AudioVisualizer({required this.decibels, super.key});

  final double decibels; // typically from -160 to 0

  @override
  Widget build(BuildContext context) {
    // Normalize decibels to a 0.0 - 1.0 scale
    // Assuming silence is -60 and max is 0 for better visual range
    final normalized = ((decibels + 60) / 60).clamp(0.0, 1.0);
    
    // We will draw 20 bars. We use a base curve and modulate it by the current normalized volume.
    const int numBars = 20;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(numBars, (index) {
        // Base height calculation using a sine wave for aesthetic curve
        final x = index / (numBars - 1); // 0 to 1
        final baseHeight = sin(x * pi) * 0.5 + 0.5; // Curve from 0.5 to 1.0 back to 0.5
        
        // Random flutter effect based on current volume
        final randomFlutter = (Random().nextDouble() * 0.3) * normalized;
        
        // Final height calculation
        final height = 10 + (30 * baseHeight * normalized) + (10 * randomFlutter);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: height.clamp(4.0, 40.0),
          decoration: BoxDecoration(
            color: ColorSchemeApp.primaryGreen.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
