import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fawatiri/models/product.dart';
import 'invoice_provider.dart';

final productActionsProvider = Provider((ref) => ProductActions(ref));

class ProductActionResult {
  final bool success;
  final String message;
  const ProductActionResult({required this.success, required this.message});
}

class ProductActions {
  final Ref ref;
  ProductActions(this.ref);

  Future<ProductActionResult> add(String name, double price) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || price <= 0) {
      return const ProductActionResult(success: false, message: 'أدخل اسم وسعر صحيح');
    }
    try {
      final added = await ref.read(firestoreServiceProvider).saveProduct(
        Product(id: const Uuid().v4(), name: trimmed, defaultPrice: price),
      );
      
      // ← تحديث القائمة
      ref.invalidate(productsProvider);
      
      return ProductActionResult(
        success: true,
        message: added
            ? 'تمت إضافة المنتج'
            : 'هذا المنتج موجود مسبقاً — تم تحديث السعر إن لزم',
      );
    } catch (e) {
      debugPrint('❌ product add error: $e');
      return ProductActionResult(success: false, message: 'فشل الحفظ: $e');
    }
  }

  Future<ProductActionResult> edit(String id, String name, double price) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || price <= 0) {
      return const ProductActionResult(success: false, message: 'أدخل اسم وسعر صحيح');
    }
    try {
      await ref.read(firestoreServiceProvider).updateProduct(id, trimmed, price);
      
      // ← تحديث القائمة
      ref.invalidate(productsProvider);
      
      return const ProductActionResult(success: true, message: 'تم تحديث المنتج');
    } catch (e) {
      debugPrint('❌ product edit error: $e');
      return ProductActionResult(success: false, message: 'فشل الحفظ: $e');
    }
  }

  Future<ProductActionResult> delete(String id) async {
    try {
      await ref.read(firestoreServiceProvider).deleteProduct(id);
      
      // ← تحديث القائمة
      ref.invalidate(productsProvider);
      
      return const ProductActionResult(success: true, message: 'تم حذف المنتج');
    } catch (e) {
      debugPrint('❌ product delete error: $e');
      return ProductActionResult(success: false, message: 'فشل الحذف: $e');
    }
  }
}