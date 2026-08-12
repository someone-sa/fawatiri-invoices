import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, confirmed }

class Payment {
  final String id;
  final double amount;
  final double totalAtTime;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;

  const Payment({
    required this.id,
    required this.amount,
    required this.totalAtTime,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
  });

  factory Payment.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      amount: (d['amount'] as num).toDouble(),
      totalAtTime: (d['totalAtTime'] as num).toDouble(),
      status: PaymentStatus.values.byName(d['status'] as String),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      confirmedAt: d['confirmedAt'] != null
          ? (d['confirmedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'totalAtTime': totalAtTime,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'confirmedAt': confirmedAt != null
        ? Timestamp.fromDate(confirmedAt!)
        : null,
  };

  bool get isFullPayment => amount >= totalAtTime;

  double get difference => totalAtTime - amount;
}
