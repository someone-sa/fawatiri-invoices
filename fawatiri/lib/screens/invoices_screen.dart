import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// ── فلتر الفواتير ──
final invoiceFilterProvider = StateProvider<InvoiceFilter>((ref) => InvoiceFilter.all);

enum InvoiceFilter { all, approved, sent }

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);
    final filter = ref.watch(invoiceFilterProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الفواتير',
          style: AppTheme.headlineSmall(color: AppTheme.onSurface),
        ),
      ),
      body: invoicesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'خطأ: $e',
            style: AppTheme.bodyMedium(color: AppTheme.error),
          ),
        ),
        data: (invoices) {
          final filtered = _filterInvoices(invoices, filter);

          return Column(
            children: [
              // ── بطاقة الفلاتر ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: _InvoiceFilterCard(
                  currentFilter: filter,
                  onFilterChanged: (f) => ref.read(invoiceFilterProvider.notifier).state = f,
                  counts: _getCounts(invoices),
                ),
              ),

              // ── قائمة الفواتير ──
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(
                        filter: filter,
                        onClearFilter: () => ref.read(invoiceFilterProvider.notifier).state = InvoiceFilter.all,
                      )
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        backgroundColor: const Color(0xFF1E1E1E),
                        onRefresh: () async {
                          ref.invalidate(invoicesProvider);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => _InvoiceCard(
                            invoice: filtered[i],
                            onTap: () => context.push('/invoice/${filtered[i].id}'),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices, InvoiceFilter filter) => switch (filter) {
    InvoiceFilter.approved => invoices.where((i) => i.status == InvoiceStatus.approved).toList(),
    InvoiceFilter.sent => invoices.where((i) => i.status == InvoiceStatus.sent).toList(),
    InvoiceFilter.all => invoices,
  };

  Map<InvoiceFilter, int> _getCounts(List<Invoice> invoices) {
    return {
      InvoiceFilter.all: invoices.length,
      InvoiceFilter.approved: invoices.where((i) => i.status == InvoiceStatus.approved).length,
      InvoiceFilter.sent: invoices.where((i) => i.status == InvoiceStatus.sent).length,
    };
  }
}

// ── بطاقة الفلاتر ──
class _InvoiceFilterCard extends StatelessWidget {
  final InvoiceFilter currentFilter;
  final ValueChanged<InvoiceFilter> onFilterChanged;
  final Map<InvoiceFilter, int> counts;

  const _InvoiceFilterCard({
    required this.currentFilter,
    required this.onFilterChanged,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── العنوان ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.filter_list_outlined,
                  color: AppTheme.primary, size: 20),
              Text('تصفية الفواتير',
                  style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),

          // ── الأعمدة: الكل | المعتمدة | المرسلة ──
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FilterColumn(
                  label: 'المرسلة',
                  value: '${counts[InvoiceFilter.sent] ?? 0}',
                  color: AppTheme.statusSent,
                  icon: Icons.reply,
                  isSelected: currentFilter == InvoiceFilter.sent,
                  onTap: () => onFilterChanged(InvoiceFilter.sent),
                ),
                const VerticalDivider(
                  color: AppTheme.outlineVariant,
                  width: 1,
                  indent: 8,
                  endIndent: 8,
                ),
                _FilterColumn(
                  label: 'المعتمدة',
                  value: '${counts[InvoiceFilter.approved] ?? 0}',
                  color: AppTheme.statusApproved,
                  icon: Icons.check_circle_outline,
                  isSelected: currentFilter == InvoiceFilter.approved,
                  onTap: () => onFilterChanged(InvoiceFilter.approved),
                ),
                const VerticalDivider(
                  color: AppTheme.outlineVariant,
                  width: 1,
                  indent: 8,
                  endIndent: 8,
                ),
                _FilterColumn(
                  label: 'الكل',
                  value: '${counts[InvoiceFilter.all] ?? 0}',
                  color: AppTheme.onSurface,
                  icon: Icons.receipt_outlined,
                  isSelected: currentFilter == InvoiceFilter.all,
                  onTap: () => onFilterChanged(InvoiceFilter.all),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── عمود الفلتر ──
class _FilterColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterColumn({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              label,
              style: AppTheme.labelSmall(
                color: isSelected ? color : AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.headlineSmall(color: color).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── بطاقة الفاتورة ──
class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const _InvoiceCard({
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = invoice.status == InvoiceStatus.approved;
    final dateStr = DateFormat('d MMM yyyy', 'ar').format(invoice.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ← اليسار: المبلغ + الحالة
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ر.ي',
                        style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        invoice.total.toStringAsFixed(2),
                        style: AppTheme.headlineSmall(color: AppTheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(isApproved: isApproved),
                ],
              ),
              const SizedBox(width: 12),

              // الوسط: التفاصيل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${invoice.items.length} منتج',
                      style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // → اليمين: الأيقونة
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_outlined,
                  color: AppTheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── شارة الحالة ──
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

// ── حالة الفارغة ──
class _EmptyState extends StatelessWidget {
  final InvoiceFilter filter;
  final VoidCallback onClearFilter;

  const _EmptyState({
    required this.filter,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    final messages = {
      InvoiceFilter.all: 'لا توجد فواتير بعد',
      InvoiceFilter.approved: 'لا توجد فواتير معتمدة',
      InvoiceFilter.sent: 'لا توجد فواتير مرسلة',
    };

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppTheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              messages[filter] ?? '',
              style: AppTheme.headlineSmall(color: AppTheme.onSurface),
            ),
            const SizedBox(height: 8),
            if (filter != InvoiceFilter.all)
              TextButton(
                onPressed: onClearFilter,
                child: Text(
                  'عرض الكل',
                  style: AppTheme.labelMedium(color: AppTheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}