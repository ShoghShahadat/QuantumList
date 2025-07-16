import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A library of helper functions for creating beautiful, pre-built entrance animations.
class QuantumAnimations {
  /// A fade-in animation for the incoming item.
  static Widget fadeIn(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

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

  /// A slide and fade-in animation from the right.
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

  /// A professional 3D flip animation around the Y axis.
  /// The child is only visible during the second half of the animation
  /// to prevent a distorted "mirrored" view.
  static Widget flipInY(
    BuildContext context,
    Widget child,
    Animation<double> animation,
  ) {
    final curvedAnimation =
        CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: curvedAnimation,
      child: child,
      builder: (context, child) {
        final isAnimating = curvedAnimation.value < 1.0;
        final isSecondHalf = curvedAnimation.value > 0.5;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(math.pi * (1 - curvedAnimation.value)),
          alignment: Alignment.center,
          // Only show the child in the second half of the flip
          child: isSecondHalf || !isAnimating ? child : const SizedBox.shrink(),
        );
      },
    );
  }
}
