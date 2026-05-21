import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.video_chat_outlined,
          size: 88,
          color: AppColors.guruPrimary,
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(body, textAlign: TextAlign.center),
      ],
    );
  }
}
