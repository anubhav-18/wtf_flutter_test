import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerSplashScreen extends ConsumerStatefulWidget {
  const TrainerSplashScreen({super.key});

  @override
  ConsumerState<TrainerSplashScreen> createState() =>
      _TrainerSplashScreenState();
}

class _TrainerSplashScreenState extends ConsumerState<TrainerSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 800), () async {
      if (!mounted) {
        return;
      }
      final loggedIn = await ref.read(authServiceProvider).isTrainerLoggedIn();
      if (!mounted) {
        return;
      }
      AppNavigation.replaceNamed(
        context,
        loggedIn ? AppRoutes.trainerDashboard : AppRoutes.trainerLogin,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Trainer App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
