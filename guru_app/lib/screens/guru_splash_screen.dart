import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'guru_dashboard_screen.dart';
import 'guru_onboarding_screen.dart';

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => onboarded
              ? const GuruDashboardScreen()
              : const GuruOnboardingScreen(),
        ),
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
