import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/models/payment.dart';
import 'package:fawatiri/providers/auth_provider.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:fawatiri/providers/payment_actions.dart';
import 'package:fawatiri/providers/pin_provider.dart';
import 'package:fawatiri/widgets/pin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull;
    final paymentsAsync = ref.watch(paymentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: paymentsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(
            child: Text('خطأ: $e',
                style: AppTheme.bodyMedium(color: AppTheme.error))),
        data: (payments) {
          final pending = payments
              .where((p) => p.status == PaymentStatus.pending)
              .toList();
          final hasPending = pending.isNotEmpty;

          final confirmed = payments
              .where((p) => p.status == PaymentStatus.confirmed)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _CurrentTotalCard(
                hasPending: hasPending,
                onInitiatePayment: () =>
                    _showInitiateDialog(context, ref),
              ),
              const SizedBox(height: 16),
              if (hasPending) ...[
                _PendingPaymentCard(
                  payment: pending.first,
                  role: role,
                  onConfirm: () =>
                      _confirmPayment(context, ref, pending.first.id),
                ),
                const SizedBox(height: 16),
              ],
              _PaymentHistorySection(payments: confirmed),
            ],
          );
        },
      ),
    );
  }

  void _showInitiateDialog(
      BuildContext context, WidgetRef ref) {
    final remaining = ref.read(remainingBalanceProvider);
    final ctrl = TextEditingController(
        text: remaining.toStringAsFixed(2));
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text('تسجيل دفعة',
              style: AppTheme.headlineSmall(color: AppTheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الحساب المتبقي',
                        style: AppTheme.labelSmall(
                            color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${remaining.toStringAsFixed(2)} ر.ي',
                        style: AppTheme.headlineSmall(
                            color: AppTheme.error)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('المبلغ الذي ستدفعه',
                  style: AppTheme.labelMedium(
                      color: AppTheme.onSurfaceVariant)),
              const SizedBox(height: 8),
              TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                textAlign: TextAlign.right,
                style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                decoration: InputDecoration(
                  suffixText: 'ر.ي',
                  hintText: '0.00',
                  filled: true,
                  fillColor: AppTheme.surfaceContainerHigh
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: AppTheme.outlineVariant
                            .withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: AppTheme.outlineVariant
                            .withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppTheme.primaryContainer),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text('إلغاء',
                  style: AppTheme.labelMedium(
                      color: AppTheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: Colors.white,
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      final amount =
                          double.tryParse(ctrl.text) ?? 0;
                      setState(() => isSaving = true);

                      final error = await ref
                          .read(paymentActionsProvider)
                          .initiatePayment(amount);

                      if (!ctx.mounted) return;

                      if (error != null) {
                        setState(() => isSaving = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                              content: Text('❌ $error')),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('✅ تم تسجيل الدفعة، بانتظار تأكيد المستلم')),
                      );
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('تسجيل',
                      style: AppTheme.labelMedium(
                          color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPayment(
      BuildContext context, WidgetRef ref, String paymentId) async {
    final pinEnabled =
        await ref.read(pinEnabledProvider.future);
    bool ok = true;

    if (pinEnabled) {
      if (!context.mounted) return;
      ok = await showPinDialog(context, ref);
    }

    if (!ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ رمز PIN غير صحيح')),
        );
      }
      return;
    }

    final error =
        await ref.read(paymentActionsProvider).confirmPayment(paymentId);

    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ $error')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم تأكيد الدفعة بنجاح')),
    );
  }
}

// ══════════════════════════════════════════
// WIDGETS
// ══════════════════════════════════════════

class _CurrentTotalCard extends ConsumerWidget {
  final bool hasPending;
  final VoidCallback onInitiatePayment;

  const _CurrentTotalCard({
    required this.hasPending,
    required this.onInitiatePayment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull;
    final totalApproved = ref.watch(totalApprovedProvider);
    final totalPaid     = ref.watch(totalPaidProvider);
    final remaining     = ref.watch(remainingBalanceProvider);
    final hasAmount     = remaining > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: AppTheme.primary, size: 22),
              Text('الحساب',
                  style: AppTheme.labelMedium(
                      color: AppTheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          _AccountRow(
            label: 'إجمالي المشتريات',
            value: totalApproved,
            color: AppTheme.onSurface,
          ),
          const SizedBox(height: 8),
          Divider(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          _AccountRow(
            label: 'إجمالي المدفوع',
            value: totalPaid,
            color: AppTheme.statusApproved,
          ),
          const SizedBox(height: 8),
          _AccountRow(
            label: 'الحساب المتبقي',
            value: remaining,
            color: hasAmount ? AppTheme.error : AppTheme.statusApproved,
            isBold: true,
          ),
          const SizedBox(height: 20),
          if (role == UserRole.owner && !hasPending && hasAmount)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onInitiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.payments_outlined, size: 20),
                label: Text('تسجيل دفعة',
                    style: AppTheme.labelMedium(color: Colors.white)),
              ),
            ),
          if (hasPending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('بانتظار تأكيد المستلم',
                      style: AppTheme.labelMedium(
                          color: AppTheme.secondary)),
                  const SizedBox(width: 8),
                  const Icon(Icons.hourglass_empty,
                      color: AppTheme.secondary, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isBold;

  const _AccountRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('ر.ي',
                style: AppTheme.labelSmall(
                    color: AppTheme.onSurfaceVariant)),
            const SizedBox(width: 4),
            Text(
              value.toStringAsFixed(2),
              style: isBold
                  ? AppTheme.headlineSmall(color: color)
                      .copyWith(fontWeight: FontWeight.w700)
                  : AppTheme.bodyMedium(color: color),
            ),
          ],
        ),
        Text(label,
            style: AppTheme.labelMedium(
                color: AppTheme.onSurfaceVariant)),
      ],
    );
  }
}

