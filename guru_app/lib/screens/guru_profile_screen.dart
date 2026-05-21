import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

import 'guru_dashboard_screen.dart';

class GuruProfileScreen extends ConsumerWidget {
  const GuruProfileScreen({super.key});

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).completeGuruOnboarding();
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const GuruDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'DK',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: CircleAvatar(child: Text('A')),
              title: Text('Aarav'),
              subtitle: Text('Lead Trainer • Auto assigned'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => _complete(context, ref),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
