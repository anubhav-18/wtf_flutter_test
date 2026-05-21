import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();
  runApp(const ProviderScope(child: GuruApp()));
}

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guru App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.guruPrimary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const GuruSplashScreen(),
    );
  }
}

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
                    _OnboardingSlide(
                      title: 'Chat with your trainer',
                      body:
                          'Stay connected with Aarav using quick replies, read receipts, and clear updates.',
                    ),
                    _OnboardingSlide(
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

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.title, required this.body});

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

class GuruDashboardScreen extends ConsumerWidget {
  const GuruDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member • DK')),
      floatingActionButton: const DevPanelButton(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _DashboardCard(
            title: 'Chat with Trainer',
            icon: Icons.chat_bubble_outline,
          ),
          _DashboardCard(
            title: 'Schedule Call',
            icon: Icons.calendar_month_outlined,
          ),
          _DashboardCard(
            title: 'My Requests',
            icon: Icons.pending_actions_outlined,
          ),
          _DashboardCard(
            title: 'Upcoming Calls',
            icon: Icons.video_call_outlined,
          ),
          _DashboardCard(title: 'My Sessions', icon: Icons.history_outlined),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.guruPrimary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
