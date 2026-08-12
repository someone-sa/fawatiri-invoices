import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/models/item.dart';
import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/providers/invoice_actions.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:fawatiri/providers/pin_provider.dart';
import 'package:fawatiri/widgets/pin_dialog.dart';
import 'package:fawatiri/widgets/receiver_present_dialog.dart';
import 'package:fawatiri/widgets/product_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InvoiceBuilderScreen extends ConsumerStatefulWidget {
  const InvoiceBuilderScreen({super.key});
  @override
  ConsumerState<InvoiceBuilderScreen> createState() => _InvoiceBuilderScreenState();
}

class _InvoiceBuilderScreenState extends ConsumerState<InvoiceBuilderScreen> {
  final List<ProductRow> _rows = [ProductRow()];
  bool _isSending = false;

  void _addRow() => setState(() => _rows.add(ProductRow()));

  Future<void> _removeRow(int i) async {
    if (_rows.length == 1) return;
    final confirmed = await confirmDeleteRow(context, _rows[i].nameCtrl.text);
    if (confirmed) setState(() => _rows.removeAt(i));
  }

  double get _total => _rows.fold(0, (sum, r) => sum + r.subtotal);

  List<Item> _collectItems() => _rows
      .map((r) => Item(
            name: r.nameCtrl.text.trim(),
            price: double.tryParse(r.priceCtrl.text) ?? 0,
            quantity: r.qty,
          ))
      .where((i) => i.name.isNotEmpty && i.price > 0)
      .toList();

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1E),
        content: Text(
          text,
          style: AppTheme.bodyMedium(color: AppTheme.onSurface),
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (_isSending) return;

    final items = _collectItems();
    if (items.isEmpty) {
      _showMessage('⚠️ أضيفي منتجاً واحداً على الأقل');
      return;
    }

    final present = await askReceiverPresent(
      context, itemCount: items.length, total: _total,
    );
    if (present == null) return;

    setState(() => _isSending = true);

    var status = InvoiceStatus.sent;

    if (present) {
      final pinEnabled = await ref.read(pinEnabledProvider.future);

      if (!pinEnabled) {
        if (!mounted) return;
        setState(() => _isSending = false);
        _showMessage('يجب تعيين رمز PIN أولاً من الإعدادات');
        return;
      }

      if (!mounted) return;
      final ok = await showPinDialog(context, ref);

      if (ok) {
        status = InvoiceStatus.approved;
      } else {
        if (!mounted) return;
        final fallback = await confirmSendAsPending(context);
        if (!fallback) {
          setState(() => _isSending = false);
          return;
        }
      }
    }

    final error = await ref.read(invoiceActionsProvider).sendInvoice(
      items: items,
      total: _total,
      status: status,
    );

    if (!mounted) return;
    setState(() => _isSending = false);

    if (error != null) {
      _showMessage('❌ $error');
      return;
    }

    _showMessage(status == InvoiceStatus.approved
        ? '✅ تم إرسال الفاتورة واعتمادها'
        : '📤 تم إرسال الفاتورة، بانتظار الاعتماد');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.onSurface),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          'فاتورة جديدة',
          style: AppTheme.headlineSmall(color: AppTheme.onSurface),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._rows.asMap().entries.map((entry) {
                  final i = entry.key;
                  final row = entry.value;
                  return ProductRowWidget(
                    key: ValueKey(row.id),
                    row: row,
                    products: products,
                    index: i,
                    showDelete: _rows.length > 1,
                    onDelete: () => _removeRow(i),
                    onChanged: () => setState(() {}),
                  );
                }),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _addRow,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'منتج آخر',
                          style: AppTheme.labelMedium(color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'ر.ي',
                          style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _total.toStringAsFixed(2),
                        style: AppTheme.displayLarge(color: AppTheme.primary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send, size: 20),
                    label: Text(
                      _isSending ? 'جاري الإرسال...' : 'إرسال',
                      style: AppTheme.labelMedium(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: AppTheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final row in _rows) row.dispose();
    super.dispose();
  }
}