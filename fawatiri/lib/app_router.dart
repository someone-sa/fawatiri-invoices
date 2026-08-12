import 'dart:async';
import 'package:fawatiri/screens/invoices_screen.dart';
import 'package:fawatiri/screens/product_library_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fawatiri/screens/invoice_builder_screen.dart';
import 'package:fawatiri/screens/login_screen.dart';
import 'package:fawatiri/screens/main_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fawatiri/screens/history_screen.dart';
import 'package:fawatiri/screens/invoice_detail_screen.dart';
import 'package:fawatiri/screens/invoice_edit_screen.dart';
import 'package:fawatiri/screens/settings_screen.dart';
import 'package:flutter/material.dart';

// ← RouterNotifier يستمع لتغيرات Auth
class RouterNotifier extends ChangeNotifier {
  RouterNotifier() {
    _subscription = FirebaseAuth.instance
        .authStateChanges()
        .listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }
  
  late final StreamSubscription<dynamic> _subscription;
  
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final user    = FirebaseAuth.instance.currentUser;
    final onLogin = state.matchedLocation == '/login';
    if (user == null && !onLogin) return '/login';
    if (user != null && onLogin)  return '/home';
    return null;
  }
}

// ← Provider ثابت للـ Router
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier();

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/login',            builder: (_, __)  => const LoginScreen()),
      GoRoute(path: '/home',             builder: (_, __)  => const MainShell()),    // ← تغيّر: MainShell بدل HomeScreen
      GoRoute(path: '/invoice/new',      builder: (_, __)  => const InvoiceBuilderScreen()),
      GoRoute(path: '/invoice/:id',      builder: (_, s)   => InvoiceDetailScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/invoice/:id/edit', builder: (_, s)   => InvoiceEditScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/history',          builder: (_, __)  => const HistoryScreen()),
      GoRoute(path: '/products',         builder: (_, __)  => const ProductLibraryScreen()),
      GoRoute(path: '/settings',         builder: (_, __)  => const SettingsScreen()),
      GoRoute(path: '/invoices', builder: (_, __) => const InvoicesScreen()),
    ],
  );
});