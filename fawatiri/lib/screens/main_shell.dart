import 'package:fawatiri/core/utils/theme.dart';
import 'package:fawatiri/providers/auth_provider.dart';
import 'package:fawatiri/screens/home_screen.dart';
import 'package:fawatiri/screens/invoices_screen.dart';
import 'package:fawatiri/screens/payment_screen.dart';
import 'package:fawatiri/screens/product_library_screen.dart';
import 'package:fawatiri/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ← مفتاح عام للوصول لـ MainShell من أي مكان
final GlobalKey<_MainShellState> mainShellKey = GlobalKey<_MainShellState>();

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  // ← دالة عامة للتبديل بين التبويبات من أي مكان
  void navigateToTab(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  // ── شاشات Owner (4) ──
  late final List<Widget> _ownerScreens;
  // ── شاشات Receiver (3) ──
  late final List<Widget> _receiverScreens;

  @override
  void initState() {
    super.initState();
    _ownerScreens = [
      HomeScreen(onShowAll: () => navigateToTab(1)),  // index 0
      const InvoicesScreen(),                          // index 1
      const ProductLibraryScreen(),                    // index 2
      const PaymentScreen(),                           // index 3
    ];
    _receiverScreens = [
      HomeScreen(onShowAll: () => navigateToTab(1)),  // index 0
      const InvoicesScreen(),                          // index 1
      const PaymentScreen(),                           // index 2
    ];
  }

  void _onTabTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).valueOrNull;
    final isOwner = role == UserRole.owner;
    final screens = isOwner ? _ownerScreens : _receiverScreens;

    // ── حماية: لو تغيّر الدور وindex تجاوز عدد الشاشات ──
    final safeIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: FawatiriBottomNavBar(
        currentIndex: safeIndex,
        onTap: _onTabTap,
      ),
    );
  }

  // ── AppBar علوي ثابت ──
   // ── AppBar علوي ثابت ──
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80), // ← زودنا من 64 إلى 80
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // ← إضافة padding عمودي للتوسيط
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12), // ← جديد
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── أيقونة الإشعارات (يمين في RTL) ──
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  // ── عنوان التطبيق ──
                  Text(
                    'فواتيري',
                    style: AppTheme.headlineMedium(color: AppTheme.primary),
                  ),
                  // ── أيقونة الإعدادات ──
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }}