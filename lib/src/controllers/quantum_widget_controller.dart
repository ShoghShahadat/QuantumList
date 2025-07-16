import 'package:flutter/material.dart';
import '../enums.dart';
import '../models.dart';
import 'scrollable_quantum_list_controller.dart';

/// کنترلر انقلابی ویجت کوانتومی - نسخه ۲.۰.۰
/// این کنترلر به شما اجازه می‌دهد تا لیست خود را مستقیماً با ویجت‌ها و شناسه‌هایشان مدیریت کنید.
/// دیگر نیازی به مدل‌های داده پیچیده نیست. فقط ویجت و شناسه‌اش!
///
/// The Revolutionary Quantum Widget Controller - v2.0.0
/// This controller allows you to manage your list directly with widgets and their IDs.
/// No more need for complex data models. Just the widget and its ID!
class QuantumWidgetController
    extends ScrollableQuantumListController<QuantumEntity> {
  /// کنترلر را با یک لیست اولیه (اختیاری) از موجودیت‌های کوانتومی مقداردهی می‌کند.
  QuantumWidgetController({List<QuantumEntity> initialItems = const []})
      : super(initialItems);

  /// یک ویجت جدید را با شناسه مشخص به انتهای لیست اضافه می‌کند.
  /// اگر شناسه‌ای از قبل وجود داشته باشد، هشداری نمایش داده شده و عملیات متوقف می‌شود.
  void add(QuantumEntity entity) {
    if (_findIndexById(entity.id) != -1) {
      debugPrint(
          "QuantumWidgetController: موجودیتی با شناسه '${entity.id}' از قبل وجود دارد. برای تغییر آن از متد update() استفاده کنید.");
      return;
    }
    super.add(entity);
  }

  /// یک ویجت را بر اساس شناسه‌اش از لیست حذف می‌کند.
  void remove(String id) {
    final index = _findIndexById(id);
    if (index != -1) {
      super.removeAt(index);
    } else {
      debugPrint(
          "QuantumWidgetController: موجودیتی با شناسه '$id' برای حذف یافت نشد.");
    }
  }

  /// ویجت یک موجودیت موجود را بر اساس شناسه‌اش به‌روزرسانی می‌کند.
  /// این متد باعث بازسازی (rebuild) بهینه همان ویجت در لیست می‌شود.
  void update(String id, Widget newWidget) {
    final index = _findIndexById(id);
    if (index != -1) {
      // یک موجودیت جدید با ویجت جدید می‌سازیم و جایگزین قبلی می‌کنیم.
      final newEntity = QuantumEntity(id: id, widget: newWidget);
      items[index] = newEntity;
      // با استفاده از استریم آپدیت، فقط همان یک آیتم را بازسازی می‌کنیم.
      updateNotifier.add(index);
    } else {
      debugPrint(
          "QuantumWidgetController: موجودیتی با شناسه '$id' برای به‌روزرسانی یافت نشد.");
    }
  }

  /// به سمت یک ویجت خاص بر اساس شناسه‌اش اسکرول می‌کند.
  Future<void> scrollTo(
    String id, {
    Duration duration = const Duration(milliseconds: 800),
    QuantumScrollAnimation animation = QuantumScrollAnimation.smooth,
    double alignment = 0.0,
  }) async {
    await super.scrollToItem(
      test: (entity) => entity.id == id,
      duration: duration,
      animation: animation,
      alignment: alignment,
    );
  }

  /// متد `insert` را بازنویسی می‌کنیم تا از استفاده اشتباه آن جلوگیری شود.
  /// در این معماری، افزودن فقط از طریق متد `add` معنی‌دار است.
  @override
  void insert(int index, QuantumEntity item) {
    debugPrint(
        "QuantumWidgetController: متد insert() در این کنترلر پشتیبانی نمی‌شود. لطفاً از add(entity) استفاده کنید.");
    // برای جلوگیری از خطاهای احتمالی، آن را به سمت متد add هدایت می‌کنیم.
    add(item);
  }

  /// یک متد داخلی برای پیدا کردن ایندکس یک موجودیت بر اساس شناسه‌اش.
  int _findIndexById(String id) {
    return items.indexWhere((entity) => entity.id == id);
  }
}
