import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/models/payment.dart';
import 'package:fawatiri/models/product.dart';
import 'package:fawatiri/core/utils/pin_hasher.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Invoices ──────────────────────────────────────
  Stream<List<Invoice>> watchInvoices() =>
      _db.collection('invoices')
         .orderBy('createdAt', descending: true)
         .snapshots()
         .map((s) => s.docs.map(Invoice.fromFirestore).toList());

Future<void> createInvoice(Invoice invoice) async {
  final number = await _getNextInvoiceNumber();
  await _db.collection('invoices').doc(invoice.id).set({
    ...invoice.toMap(),
    'invoiceNumber': number,
  });
}
  Future<void> updateInvoice(String id, Map<String, dynamic> data) =>
      _db.collection('invoices').doc(id).update(data);

  // ── Products (بدون تكرار بالاسم) ─────────────────
  Stream<List<Product>> watchProducts() =>
      _db.collection('products')
         .snapshots()
         .map((s) => s.docs.map(Product.fromFirestore).toList());

  /// يحفظ منتجاً جديداً، أو يحدّث السعر فقط لو الاسم موجود مسبقاً.
  /// يرجع true لو أُضيف منتج جديد فعلاً، false لو كان موجوداً مسبقاً.
  Future<bool> saveProduct(Product p) async {
    final name = p.name.trim();
    if (name.isEmpty) return false;

    final existing = await _db
        .collection('products')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentPrice = (doc.data()['price'] as num).toDouble();
      if (currentPrice != p.defaultPrice) {
        await doc.reference.update({'price': p.defaultPrice});
      }
      return false;
    } else {
      await _db.collection('products').doc(p.id).set({
        'name': name,
        'price': p.defaultPrice,
      });
      return true;
    }
  }

  Future<void> updateProduct(String id, String name, double price) =>
      _db.collection('products').doc(id).update({
        'name': name.trim(),
        'price': price,
      });

  Future<void> updateProductPrice(String id, double price) =>
      _db.collection('products').doc(id).update({'price': price});

  Future<void> deleteProduct(String id) =>
      _db.collection('products').doc(id).delete();

  // ── PIN — مصدر واحد موحّد في Firestore ───────────
  Future<void> saveReceiverPin(String pin) async {
    await _db.collection('config').doc('receiver_security').set({
      'pin': PinHasher.hash(pin),
      'pinEnabled': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> verifyReceiverPin(String input) async {
    final doc = await _db.collection('config').doc('receiver_security').get();
    if (!doc.exists) return false;
    return doc.data()?['pin'] == PinHasher.hash(input);
  }

  Future<bool> isReceiverPinEnabled() async {
    final doc = await _db.collection('config').doc('receiver_security').get();
    return doc.data()?['pinEnabled'] ?? false;
  }

  // ── Payments ──────────────────────────────────────

  Stream<List<Payment>> watchPayments() =>
      _db.collection('payments')
         .orderBy('createdAt', descending: true)
         .snapshots()
         .map((s) => s.docs.map(Payment.fromFirestore).toList());

  Future<void> createPayment(Payment payment) async {
    await _db.collection('payments').doc(payment.id).set(payment.toMap());
  }

  Future<void> confirmPayment(String paymentId) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': PaymentStatus.confirmed.name,
      'confirmedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> watchPendingPaymentsCount() =>
      _db.collection('payments')
         .where('status', isEqualTo: 'pending')
         .snapshots()
         .map((s) => s.docs.length);

  Future<int> _getNextInvoiceNumber() async {
    final snapshot = await _db
        .collection('invoices')
        .orderBy('invoiceNumber', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return 1;
    return (snapshot.docs.first.data()['invoiceNumber'] as int? ?? 0) + 1;
  }
}