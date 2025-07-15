import 'package:flutter/material.dart';
import 'dart:math' as math;

/// یک کتابخانه از توابع کمکی برای ساخت انیمیشن‌های ورود زیبا و آماده.
/// A library of helper functions for creating beautiful, pre-built entrance animations.
class QuantumAnimations {
  /// انیمیشن محو شدن (FadeIn) برای آیتم ورودی.
  static Widget fadeIn(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// انیمیشن اسلاید و محو شدن از پایین.
  static Widget slideInFromBottom(
    BuildContext context,
    Widget child,
    Animation<double> animation, {
    double slideOffset = 50.0,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, slideOffset / 100),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  /// انیمیشن اسلاید و محو شدن از چپ.
  static Widget slideInFromLeft(
    BuildContext context,
    Widget child,
    Animation<double> animation, {
    double slideOffset = 50.0,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(-slideOffset / 100, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  /// **[جدید]** انیمیشن اسلاید و محو شدن از راست.
  /// **[New]** A slide and fade-in animation from the right.
  static Widget slideInFromRight(
    BuildContext context,
    Widget child,
    Animation<double> animation, {
    double slideOffset = 50.0,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(slideOffset / 100, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }

  /// انیمیشن بزرگ شدن و محو شدن (Scale & Fade).
  static Widget scaleIn(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

  /// **[جدید]** انیمیشن چرخش سه‌بعدی حول محور Y.
  /// **[New]** A 3D flip animation around the Y axis.
  static Widget flipInY(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    final a = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: a,
      child: child,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(math.pi * (1 - a.value)),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
