import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/models/payment.dart';
import 'package:fawatiri/models/product.dart';
import 'package:fawatiri/services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider((_) => FirestoreService());

final invoicesProvider = StreamProvider<List<Invoice>>((ref) {
  final role = ref.watch(authProvider);

  return role.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (r) {
      if (r == null) return const Stream.empty();
      return ref.read(firestoreServiceProvider).watchInvoices();
    },
  );
});

// ✅ إجمالي المشتريات المعتمدة (approved + paid)
final totalApprovedProvider = Provider<double>((ref) {
  final invoices = ref.watch(invoicesProvider).valueOrNull ?? [];
  return invoices
      .where((i) => 
          i.status == InvoiceStatus.approved || 
          i.status == InvoiceStatus.paid)
      .fold(0.0, (sum, i) => sum + i.total);
});

final totalPaidProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentsProvider).valueOrNull ?? [];
  return payments
      .where((p) => p.status == PaymentStatus.confirmed)
      .fold(0.0, (sum, p) => sum + p.amount);
});

final remainingBalanceProvider = Provider<double>((ref) {
  final total = ref.watch(totalApprovedProvider);
  final paid  = ref.watch(totalPaidProvider);
  return (total - paid).clamp(0.0, double.infinity);
});

/// Badge للمستلم فقط
final pendingCountProvider = Provider<int>((ref) {
  final role = ref.watch(authProvider).valueOrNull;
  if (role != UserRole.receiver) return 0;

  final invoices = ref.watch(invoicesProvider).valueOrNull ?? [];
  return invoices.where((i) => i.status == InvoiceStatus.sent).length;
});

final productsProvider = StreamProvider<List<Product>>((ref) {
  final role = ref.watch(authProvider);

  return role.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (r) {
      if (r == null) return const Stream.empty();
      return ref.read(firestoreServiceProvider).watchProducts();
    },
  );
});

// ── Payment Providers ──────────────────────────────

final paymentsProvider = StreamProvider<List<Payment>>((ref) {
  final role = ref.watch(authProvider);

  return role.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (r) {
      if (r == null) return const Stream.empty();
      return ref.read(firestoreServiceProvider).watchPayments();
    },
  );
});

final pendingPaymentTotalProvider = Provider<double>((ref) {
  final invoices = ref.watch(invoicesProvider).valueOrNull ?? [];
  return invoices
      .where((i) => i.status == InvoiceStatus.approved)
      .fold(0.0, (sum, i) => sum + i.total);
});

final approvedInvoiceIdsProvider = Provider<List<String>>((ref) {
  final invoices = ref.watch(invoicesProvider).valueOrNull ?? [];
  return invoices
      .where((i) => i.status == InvoiceStatus.approved)
      .map((i) => i.id)
      .toList();
});

final pendingPaymentsCountProvider = StreamProvider<int>((ref) {
  final role = ref.watch(authProvider);

  return role.when(
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
    data: (r) {
      if (r == null) return const Stream.empty();
      return ref.read(firestoreServiceProvider).watchPendingPaymentsCount();
    },
  );
});