import 'package:collection/collection.dart';
import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/models/item.dart';
import 'package:fawatiri/providers/invoice_actions.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:fawatiri/widgets/product_row.dart';
import 'package:fawatiri/widgets/receiver_present_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InvoiceEditScreen extends ConsumerStatefulWidget {
  final String id;
  const InvoiceEditScreen({super.key, required this.id});

  @override
  ConsumerState<InvoiceEditScreen> createState() => _InvoiceEditScreenState();
}

class _InvoiceEditScreenState extends ConsumerState<InvoiceEditScreen> {
  final List<ProductRow> _rows = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  void _loadInvoice() {
    final invoice = ref.read(invoicesProvider).valueOrNull
        ?.firstWhereOrNull((i) => i.id == widget.id);

    if (invoice == null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _loadInvoice();
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _rows.clear();
      for (final item in invoice.items) {
        final row = ProductRow();
        row.nameCtrl.text = item.name;
        row.priceCtrl.text = item.price.toString();
        row.qty = item.quantity;
        _rows.add(row);
      }
      _isLoading = false;
    });
  }

  void _markChanged() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  void _addRow() {
    setState(() => _rows.add(ProductRow()));
    _markChanged();
  }

  Future<void> _removeRow(int i) async {
    if (_rows.length == 1) return;
    final confirmed = await confirmDeleteRow(context, _rows[i].nameCtrl.text);
    if (confirmed) {
      setState(() => _rows.removeAt(i));
      _markChanged();
    }
  }

  double get _total => _rows.fold(0, (sum, r) => sum + r.subtotal);

  Future<bool> _confirmDiscard() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              'تجاهل التعديلات؟',
              style: AppTheme.headlineSmall(color: AppTheme.onSurface),
            ),
            content: Text(
              'لم تحفظي بعد. هل تريدين الخروج بدون حفظ؟',
              style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'البقاء',
                  style: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'تجاهل والخروج',
                  style: AppTheme.labelMedium(color: AppTheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

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

  Future<void> _saveEdit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final items = _rows
        .map((r) => Item(
              name: r.nameCtrl.text.trim(),
              price: double.tryParse(r.priceCtrl.text) ?? 0,
              quantity: r.qty,
            ))
        .where((i) => i.name.isNotEmpty && i.price > 0)
        .toList();

    final error = await ref.read(invoiceActionsProvider).saveEdit(
          invoiceId: widget.id,
          items: items,
          total: _total,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      _showMessage('❌ $error');
      return;
    }

    _hasUnsavedChanges = false;
    _showMessage('✅ تم حفظ التعديل بنجاح');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final products = ref.watch(productsProvider).valueOrNull ?? [];

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard && context.mounted) context.pop();
      },
      child: Scaffold(
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
            'تعديل الفاتورة',
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
                      onChanged: () {
                        setState(() {});
                        _markChanged();
                      },
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
                            style: AppTheme.labelSmall(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _total.toStringAsFixed(2),
                          style: AppTheme.displayLarge(
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveEdit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save, size: 20),
                      label: Text(
                        _isSaving ? 'جاري الحفظ...' : 'حفظ التعديل',
                        style: AppTheme.labelMedium(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainer,
                        foregroundColor: AppTheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
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
      ),
    );
  }

  @override
  void dispose() {
    for (final row in _rows) row.dispose();
    super.dispose();
  }
}