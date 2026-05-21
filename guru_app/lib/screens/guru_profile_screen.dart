import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class GuruProfileScreen extends ConsumerStatefulWidget {
  const GuruProfileScreen({super.key});

  @override
  ConsumerState<GuruProfileScreen> createState() => _GuruProfileScreenState();
}

class _GuruProfileScreenState extends ConsumerState<GuruProfileScreen> {
  final _nameController = TextEditingController(text: 'DK');
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await ref.read(authServiceProvider).completeGuruOnboarding();
    if (!mounted) return;
    AppNavigation.replaceNamed(context, AppRoutes.guruDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Avatar preview
              Center(
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : 'D',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'e.g. DK',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              // Assigned trainer card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: cs.primary,
                      child: const Text('A',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Aarav', style: Theme.of(context).textTheme.titleSmall),
                        Text('Lead Trainer • Auto assigned',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _loading || _nameController.text.trim().isEmpty ? null : _complete,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Text('Start Training'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
