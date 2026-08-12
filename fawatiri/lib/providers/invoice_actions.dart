import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/models/item.dart';
import 'package:fawatiri/models/product.dart';
import 'invoice_provider.dart';

final invoiceActionsProvider = Provider((ref) => InvoiceActions(ref));

class InvoiceActions {
  final Ref ref;
  InvoiceActions(this.ref);

  /// يبني فاتورة جديدة ويحفظها + يحفظ منتجاتها في المكتبة.
  /// يرجع null عند النجاح، أو رسالة خطأ.
  Future<String?> sendInvoice({
    required List<Item> items,
    required double total,
    required InvoiceStatus status,
  }) async {
    if (items.isEmpty) return 'أضيفي منتجاً واحداً على الأقل';

    try {
      final invoice = Invoice(
      id: const Uuid().v4(),
      invoiceNumber: 0,        // ← placeholder، يُستبدل في createInvoice
      items: items,
      total: total,
      status: status,
      createdAt: DateTime.now(),

      );

      await ref.read(firestoreServiceProvider).createInvoice(invoice);

      for (final item in items) {
        await ref.read(firestoreServiceProvider).saveProduct(
          Product(id: const Uuid().v4(), name: item.name, defaultPrice: item.price),
        );
      }

      return null;
    } catch (e) {
      debugPrint('❌ sendInvoice error: $e');
      return 'فشل الإرسال: $e';
    }
  }

  /// يحفظ تعديلاً على فاتورة موجودة + يحفظ أي منتج جديد في المكتبة.
  Future<String?> saveEdit({
    required String invoiceId,
    required List<Item> items,
    required double total,
  }) async {
    if (items.isEmpty) return 'يجب وجود منتج واحد على الأقل';

    try {
      await ref.read(firestoreServiceProvider).updateInvoice(invoiceId, {
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'status': 'sent',
      });

      final existingProducts = ref.read(productsProvider).valueOrNull ?? [];
      for (final item in items) {
        final exists = existingProducts.any(
          (p) => p.name.trim().toLowerCase() == item.name.trim().toLowerCase(),
        );
        if (!exists) {
          await ref.read(firestoreServiceProvider).saveProduct(
            Product(id: const Uuid().v4(), name: item.name, defaultPrice: item.price),
          );
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ saveEdit error: $e');
      return 'فشل الحفظ: $e';
    }
  }

  /// يعتمد فاتورة (status → approved).
  Future<String?> approveInvoice(String invoiceId) async {
    try {
      await ref.read(firestoreServiceProvider)
          .updateInvoice(invoiceId, {'status': 'approved'});
      return null;
    } catch (e) {
      debugPrint('❌ approveInvoice error: $e');
      return 'فشل الاعتماد: $e';
    }
  }
}