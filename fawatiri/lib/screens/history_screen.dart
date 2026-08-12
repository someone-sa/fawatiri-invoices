import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:fawatiri/widgets/invoice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  InvoiceStatus? filter;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(invoicesProvider).valueOrNull ?? [];
    final list = filter == null
        ? all
        : all.where((i) => i.status == filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('السجل')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(spacing: 8, children: [
              FilterChip(label: const Text('الكل'),
                  selected: filter == null,
                  onSelected: (_) => setState(() => filter = null)),
              FilterChip(label: const Text('مرسلة'),
                  selected: filter == InvoiceStatus.sent,
                  onSelected: (_) => setState(() => filter = InvoiceStatus.sent)),
              FilterChip(label: const Text('معتمدة'),
                  selected: filter == InvoiceStatus.approved,
                  onSelected: (_) => setState(() => filter = InvoiceStatus.approved)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => InvoiceCard(invoice: list[i]),
            ),
          ),
        ],
      ),
    );
  }
}