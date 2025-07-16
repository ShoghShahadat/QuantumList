import 'package:flutter/material.dart';

/// Defines the type of animation choreography for the list items.
/// انواع الگوهای رقص انیمیشن برای آیتم‌های لیست را تعریف می‌کند.
enum ChoreographyType {
  /// All items animate in simultaneously.
  /// تمام آیتم‌ها به صورت همزمان وارد می‌شوند.
  simultaneous,

  /// Items animate in one after another with a fixed delay.
  /// آیتم‌ها با یک تاخیر ثابت، یکی پس از دیگری وارد می‌شوند.
  staggered,

  /// Items animate in a smooth, overlapping wave pattern.
  /// آیتم‌ها با یک الگوی موجی نرم و همپوشانی شده وارد می‌شوند.
  wave,
}

/// A class that defines and calculates animation curves for list items
/// to create complex, choreographed entrance effects.
/// کلاسی برای تعریف و محاسبه انیمیشن‌های آیتم‌های لیست جهت خلق جلوه‌های ورودی پیچیده.
class QuantumChoreography {
  /// The type of choreography pattern to apply.
  final ChoreographyType type;

  /// The delay between the start of each item's animation.
  /// Used by 'staggered' and 'wave' types.
  final Duration stagger;

  /// The duration of each individual item's animation, as a fraction of the total animation time.
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

  /// Calculates the specific animation curve for a single item based on its index.
  /// انیمیشن خاص یک آیتم را بر اساس ایندکس آن محاسبه می‌کند.
  Animation<double> getAnimation({
    required Animation<double> parent,
    required int index,
    // **[CRITICAL FIX]** The total duration is now passed in as a parameter
    // instead of trying to read it from the abstract Animation class.
    required Duration totalDuration,
  }) {
    // If the parent animation has no duration, we can't create intervals.
    if (totalDuration == Duration.zero) {
      return parent;
    }

    switch (type) {
      case ChoreographyType.staggered:
      case ChoreographyType.wave:
        // **[CRITICAL FIX]** Use the passed-in totalDuration.
        final double totalDurationMs = totalDuration.inMilliseconds.toDouble();
        final double staggerMs = stagger.inMilliseconds.toDouble();

        // Calculate the start time of this item's animation as a fraction of the total duration.
        final double startTime = (index * staggerMs) / totalDurationMs;
        // The end time is the start time plus the fraction of the total duration this item should animate for.
        final double endTime = startTime + itemDurationFraction;

        return CurvedAnimation(
          parent: parent,
          // The Interval curve ensures this item's animation only runs within its designated time slice.
          curve: Interval(
            startTime.clamp(0.0, 1.0),
            endTime.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        );
      case ChoreographyType.simultaneous:
      default:
        // For simultaneous, every item just uses the parent animation directly.
        return parent;
    }
  }
}
