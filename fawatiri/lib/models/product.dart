import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double defaultPrice;

  const Product({
    required this.id,
    required this.name,
    required this.defaultPrice,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: d['name'] as String,
      defaultPrice: (d['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'price': defaultPrice};
}