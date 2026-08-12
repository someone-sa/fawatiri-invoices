import 'package:fawatiri/app_router.dart';
import 'package:fawatiri/firebase_options.dart';
import 'package:fawatiri/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('ar', null); // ← أضف هذا السطر
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: FawatiriApp()));
}

class FawatiriApp extends ConsumerWidget {
  const FawatiriApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final role   = ref.watch(authProvider).valueOrNull;

    final seedColor = role == UserRole.owner
        ? const Color(0xFF1E4A8C)
        : const Color(0xFF1A7A4A);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'فواتيري',
      locale: const Locale('ar'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        fontFamily: GoogleFonts.cairo().fontFamily,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}