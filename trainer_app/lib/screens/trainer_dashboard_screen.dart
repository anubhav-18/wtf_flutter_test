import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class TrainerDashboardScreen extends ConsumerWidget {
  const TrainerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final now = DateTime.now();

    final pendingCount =
        requests.where((r) => r.status == CallRequestStatus.pending).length;

    final upcomingCount = requests
        .where((r) =>
            r.status == CallRequestStatus.approved &&
            r.trainerId == AppConstants.trainerId &&
            r.scheduledFor.isAfter(now.subtract(const Duration(minutes: 30))))
        .length;

    final unreadCount = messages
        .where((m) =>
            m.receiverId == AppConstants.trainerId &&
            m.status != MessageStatus.read)
        .length;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              title: const Text('Coach Aarav 🏋️',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24, top: 40),
                    child: Icon(
                      Icons.sports_gymnastics_rounded,
                      size: 90,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              const DevPanelButton(),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stat chips row
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    if (pendingCount > 0)
                      _StatChip(
                        icon: Icons.pending_actions_rounded,
                        label: '$pendingCount pending',
                        color: AppColors.warning,
                      ),
                    _StatChip(
                      icon: Icons.video_call_rounded,
                      label: '$upcomingCount upcoming',
                      color: AppColors.success,
                    ),
                    if (unreadCount > 0)
                      _StatChip(
                        icon: Icons.mark_unread_chat_alt_rounded,
                        label: '$unreadCount unread',
                        color: const Color(0xFF42A5F5),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Dashboard',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant, letterSpacing: 0.5)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _ActionCard(
                      icon: Icons.people_rounded,
                      label: 'Members',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                      onTap: () => AppNavigation.pushNamed(
                          context, AppRoutes.trainerMembers),
                    ),
                    _ActionCard(
                      icon: Icons.chat_rounded,
                      label: 'Chats',
                      badge: unreadCount > 0 ? '$unreadCount' : null,
                      gradient: const LinearGradient(
                          colors: [Color(0xFF00695C), Color(0xFF26A69A)]),
                      onTap: () => AppNavigation.pushNamed(
                          context, AppRoutes.trainerChats),
                    ),
                    _ActionCard(
                      icon: Icons.pending_actions_rounded,
                      label: 'Requests',
                      badge: pendingCount > 0 ? '$pendingCount' : null,
                      gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFFF8A65)]),
                      onTap: () => AppNavigation.pushNamed(
                          context, AppRoutes.trainerRequests),
                    ),
                    _ActionCard(
                      icon: Icons.videocam_rounded,
                      label: 'Upcoming',
                      badge: upcomingCount > 0 ? '$upcomingCount' : null,
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
                      onTap: () => AppNavigation.pushNamed(
                          context, AppRoutes.trainerUpcomingCalls),
                    ),
                    _ActionCard(
                      icon: Icons.history_rounded,
                      label: 'Sessions',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF37474F), Color(0xFF78909C)]),
                      onTap: () => AppNavigation.pushNamed(
                          context, AppRoutes.trainerSessions),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Member summary
                _MemberCard(cs: cs),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(gradient: gradient),
          child: Stack(
            children: [
              Positioned(
                bottom: -8,
                right: -4,
                child: Icon(icon,
                    size: 56, color: Colors.white.withValues(alpha: 0.15)),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white, size: 26),
                    const Spacer(),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ],
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.guruPrimary,
            child: const Text('DK',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DK',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Your Member',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.circle, size: 10, color: AppColors.success),
        ],
      ),
    );
  }
}
