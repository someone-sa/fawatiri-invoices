import 'package:fawatiri/core/utils/theme.dart';
import 'package:flutter/material.dart';

/// تنسيق عدد المنتجات بالعربية
String _formatProducts(int count) {
  if (count == 1) return 'منتج واحد';
  if (count == 2) return 'منتجين';
  return '$count منتجات';
}

Future<bool?> askReceiverPresent(
  BuildContext context, {
  required int itemCount,
  required double total,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── أيقونة ──
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),

            // ── عنوان ──
            Text(
              'إرسال الفاتورة',
              style: AppTheme.headlineSmall(color: AppTheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // ── تفاصيل الفاتورة ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _formatProducts(itemCount),
                    style: AppTheme.headlineSmall(color: AppTheme.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ر.ي',
                        style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        total.toStringAsFixed(2),
                        style: AppTheme.displayLarge(color: AppTheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── سؤال ──
            Text(
              'هل المستلم حاضر الآن؟',
              style: AppTheme.bodyMedium(color: AppTheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // ── توضيح ──
            Text(
              'إذا حاضر تعتمد الفاتورة فوراً، إذا لا ترسل وتنتظر اعتمادها لاحقاً',
              style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ── زرين بجانب بعض: غير حاضر | حاضر ──
            Row(
              children: [
                // غير حاضر (يسار)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.onSurfaceVariant,
                      side: BorderSide(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'غير حاضر',
                      style: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // حاضر (يمين)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'حاضر',
                      style: AppTheme.labelMedium(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── زر إلغاء (كامل العرض، حواف حمراء) ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, null),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(
                    color: AppTheme.error.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: AppTheme.labelMedium(color: AppTheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> confirmSendAsPending(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_empty,
                color: AppTheme.secondary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'PIN غير صحيح',
              style: AppTheme.headlineSmall(color: AppTheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'تريدين إرسال الفاتورة كمعلّقة بدلاً من ذلك؟',
              style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'إرسال كمعلّقة',
                  style: AppTheme.labelMedium(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(
                    color: AppTheme.error.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: AppTheme.labelMedium(color: AppTheme.error),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ) ?? false;
}

Future<bool> confirmDeleteRow(BuildContext context, String productName) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.errorContainer.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppTheme.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'حذف المنتج؟',
              style: AppTheme.headlineSmall(color: AppTheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'هل تريدين حذف "$productName"؟',
              style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'حذف',
                  style: AppTheme.labelMedium(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.onSurfaceVariant,
                  side: BorderSide(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'إلغاء',
                  style: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ) ?? false;
}