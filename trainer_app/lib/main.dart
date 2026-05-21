import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();
  runApp(const ProviderScope(child: TrainerApp()));
}

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.trainerPrimary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const TrainerSplashScreen(),
    );
  }
}

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => loggedIn
              ? const TrainerDashboardScreen()
              : const TrainerLoginScreen(),
        ),
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

class TrainerDashboardScreen extends StatelessWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer • Aarav')),
      floatingActionButton: const DevPanelButton(),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _DashboardTile(title: 'Members', icon: Icons.people_outline),
          _DashboardTile(title: 'Chats', icon: Icons.chat_bubble_outline),
          _DashboardTile(title: 'Requests', icon: Icons.pending_actions),
          _DashboardTile(title: 'Sessions', icon: Icons.history_outlined),
          _DashboardTile(
            title: 'Upcoming Calls',
            icon: Icons.video_call_outlined,
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.trainerPrimary, size: 32),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
