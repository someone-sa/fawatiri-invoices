import 'dart:ui';
import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;
  String? error;

Future<void> _signIn() async {
  if (!mounted) return;

  setState(() {
    loading = true;
    error = null;
  });

  try {
    await ref.read(authActionsProvider).signIn(
      emailCtrl.text.trim(),
      passwordCtrl.text.trim(),
    );
  } on FirebaseAuthException catch (e) {
    if (mounted) {
      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
          message = '❌ البريد الإلكتروني غير موجود';
          break;
        case 'wrong-password':
          message = '❌ كلمة المرور غير صحيحة';
          break;
        case 'user-disabled':
          message = '❌ الحساب معطل';
          break;
        case 'too-many-requests':
          message = '⏳ محاولات كثيرة، حاول لاحقاً';
          break;
        case 'invalid-credential':
          message = '❌ البريد أو كلمة المرور غير صحيحة';
          break;
        default:
          message = '❌ خطأ في تسجيل الدخول';
      }
      setState(() => error = message);
    }
  } finally {
    if (mounted) setState(() => loading = false);
  }
}

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.outlineVariant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ── Logo ──
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerHigh
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'فواتيري',
                      style: AppTheme.displayLarge(color: AppTheme.primary),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'قم بتسجيل الدخول للوصول إلى لوحة التحكم الخاصة بك',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMedium(color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),

                    // ── Email ──
                    _buildInputField(
                      controller: emailCtrl,
                      label: 'البريد الإلكتروني',
                      hint: 'name@company.com',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),

                    // ── Password ──
                    _buildInputField(
                      controller: passwordCtrl,
                      label: 'كلمة المرور',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      onSubmitted: (_) => _signIn(),
                      suffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(Icons.lock_outline, color: AppTheme.onSurfaceVariant, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Error ──
                    if (error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorContainer.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error!,
                                style: AppTheme.labelMedium(color: AppTheme.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: loading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryContainer,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor:
                              AppTheme.primaryContainer.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('تسجيل الدخول',
                                      style: AppTheme.labelMedium(
                                          color: Colors.white)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.login, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: AppTheme.labelMedium(color: AppTheme.onSurface)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          onSubmitted: onSubmitted,
          style: AppTheme.bodyMedium(color: AppTheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium(
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            suffixIcon: suffix ??
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
                ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48, minHeight: 48,
            ),
            filled: true,
            fillColor: AppTheme.surface.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.primaryContainer,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}