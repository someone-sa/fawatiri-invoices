import 'package:fawatiri/core/utils/number_parser.dart';
import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/models/product.dart';
import 'package:fawatiri/providers/auth_provider.dart';
import 'package:fawatiri/providers/invoice_provider.dart';
import 'package:fawatiri/providers/product_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductLibraryScreen extends ConsumerWidget {
  const ProductLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(authProvider);

    return roleAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Text('خطأ: $e', style: AppTheme.bodyMedium(color: AppTheme.error)),
        ),
      ),
      data: (role) {
        if (role != UserRole.owner) {
          return Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: Text(
                '⛔ غير مصرح لك بالوصول لهذه الصفحة',
                style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
              ),
            ),
          );
        }
        return const _ProductLibraryContent();
      },
    );
  }
}

class _ProductLibraryContent extends ConsumerWidget {
  const _ProductLibraryContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'مكتبة المنتجات',
          style: AppTheme.headlineSmall(color: AppTheme.onSurface),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, ref),
        backgroundColor: AppTheme.primaryContainer,
        foregroundColor: AppTheme.onPrimaryContainer,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'إضافة منتج',
          style: AppTheme.labelMedium(color: AppTheme.onPrimaryContainer),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'خطأ: $e',
            style: AppTheme.bodyMedium(color: AppTheme.error),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return _EmptyState(onAdd: () => _showAddEditDialog(context, ref));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (_, i) {
              final p = products[i];
              return _ProductCard(
                product: p,
                onEdit: () => _showAddEditDialog(context, ref, product: p),
                onDelete: () => _confirmDelete(context, ref, p),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, WidgetRef ref, {Product? product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(
      text: product != null ? product.defaultPrice.toString() : '',
    );
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          title: Text(
            isEdit ? 'تعديل منتج' : 'منتج جديد',
            style: AppTheme.headlineSmall(color: AppTheme.onSurface),
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTextField(
                controller: nameCtrl,
                label: 'اسم المنتج',
                icon: Icons.label_outlined,
              ),
              const SizedBox(height: 16),
              _DialogTextField(
                controller: priceCtrl,
                label: 'السعر',
                icon: Icons.attach_money_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  final normalized = normalizeNumbers(value);
                  if (normalized != value) {
                    priceCtrl.value = TextEditingValue(
                      text: normalized,
                      selection: TextSelection.collapsed(offset: normalized.length),
                    );
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: Text(
                'إلغاء',
                style: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: AppTheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      setState(() => isSaving = true);

                      final price = double.tryParse(priceCtrl.text) ?? 0;
                      final result = isEdit
                          ? await ref.read(productActionsProvider)
                              .edit(product.id, nameCtrl.text, price)
                          : await ref.read(productActionsProvider)
                              .add(nameCtrl.text, price);

                      if (!ctx.mounted) return;

                      if (!result.success) {
                        setState(() => isSaving = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.errorContainer,
                            content: Text(
                              '⚠️ ${result.message}',
                              style: AppTheme.bodyMedium(color: AppTheme.onErrorContainer),
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppTheme.primaryContainer,
                          content: Text(
                            '✅ ${result.message}',
                            style: AppTheme.bodyMedium(color: AppTheme.onPrimaryContainer),
                          ),
                        ),
                      );
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEdit ? 'حفظ' : 'إضافة',
                      style: AppTheme.labelMedium(color: AppTheme.onPrimaryContainer),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        title: Text(
          'حذف المنتج؟',
          style: AppTheme.headlineSmall(color: AppTheme.onSurface),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل تريد حذف "${product.name}"؟',
          style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              final result = await ref.read(productActionsProvider).delete(product.id);
              if (!ctx.mounted) return;

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: result.success
                      ? AppTheme.primaryContainer
                      : AppTheme.errorContainer,
                  content: Text(
                    result.success ? '🗑️ ${result.message}' : '❌ ${result.message}',
                    style: AppTheme.bodyMedium(
                      color: result.success
                          ? AppTheme.onPrimaryContainer
                          : AppTheme.onErrorContainer,
                    ),
                  ),
                ),
              );
            },
            child: Text(
              'حذف',
              style: AppTheme.labelMedium(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── حالة الفارغة ──
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
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
                Icons.inventory_2_outlined,
                size: 40,
                color: AppTheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات بعد',
              style: AppTheme.headlineSmall(color: AppTheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة منتجاتك الأولى',
              style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                'إضافة منتج',
                style: AppTheme.labelMedium(color: AppTheme.onPrimaryContainer),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: AppTheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── بطاقة المنتج ──
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ← اليسار: الأزرار
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  icon: Icons.edit_outlined,
                  color: AppTheme.primary,
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.delete_outline,
                  color: AppTheme.error,
                  onTap: onDelete,
                ),
              ],
            ),
            const SizedBox(width: 12),
            // الوسط: التفاصيل (محاذاة لليمين)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.bodyMedium(color: AppTheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  // ← ر.ي على يسار السعر
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ر.ي',
                        style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.defaultPrice.toStringAsFixed(2),
                        style: AppTheme.labelMedium(color: AppTheme.primary),
                      ),
                    ],
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
                Icons.inventory_2_outlined,
                color: AppTheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── زر إجراء دائري ──
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ── حقل إدخال الـ Dialog ──
class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const _DialogTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      textAlign: TextAlign.right,
      style: AppTheme.bodyMedium(color: AppTheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
        filled: true,
        fillColor: AppTheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}