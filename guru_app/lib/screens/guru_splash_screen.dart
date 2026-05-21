import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class GuruSplashScreen extends ConsumerStatefulWidget {
  const GuruSplashScreen({super.key});

  @override
  ConsumerState<GuruSplashScreen> createState() => _GuruSplashScreenState();
}

class _GuruSplashScreenState extends ConsumerState<GuruSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) {
        return;
      }
      final onboarded = await ref.read(authServiceProvider).isGuruOnboarded();
      if (!mounted) {
        return;
      }
      AppNavigation.replaceNamed(
        context,
        onboarded ? AppRoutes.guruDashboard : AppRoutes.guruOnboarding,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Guru App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
