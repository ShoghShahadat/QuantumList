/// نوع چیدمان لیست را مشخص می‌کند.
/// Defines the layout type for the list.
enum QuantumListType {
  /// چیدمان لیستی استاندارد (عمودی یا افقی)
  list,

  /// چیدمان شبکه‌ای (گرید)
  grid,
}

/// **[اصلاح شده]** انواع انیمیشن اسکرول را برای متد scrollToItem مشخص می‌کند.
/// **[Updated]** Defines the type of scroll animation for the scrollToItem method.
enum QuantumScrollAnimation {
  /// انیمیشن نرم و روان
  smooth,

  /// انیمیشن با شتاب در ابتدا
  accelerated,

  /// انیمیشن فنری و جهنده
  bouncy,

  /// **[جدید]** انیمیشن با کاهش شتاب در انتها
  decelerated,

  /// **[جدید]** انیمیشن خطی با سرعت ثابت
  linear,
}

/// **[جدید]** انواع انیمیشن‌های ورودی برای آیتم‌های لیست.
/// **[New]** Defines the entrance animation types for list items.
enum QuantumAnimationType {
  /// محو شدن
  fadeIn,

  /// بزرگ شدن
  scaleIn,

  /// اسلاید از پایین
  slideInFromBottom,

  /// اسلاید از چپ
  slideInFromLeft,

  /// **[جدید]** اسلاید از راست
  slideInFromRight,

  /// **[جدید]** چرخش سه‌بعدی حول محور Y
  flipInY,
}
