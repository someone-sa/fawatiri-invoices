class Item {
  final String name;
  final double price;
  final int quantity;

  const Item({required this.name, required this.price, required this.quantity});

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'quantity': quantity,
  };

  factory Item.fromMap(Map<String, dynamic> m) => Item(
    name: m['name'] as String,
    price: (m['price'] as num).toDouble(),
    quantity: m['quantity'] as int,
  );
}