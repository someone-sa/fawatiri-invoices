import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/pin_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull;
    final pinEnabledAsync = ref.watch(pinEnabledProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'الإعدادات',
          style: AppTheme.headlineSmall(color: AppTheme.onSurface),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (role == UserRole.receiver) ...[
            // ── قسم الأمان ──
            _SettingsSection(
              title: 'الأمان',
              children: [
                // ── PIN Management (إجباري دائماً) ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.lock_outline, color: AppTheme.primary),
                          Text('رمز PIN',
                              style: AppTheme.headlineSmall(color: AppTheme.onSurface)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('رمز PIN إجباري لاعتماد الفواتير',
                          style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      // زر تعيين PIN أو تغيير PIN
                      pinEnabledAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (isEnabled) {
                          if (!isEnabled) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.tertiaryContainer,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _showSetPinDialog(context, ref),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('تعيين رمز PIN',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            );
                          } else {
                            return SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: BorderSide(
                                      color: AppTheme.primary.withValues(alpha: 0.5)),
                                ),
                                onPressed: () => _showChangePinDialog(context, ref),
                                icon: const Icon(Icons.edit, size: 20),
                                label: const Text('تغيير رمز PIN'),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      // معلومة
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
                          'رمز PIN مطلوب لكل اعتماد فاتورة عند وجود المستلم',
                          style: AppTheme.labelSmall(color: AppTheme.primary),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // ── قسم الحساب ──
          _SettingsSection(
            title: 'الحساب',
            children: [
              _ActionTile(
                icon: Icons.logout_rounded,
                iconColor: AppTheme.error,
                title: 'تسجيل الخروج',
                titleColor: AppTheme.error,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetPinDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => const _SetPinDialog(),
    );
  }

  void _showChangePinDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => const _ChangePinDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
          'تسجيل الخروج',
          style: AppTheme.headlineSmall(color: AppTheme.onSurface),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
            },
            child: Text(
              'تسجيل الخروج',
              style: AppTheme.labelMedium(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── بطاقة قسم الإعدادات ──
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: Text(
            title,
            style: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

// ── عنصر إجراء ──
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      // ← محاذاة النص لليمين
      title: Text(
        title,
        style: AppTheme.bodyMedium(color: titleColor ?? AppTheme.onSurface),
        textAlign: TextAlign.right, // ← إضافة هذا
      ),
      leading: Icon(
        Icons.arrow_back_ios,
        size: 14,
        color: AppTheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

// ── Dialog تعيين PIN جديد ──
class _SetPinDialog extends ConsumerStatefulWidget {
  const _SetPinDialog();

  @override
  ConsumerState<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends ConsumerState<_SetPinDialog> {
  final pinCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? error;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    pinCtrl.addListener(_onTextChanged);
    confirmCtrl.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      title: Text(
        'تعيين رمز PIN',
        style: AppTheme.headlineSmall(color: AppTheme.onSurface),
        textAlign: TextAlign.right,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinField(
            controller: pinCtrl,
            label: 'PIN الجديد',
          ),
          const SizedBox(height: 12),
          _PinField(
            controller: confirmCtrl,
            label: 'تأكيد PIN الجديد',
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: AppTheme.bodyMedium(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
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
          onPressed: (isSaving || pinCtrl.text.length != 4 || confirmCtrl.text.length != 4)
              ? null
              : () async {
                  setState(() {
                    error = null;
                    isSaving = true;
                  });

                  try {
                    if (pinCtrl.text != confirmCtrl.text) {
                      setState(() {
                        error = 'PIN الجديد غير متطابق';
                        isSaving = false;
                      });
                      return;
                    }

                    await ref.read(pinActionsProvider).setPin(pinCtrl.text);

                    if (!mounted) return;

                    ref.invalidate(pinEnabledProvider);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppTheme.primaryContainer,
                        content: Text(
                          'تم تعيين رمز PIN',
                          style: AppTheme.bodyMedium(color: AppTheme.onPrimaryContainer),
                        ),
                      ),
                    );
                  } catch (e) {
                    setState(() {
                      error = 'خطأ: $e';
                      isSaving = false;
                    });
                  }
                },
          child: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'حفظ',
                  style: AppTheme.labelMedium(color: AppTheme.onPrimaryContainer),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pinCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }
}

// ── Dialog تغيير PIN ──
class _ChangePinDialog extends ConsumerStatefulWidget {
  const _ChangePinDialog();

  @override
  ConsumerState<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends ConsumerState<_ChangePinDialog> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      title: Text(
        'تغيير PIN',
        style: AppTheme.headlineSmall(color: AppTheme.onSurface),
        textAlign: TextAlign.right,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinField(
            controller: currentCtrl,
            label: 'PIN الحالي',
          ),
          const SizedBox(height: 12),
          _PinField(
            controller: newCtrl,
            label: 'PIN الجديد',
          ),
          const SizedBox(height: 12),
          _PinField(
            controller: confirmCtrl,
            label: 'تأكيد PIN الجديد',
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: AppTheme.bodyMedium(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
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
          onPressed: () async {
            final ok = await ref.read(pinActionsProvider).verify(currentCtrl.text);
            if (!mounted) return;
            if (!ok) {
              setState(() => error = 'PIN الحالي غير صحيح');
              return;
            }
            
            if (newCtrl.text != confirmCtrl.text) {
              setState(() => error = 'PIN الجديد غير متطابق');
              return;
            }
            
            if (newCtrl.text.length != 4) {
              setState(() => error = 'PIN يجب أن يكون 4 أرقام');
              return;
            }

            await ref.read(pinActionsProvider).setPin(newCtrl.text);
            if (!mounted) return;

            ref.invalidate(pinEnabledProvider);
            
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.primaryContainer,
                  content: Text(
                    '✅ تم تغيير PIN',
                    style: AppTheme.bodyMedium(color: AppTheme.onPrimaryContainer),
                  ),
                ),
              );
            }
          },
          child: Text(
            'حفظ',
            style: AppTheme.labelMedium(color: AppTheme.onPrimaryContainer),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }
}

// ── حقل PIN ──
class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PinField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      textAlign: TextAlign.center,
      style: AppTheme.headlineMedium(color: AppTheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.labelMedium(color: AppTheme.onSurfaceVariant),
        counterStyle: AppTheme.labelSmall(color: AppTheme.onSurfaceVariant),
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