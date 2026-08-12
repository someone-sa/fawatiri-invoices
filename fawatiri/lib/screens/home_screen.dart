import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/models/invoice.dart';
import 'package:fawatiri/providers/auth_provider.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onShowAll; // ← جديد

  const HomeScreen({super.key, this.onShowAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull;
    return role == UserRole.owner
        ? _OwnerHome(onShowAll: onShowAll)
        : _ReceiverHome(onShowAll: onShowAll);
  }
}

// ── OWNER HOME ──
class _OwnerHome extends ConsumerWidget {
  final VoidCallback? onShowAll;
  const _OwnerHome({this.onShowAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider).valueOrNull ?? [];
    final total = ref.watch(totalApprovedProvider);
    final approved = invoices.where((i) => i.status == InvoiceStatus.approved).length;
    final sent = invoices.where((i) => i.status == InvoiceStatus.sent).length;
    final recent = invoices.take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          children: [
            _StatCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'إجمالي المشتريات',
              value: '${total.toStringAsFixed(2)}',
              unit: 'ر.ي',
            ),
            const SizedBox(height: 12),
            _InvoiceStatsCard(
              total: invoices.length,
              sent: sent,
              approved: approved,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _RecentInvoicesSection(
          invoices: recent,
          onShowAll: onShowAll, // ← تمرير الدالة
        ),
      ],
    );
  }
}

// ── RECEIVER HOME ──
class _ReceiverHome extends ConsumerWidget {
  final VoidCallback? onShowAll;
  const _ReceiverHome({this.onShowAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider).valueOrNull ?? [];
    final pending = ref.watch(pendingCountProvider);
    final approved = invoices.where((i) => i.status == InvoiceStatus.approved).length;
    final recent = invoices.take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          children: [
            _StatCard(
              icon: Icons.inbox_outlined,
              label: 'فواتير واردة',
              value: '$pending',
              unit: 'فاتورة',
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.check_circle_outline,
              label: 'فواتير معتمدة',
              value: '$approved',
              unit: 'فاتورة',
            ),
          ],
        ),
        const SizedBox(height: 24),
        _RecentInvoicesSection(
          invoices: recent,
          onShowAll: onShowAll, // ← تمرير الدالة
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════
// WIDGETS مشتركة
// ══════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
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
        crossAxisAlignment: CrossAxisAlignment.end, // العنوان على اليمين
        children: [
          // ── الصف العلوي: الأيقونة يسار | العنوان يمين ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              Text(
                label,
                style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── القيمة: ر.ي يسار | الرقم يمين ──
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // ← محاذاة لليمين
            children: [
              // الوحدة على اليسار
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Text(
                  unit,
                  style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 6),
              // الرقم على اليمين
              Text(
                value,
                style: AppTheme.displayLarge(color: AppTheme.onSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceStatsCard extends StatelessWidget {
  final int total;
  final int sent;
  final int approved;

  const _InvoiceStatsCard({
    required this.total,
    required this.sent,
    required this.approved,
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
          // ── الصف العلوي: الأيقونة يسار | العنوان يمين ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  color: AppTheme.primary, size: 20),
              Text('إحصائيات الفواتير',
                  style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),

          // ── الأعمدة مع فواصل ──
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(
                  label: 'المرسلة',
                  value: '$sent',
                  color: AppTheme.statusSent,
                  icon: Icons.reply,
                ),
                const VerticalDivider(
                  color: AppTheme.outlineVariant,
                  width: 1,
                  indent: 8,
                  endIndent: 8,
                ),
                _StatColumn(
                  label: 'المعتمدة',
                  value: '$approved',
                  color: AppTheme.statusApproved,
                  icon: Icons.check_circle_outline,
                ),
                const VerticalDivider(
                  color: AppTheme.outlineVariant,
                  width: 1,
                  indent: 8,
                  endIndent: 8,
                ),
                _StatColumn(
                  label: 'الكل',
                  value: '$total',
                  color: AppTheme.onSurface,
                  icon: Icons.receipt_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // خلفية دائرية خلف الأيقونة
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
          style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
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
    );
  }
}


class _RecentInvoicesSection extends ConsumerWidget {
  final List<Invoice> invoices;
  final VoidCallback? onShowAll; // ← جديد

  const _RecentInvoicesSection({
    required this.invoices,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: onShowAll ?? () {}, // ← استخدام الدالة
              child: Row(
                children: [
                  const Icon(Icons.arrow_left,
                      size: 12, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Text('عرض الكل',
                      style: AppTheme.labelMedium(color: AppTheme.primary)),
                ],
              ),
            ),
            Text('أحدث الفواتير',
                style: AppTheme.headlineSmall(color: AppTheme.onSurface)),
          ],
        ),
        const SizedBox(height: 8),

        // ── القائمة ──
        if (invoices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 40,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text('لا توجد فواتير بعد',
                    style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: invoices.asMap().entries.map((entry) {
                final isLast = entry.key == invoices.length - 1;
                return _InvoiceListItem(
                  invoice: entry.value,
                  isLast: isLast,
                );
              }).toList(),
            ),
          ),

      ],
    );
  }
}

class _InvoiceListItem extends StatelessWidget {
  final Invoice invoice;
  final bool isLast;

  const _InvoiceListItem({required this.invoice, required this.isLast});

  // ── صياغة عدد المنتجات ──
  String _itemsLabel(int count) => switch (count) {
    1 => 'منتج واحد',
    2 => 'منتجان',
    _ => '$count منتجات',
  };

  @override
  Widget build(BuildContext context) {
    final isApproved = invoice.status == InvoiceStatus.approved;
    final date = DateFormat('d MMM yyyy', 'ar').format(invoice.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/invoice/${invoice.id}'),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(12))
            : BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
          ),
          child: Row(
            children: [

              // ── اليسار: المبلغ + الحالة ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('ر.ي',
                          style: AppTheme.labelSmall(
                              color: AppTheme.onSurfaceVariant)),
                      const SizedBox(width: 4),
                      Text(invoice.total.toStringAsFixed(2),
                          style: AppTheme.headlineSmall(
                              color: AppTheme.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(isApproved: isApproved),
                ],
              ),
              const SizedBox(width: 12),

              // ── الوسط: الرقم + التاريخ + عدد المنتجات ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // رقم الفاتورة
                    Text(
                      invoice.displayNumber,
                      style: AppTheme.bodyMedium(
                        color: AppTheme.primary,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    // التاريخ
                    Text(
                      date,
                      style: AppTheme.labelSmall(
                          color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    // عدد المنتجات
                    Text(
                      _itemsLabel(invoice.items.length),
                      style: AppTheme.labelSmall(
                          color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── اليمين: الأيقونة ──
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_outlined,
                    color: AppTheme.onSurfaceVariant, size: 20),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isApproved;
  const _StatusBadge({required this.isApproved});

  @override
  Widget build(BuildContext context) {
final color = isApproved ? AppTheme.statusApproved : AppTheme.statusSent;    final bgColor = color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.2);
    final label  = isApproved ? 'معتمدة' : 'مرسلة';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(label,
          style: AppTheme.labelSmall(color: color)),
    );
  }
}