/// نوع چیدمان لیست را مشخص می‌کند.
/// Defines the layout type for the list.
enum QuantumListType {
  /// چیدمان لیستی استاندارد (عمودی یا افقی)
  /// Standard list layout (vertical or horizontal).
  list,

  /// چیدمان شبکه‌ای (گرید)
  /// Grid layout.
  grid,
}

/// **[جدید]** نوع انیمیشن اسکرول را برای متد scrollOrJumpToIndex مشخص می‌کند.
/// **[New]** Defines the type of scroll animation for the scrollOrJumpToIndex method.
enum QuantumScrollAnimation {
  /// انیمیشن نرم و روان (پیش‌فرض)
  /// Smooth ease-in-out animation (default).
  smooth,

  /// انیمیشن با شتاب در ابتدا
  /// Accelerating animation.
  accelerated,

  /// انیمیشن فنری و جهنده
  /// Bouncy, elastic animation.
  bouncy,
}
