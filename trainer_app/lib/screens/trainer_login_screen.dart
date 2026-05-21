import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'trainer_dashboard_screen.dart';

class TrainerLoginScreen extends ConsumerWidget {
  const TrainerLoginScreen({super.key});

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).loginTrainer();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TrainerDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.trainerPrimary,
                child: Text('A', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 24),
              Text(
                'Aarav',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Lead Trainer', textAlign: TextAlign.center),
              const Spacer(),
              FilledButton(
                onPressed: () => _login(context, ref),
                child: const Text('Login as Aarav'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
