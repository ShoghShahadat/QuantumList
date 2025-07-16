import 'dart:math';
import 'package:flutter/material.dart';

/// Defines the type of animation choreography for the list items.
enum ChoreographyType {
  /// All items animate in simultaneously.
  simultaneous,

  /// Items animate in one after another with a fixed delay.
  staggered,

  /// Items animate in a smooth, overlapping wave pattern.
  wave,

  /// **[NEW]** Items animate in a spiral/snake-like pattern.
  /// **[جدید]** آیتم‌ها با یک الگوی مارپیچی وارد می‌شوند.
  spiral,

  /// **[NEW]** Items animate based on their distance from the center of the list.
  /// **[جدید]** آیتم‌ها بر اساس فاصله از مرکز لیست انیمیت می‌شوند.
  distanceFromCenter,
}

/// A class that defines and calculates animation curves for list items
/// to create complex, choreographed entrance effects.
class QuantumChoreography {
  final ChoreographyType type;
  final Duration stagger;
  final double itemDurationFraction;

  const QuantumChoreography({
    this.type = ChoreographyType.simultaneous,
    this.stagger = const Duration(milliseconds: 50),
    this.itemDurationFraction = 0.7,
  });

  /// A factory for a classic staggered animation effect.
  factory QuantumChoreography.staggered({
    Duration delay = const Duration(milliseconds: 60),
  }) {
    return QuantumChoreography(
      type: ChoreographyType.staggered,
      stagger: delay,
      itemDurationFraction: 0.8,
    );
  }

  /// A factory for a smooth, wave-like animation effect.
  factory QuantumChoreography.wave({
    Duration delay = const Duration(milliseconds: 40),
  }) {
    return QuantumChoreography(
      type: ChoreographyType.wave,
      stagger: delay,
      itemDurationFraction: 0.9,
    );
  }

  /// **[NEW]** A factory for a cool, spiral-like animation effect.
  factory QuantumChoreography.spiral({
    Duration delay = const Duration(milliseconds: 70),
  }) {
    return QuantumChoreography(
      type: ChoreographyType.spiral,
      stagger: delay,
      itemDurationFraction: 0.8,
    );
  }

  /// **[NEW]** A factory for a center-out animation effect.
  factory QuantumChoreography.distanceFromCenter({
    Duration delay = const Duration(milliseconds: 30),
  }) {
    return QuantumChoreography(
      type: ChoreographyType.distanceFromCenter,
      stagger: delay,
      itemDurationFraction: 0.9,
    );
  }

  /// Calculates the specific animation curve for a single item.
  Animation<double> getAnimation({
    required Animation<double> parent,
    required int index,
    required Duration totalDuration,
    required int totalItems, // NEW: Needed for distance calculation
  }) {
    if (totalDuration == Duration.zero) {
      return parent;
    }

    final double totalDurationMs = totalDuration.inMilliseconds.toDouble();
    final double staggerMs = stagger.inMilliseconds.toDouble();
    double startTime;

    switch (type) {
      case ChoreographyType.staggered:
      case ChoreographyType.wave:
        startTime = (index * staggerMs) / totalDurationMs;
        break;
      case ChoreographyType.spiral:
        // Use a sine wave to create a back-and-forth spiral effect
        final sinValue = sin(index * 0.5); // Adjust frequency for effect
        startTime =
            (index * staggerMs * (1 + sinValue) * 0.5) / totalDurationMs;
        break;
      case ChoreographyType.distanceFromCenter:
        final centerIndex = (totalItems - 1) / 2.0;
        final distance = (index - centerIndex).abs();
        startTime = (distance * staggerMs) / totalDurationMs;
        break;
      case ChoreographyType.simultaneous:
      default:
        return parent;
    }

    final double endTime = startTime + itemDurationFraction;

    return CurvedAnimation(
      parent: parent,
      curve: Interval(
        startTime.clamp(0.0, 1.0),
        endTime.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