class _PendingPaymentCard extends StatelessWidget {
  final Payment payment;
  final UserRole? role;
  final VoidCallback onConfirm;

  const _PendingPaymentCard({
    required this.payment,
    required this.role,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color:
                          AppTheme.secondary.withValues(alpha: 0.3)),
                ),
                child: Text('في الانتظار',
                    style: AppTheme.labelSmall(
                        color: AppTheme.secondary)),
              ),
              Text('دفعة معلقة',
                  style: AppTheme.headlineSmall(
                      color: AppTheme.onSurface)),
            ],
          ),
          const SizedBox(height: 16),
          _PaymentDetailRow(
            label: 'المبلغ المدفوع',
            value: '${payment.amount.toStringAsFixed(2)} ر.ي',
            valueColor: AppTheme.primary,
          ),
          const SizedBox(height: 8),
          _PaymentDetailRow(
            label: 'الإجمالي المستحق',
            value: '${payment.totalAtTime.toStringAsFixed(2)} ر.ي',
          ),
          if (!payment.isFullPayment) ...[
            const SizedBox(height: 8),
            _PaymentDetailRow(
              label: 'الفرق المتبقي',
              value: '${payment.difference.toStringAsFixed(2)} ر.ي',
              valueColor: AppTheme.error,
            ),
          ],
          const SizedBox(height: 20),
          if (role == UserRole.receiver)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text('تأكيد الاستلام',
                    style: AppTheme.labelMedium(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentHistorySection extends StatelessWidget {
  final List<Payment> payments;

  const _PaymentHistorySection({required this.payments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('سجل الدفعات',
            style: AppTheme.headlineSmall(color: AppTheme.onSurface)),
        const SizedBox(height: 12),
        if (payments.isEmpty)
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
                    color: AppTheme.onSurfaceVariant
                        .withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text('لا توجد دفعات مسجلة بعد',
                    style: AppTheme.bodyMedium(
                        color: AppTheme.onSurfaceVariant)),
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
              children: payments.asMap().entries.map((entry) {
                final isLast = entry.key == payments.length - 1;
                return _PaymentHistoryItem(
                  payment: entry.value,
                  isLast: isLast,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _PaymentHistoryItem extends StatelessWidget {
  final Payment payment;
  final bool isLast;

  const _PaymentHistoryItem({
    required this.payment,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy', 'ar').format(payment.createdAt);
    final confirmedDate = payment.confirmedAt != null
        ? DateFormat('d MMM yyyy', 'ar').format(payment.confirmedAt!)
        : null;

    return Container(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('ر.ي',
                      style: AppTheme.labelSmall(
                          color: AppTheme.onSurfaceVariant)),
                  const SizedBox(width: 4),
                  Text(payment.amount.toStringAsFixed(2),
                      style: AppTheme.headlineSmall(
                          color: AppTheme.statusApproved)),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (payment.isFullPayment
                          ? AppTheme.statusApproved
                          : AppTheme.secondary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (payment.isFullPayment
                            ? AppTheme.statusApproved
                            : AppTheme.secondary)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  payment.isFullPayment ? 'كامل' : 'جزئي',
                  style: AppTheme.labelSmall(
                    color: payment.isFullPayment
                        ? AppTheme.statusApproved
                        : AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('تاريخ الدفع: $date',
                    style: AppTheme.labelSmall(
                        color: AppTheme.onSurfaceVariant)),
                if (confirmedDate != null) ...[
                  const SizedBox(height: 2),
                  Text('تأكيد الاستلام: $confirmedDate',
                      style: AppTheme.labelSmall(
                          color: AppTheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.statusApproved.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppTheme.statusApproved, size: 20),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PaymentDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value,
            style: AppTheme.bodyMedium(
                color: valueColor ?? AppTheme.onSurface)),
        Text(label,
            style: AppTheme.labelMedium(
                color: AppTheme.onSurfaceVariant)),
      ],
    );
  }
}
