/// Defines the layout type for the list.
enum QuantumListType {
  /// A standard vertical or horizontal list layout.
  list,

  /// A grid layout.
  grid,
}

/// Defines the type of scroll animation for the scrollToItem method.
enum QuantumScrollAnimation {
  /// A smooth, ease-in-out animation.
  smooth,

  /// An accelerating animation.
  accelerated,

  /// A springy, bouncy animation.
  bouncy,

  /// A decelerating animation.
  decelerated,

  /// A constant speed, linear animation.
  linear,
}

/// Defines the entrance animation types for list items.
enum QuantumAnimationType {
  /// No animation.
  none,

  /// A fade-in animation.
  fadeIn,

  /// A scale-up animation.
  scaleIn,

  /// A slide-in animation from the bottom.
  slideInFromBottom,

  /// A slide-in animation from the left.
  slideInFromLeft,

  /// A slide-in animation from the right.
  slideInFromRight,

  /// A 3D flip animation around the Y axis.
  flipInY,
}
