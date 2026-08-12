import 'package:fawatiri/models/invoice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  const InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final color = invoice.status == InvoiceStatus.approved
        ? Colors.green
        : Colors.orange;
    final label = invoice.status == InvoiceStatus.approved
        ? 'معتمدة'
        : 'مرسلة';
    final date = DateFormat('d MMM yyyy', 'ar').format(invoice.createdAt);

    return ListTile(
      onTap: () => context.push('/invoice/${invoice.id}'),
      leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.receipt, color: Colors.white)),
      title:    Text('${invoice.items.length} منتج — ${invoice.total} ريال'),
      subtitle: Text(date),
      trailing: Chip(
          label: Text(label),
          backgroundColor: color.withOpacity(0.15)),
    );
  }
}