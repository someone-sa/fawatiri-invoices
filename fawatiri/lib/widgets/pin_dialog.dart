import 'package:firebase_auth/firebase_auth.dart';
import 'package:fawatiri/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fawatiri/providers/pin_provider.dart';
import 'package:fawatiri/core/utils/number_parser.dart';

Future<bool> showPinDialog(BuildContext context, WidgetRef ref) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _PinDialog(ref: ref),
  ) ?? false;
}

class _PinDialog extends StatefulWidget {
  final WidgetRef ref;
  const _PinDialog({required this.ref});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _ctrl = TextEditingController();
  bool _error = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── أيقونة ──
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── عنوان ──
              Text(
                'أدخل رمز PIN',
                style: AppTheme.headlineSmall(color: AppTheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'المستلم يدخل رمز PIN للاعتماد الفوري',
                style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ── حقل PIN ──
              TextField(
                controller: _ctrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                autofocus: true,
                textAlign: TextAlign.center,
                style: AppTheme.headlineMedium(color: AppTheme.onSurface),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: AppTheme.headlineMedium(
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  errorText: _error ? 'PIN غير صحيح' : null,
                  errorStyle: AppTheme.labelSmall(color: AppTheme.error),
                  filled: true,
                  fillColor: AppTheme.surface.withValues(alpha: 0.5),
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
                    borderSide: const BorderSide(
                      color: AppTheme.primaryContainer,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── نسيت الرمز ──
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    _showForgotPinDialog(context, widget.ref);
                  },
                  icon: const Icon(Icons.help_outline,
                      color: AppTheme.error, size: 16),
                  label: Text('نسيت الرمز؟',
                      style: AppTheme.labelSmall(color: AppTheme.error)),
                ),
              ),
              const SizedBox(height: 16),

              // ── أزرار ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await widget.ref.read(pinActionsProvider)
                            .verify(normalizeNumbers(_ctrl.text.trim()));

                        if (ok && mounted) {
                          Navigator.of(context).pop(true);
                        } else if (mounted) {
                          setState(() => _error = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainer,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'تأكيد',
                        style: AppTheme.labelMedium(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dialog نسيت الرمز: إعادة تعيين بـ Email + Password ──
void _showForgotPinDialog(BuildContext context, WidgetRef ref) {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool isAuthenticating = false;
  String? authError;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('نسيت رمز PIN',
            style: AppTheme.headlineSmall(color: AppTheme.error)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'تحقق من هويتك باستخدام بيانات الدخول',
              style: AppTheme.labelSmall(
                  color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),

            // البريد الإلكتروني
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.right,
              style: AppTheme.bodyMedium(color: AppTheme.onSurface),
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                labelStyle: AppTheme.labelMedium(
                    color: AppTheme.onSurfaceVariant),
                filled: true,
                fillColor: AppTheme.surfaceContainerHigh
                    .withValues(alpha: 0.3),
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
            const SizedBox(height: 12),

            // كلمة المرور
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              textAlign: TextAlign.right,
              style: AppTheme.bodyMedium(color: AppTheme.onSurface),
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                labelStyle: AppTheme.labelMedium(
                    color: AppTheme.onSurfaceVariant),
                filled: true,
                fillColor: AppTheme.surfaceContainerHigh
                    .withValues(alpha: 0.3),
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

            // رسالة الخطأ
            if (authError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  authError!,
                  style: AppTheme.labelSmall(color: AppTheme.error),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: isAuthenticating ? null : () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryContainer,
              foregroundColor: Colors.white,
            ),
            onPressed: (isAuthenticating ||
                    emailCtrl.text.isEmpty ||
                    passwordCtrl.text.isEmpty)
                ? null
                : () async {
                    setState(() {
                      isAuthenticating = true;
                      authError = null;
                    });

                    try {
                      await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: emailCtrl.text.trim(),
                        password: passwordCtrl.text.trim(),
                      );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      _showResetPinDialog(
                        context,
                        ref,
                        email: emailCtrl.text.trim(),
                      );
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        isAuthenticating = false;
                        authError = _getErrorMessage(e.code);
                      });
                    } catch (e) {
                      setState(() {
                        isAuthenticating = false;
                        authError = 'خطأ: $e';
                      });
                    }
                  },
            child: isAuthenticating
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('التحقق'),
          ),
        ],
      ),
    ),
  );
}

// ── Dialog إعادة تعيين PIN (بعد التحقق من الهوية) ──
void _showResetPinDialog(
  BuildContext context,
  WidgetRef ref, {
  required String email,
}) {
  final newPinCtrl = TextEditingController();
  bool isSaving = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('إعادة تعيين رمز PIN',
            style: AppTheme.headlineSmall(color: AppTheme.tertiaryContainer)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'تم التحقق من هويتك بنجاح',
              style: AppTheme.labelSmall(
                  color: AppTheme.statusApproved),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            Text(
              'عيّني رمز PIN جديد (4 أرقام)',
              style: AppTheme.labelSmall(
                  color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPinCtrl,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              obscureText: true,
              autofocus: true,
              style: AppTheme.headlineMedium(color: AppTheme.primary),
              decoration: InputDecoration(
                hintText: '••••',
                filled: true,
                fillColor: AppTheme.surfaceContainerHigh
                    .withValues(alpha: 0.3),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'سيتم حذف الرمز القديم وحفظ الرمز الجديد',
                style: AppTheme.labelSmall(color: AppTheme.primary),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isSaving ? null : () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.tertiaryContainer,
              foregroundColor: Colors.white,
            ),
            onPressed: (isSaving || newPinCtrl.text.length != 4)
                ? null
                : () async {
                    setState(() => isSaving = true);

                    try {
                      final pinActions =
                          ref.read(pinActionsProvider);
                      await pinActions
                          .setPin(newPinCtrl.text);

                      if (!ctx.mounted) return;

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                              'تم إعادة تعيين رمز PIN بنجاح'),
                          backgroundColor: Color(0xFF34D399),
                        ),
                      );
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx)
                            .showSnackBar(
                          SnackBar(
                              content: Text('فشل: $e')),
                        );
                      }
                    }
                  },
            child: isSaving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white))
                : const Text('إعادة تعيين'),
          ),
        ],
      ),
    ),
  );
}

// ── Helper: ترجمة رسائل الخطأ ──
String _getErrorMessage(String code) {
  return switch (code) {
    'user-not-found' => 'البريد الإلكتروني غير موجود',
    'wrong-password' => 'كلمة المرور غير صحيحة',
    'invalid-email' => 'البريد الإلكتروني غير صحيح',
    'user-disabled' => 'الحساب معطّل',
    'too-many-requests' =>
      'محاولات كثيرة — حاولي لاحقاً',
    _ => 'خطأ في التحقق: $code',
  };
}
