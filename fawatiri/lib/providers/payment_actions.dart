import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fawatiri/models/payment.dart';
import 'invoice_provider.dart';

final paymentActionsProvider = Provider((ref) => PaymentActions(ref));

class PaymentActions {
  final Ref ref;
  PaymentActions(this.ref);

  Future<String?> initiatePayment(double amount) async {
    final remaining = ref.read(remainingBalanceProvider);

    if (remaining <= 0) return 'لا يوجد رصيد مستحق حالياً';
    if (amount <= 0)    return 'أدخل مبلغاً صحيحاً';
    if (amount > remaining) return 'المبلغ يتجاوز الرصيد المتبقي';

    try {
      final payment = Payment(
        id: const Uuid().v4(),
        amount: amount,
        totalAtTime: remaining,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
      );
      await ref.read(firestoreServiceProvider).createPayment(payment);
      return null;
    } catch (e) {
      debugPrint('❌ initiatePayment error: $e');
      return 'فشل تسجيل الدفعة: $e';
    }
  }

  Future<String?> confirmPayment(String paymentId) async {
    try {
      await ref.read(firestoreServiceProvider).confirmPayment(paymentId);
      return null;
    } catch (e) {
      debugPrint('❌ confirmPayment error: $e');
      return 'فشل تأكيد الدفعة: $e';
    }
  }
}
