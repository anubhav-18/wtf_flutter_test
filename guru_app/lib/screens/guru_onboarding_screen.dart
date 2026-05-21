import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/onboarding_slide.dart';
import 'guru_profile_screen.dart';

class GuruOnboardingScreen extends ConsumerStatefulWidget {
  const GuruOnboardingScreen({super.key});

  @override
  ConsumerState<GuruOnboardingScreen> createState() =>
      _GuruOnboardingScreenState();
}

class _GuruOnboardingScreenState extends ConsumerState<GuruOnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_page < 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      return;
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const GuruProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _page = value),
                  children: const [
                    OnboardingSlide(
                      title: 'Chat with your trainer',
                      body:
                          'Stay connected with Aarav using quick replies, read receipts, and clear updates.',
                    ),
                    OnboardingSlide(
                      title: 'Schedule 100ms calls',
                      body:
                          'Request a call, track approval, and join from Upcoming Calls.',
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _continue,
                child: Text(_page < 1 ? 'Next' : 'Create DK Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
