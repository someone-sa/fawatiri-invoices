import 'package:cloud_firestore/cloud_firestore.dart';
import 'item.dart';

enum InvoiceStatus { sent, approved, paid }

class Invoice {
  final String id;
  final int invoiceNumber;      // ← جديد
  final List<Item> items;
  final double total;
  final InvoiceStatus status;
  final DateTime createdAt;

  const Invoice({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.invoiceNumber,
  });

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      invoiceNumber: d['invoiceNumber'] as int? ?? 0, // ← 0 للفواتير القديمة
      items: (d['items'] as List)
          .map((e) => Item.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      total: (d['total'] as num).toDouble(),
      status: InvoiceStatus.values.byName(d['status'] as String),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  
  }

  Map<String, dynamic> toMap() => {
    'items': items.map((e) => e.toMap()).toList(),
    'total': total,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    // invoiceNumber يُضاف في createInvoice مباشرة
  };
  // عرض الرقم في الـ UI
  String get displayNumber =>
      invoiceNumber > 0 ? '#${invoiceNumber.toString().padLeft(3, '0')}' : '—';
}