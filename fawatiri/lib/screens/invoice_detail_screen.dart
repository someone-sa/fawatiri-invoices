import 'package:collection/collection.dart';
import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/providers/auth_provider.dart';
import 'package:fawatiri/providers/invoice_actions.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:fawatiri/providers/pin_provider.dart';
import 'package:fawatiri/widgets/pin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const InvoiceDetailScreen({super.key, required this.id});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _isApproving = false;

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _approve(Invoice invoice) async {
    if (_isApproving) return;
    setState(() => _isApproving = true);

    final pinEnabled = await ref.read(pinEnabledProvider.future);
    bool ok = true;

    if (pinEnabled) {
      if (!mounted) return;
      ok = await showPinDialog(context, ref);
    }

    if (!ok) {
      if (mounted) {
        setState(() => _isApproving = false);
        _showMessage('❌ رمز PIN غير صحيح');
      }
      return;
    }

    final error = await ref.read(invoiceActionsProvider).approveInvoice(invoice.id);

    if (!mounted) return;
    setState(() => _isApproving = false);

    if (error != null) {
      _showMessage('❌ $error');
      return;
    }

    _showMessage('✅ تم اعتماد الفاتورة');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).valueOrNull;
    final invoice = ref.watch(invoicesProvider).valueOrNull
        ?.firstWhereOrNull((i) => i.id == widget.id);

    if (invoice == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final isApproved = invoice.status == InvoiceStatus.approved;
    final dateStr = DateFormat('d MMM yyyy', 'ar').format(invoice.createdAt);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isApproved ? '✅ فاتورة معتمدة' : 'تفاصيل الفاتورة',
          style: AppTheme.headlineSmall(color: AppTheme.onSurface),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // ← يسار الشاشة
      floatingActionButton: 
      (role == UserRole.owner && invoice.status == InvoiceStatus.sent)
        ? FloatingActionButton.extended(
            onPressed: () => context.push('/invoice/${invoice.id}/edit'),
            backgroundColor: AppTheme.primaryContainer,
            foregroundColor: AppTheme.onPrimaryContainer,
            icon: const Icon(Icons.edit, size: 20),
            label: Text(
              'تعديل',
              style: AppTheme.labelMedium(color: AppTheme.onPrimaryContainer),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          )
        : null,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── الهيدر: التاريخ + الشارة ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'تاريخ الإصدار: $dateStr',
                        style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      _StatusBadge(isApproved: isApproved),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── جدول المنتجات ──
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      // رأس الجدول
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHigh,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'الإجمالي',
                                style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'السعر',
                                style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'الكمية',
                                style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'الوصف',
                                style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // صفوف المنتجات
                      ...invoice.items.asMap().entries.map((entry) {
                        final isLast = entry.key == invoice.items.length - 1;
                        final item = entry.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          item.subtotal.toStringAsFixed(2),
                                          style: AppTheme.bodyMedium(color: AppTheme.onSurface).copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          item.price.toStringAsFixed(2),
                                          style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '${item.quantity}',
                                          style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Center(
                                        child: Text(
                                          item.name,
                                          style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── بطاقة الإجمالي ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.5),
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
                            invoice.total.toStringAsFixed(2),
                            style: AppTheme.displayLarge(color: AppTheme.primary),
                          ),
                        ],
                      ),
                      Text(
                        ': الإجمالي المستحق',
                        style: AppTheme.headlineSmall(color: AppTheme.onSurface),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── الأزرار السفلية للمستلم فقط ──
          if (role == UserRole.receiver && invoice.status == InvoiceStatus.sent)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ← اليسار: زر اعتماد (أخضر)
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _isApproving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_circle, size: 20),
                        label: Text(
                          _isApproving ? 'جاري الاعتماد...' : 'اعتماد الفاتورة',
                          style: AppTheme.labelMedium(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.statusApproved,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isApproving ? null : () => _approve(invoice),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ← اليمين: زر رفض (محيط)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.onSurface,
                          side: BorderSide(color: AppTheme.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'رفض الفاتورة',
                          style: AppTheme.labelMedium(color: AppTheme.onSurface),
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
}

class _StatusBadge extends StatelessWidget {
  final bool isApproved;
  const _StatusBadge({required this.isApproved});

  @override
  Widget build(BuildContext context) {
    final color = isApproved ? AppTheme.statusApproved : AppTheme.statusSent;
    final bgColor = color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.2);
    final label = isApproved ? 'معتمدة' : 'مرسلة';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.labelSmall(color: color),
          ),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}