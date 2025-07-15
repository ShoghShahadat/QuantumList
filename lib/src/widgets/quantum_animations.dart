import 'package:flutter/material.dart';

/// یک کتابخانه از توابع کمکی برای ساخت انیمیشن‌های ورود زیبا و آماده.
/// A library of helper functions for creating beautiful, pre-built entrance animations.
class QuantumAnimations {
  /// انیمیشن محو شدن (FadeIn) برای آیتم ورودی.
  /// A fade-in animation for the entering item.
  static Widget fadeIn(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// انیمیشن اسلاید و محو شدن از پایین.
  /// A slide and fade-in animation from the bottom.
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
  /// A slide and fade-in animation from the left.
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

  /// انیمیشن بزرگ شدن و محو شدن (Scale & Fade).
  /// A scale and fade-in animation.
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
}
