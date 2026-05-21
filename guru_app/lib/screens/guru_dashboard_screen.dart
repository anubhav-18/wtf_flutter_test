import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class GuruDashboardScreen extends ConsumerWidget {
  const GuruDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(callRequestsStreamProvider).value ?? [];
    final messages = ref.watch(messagesStreamProvider).value ?? [];
    final now = DateTime.now();

    final upcomingCount = requests
        .where((r) =>
            r.status == CallRequestStatus.approved &&
            r.memberId == AppConstants.memberId &&
            r.scheduledFor.isAfter(now.subtract(const Duration(minutes: 30))))
        .length;

    final unreadCount = messages
        .where((m) =>
            m.receiverId == AppConstants.memberId &&
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
              title: const Text('Hey, DK 👋',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.guruPrimary.withValues(alpha: 0.9),
                      const Color(0xFF0D3B8E),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24, top: 40),
                    child: Icon(
                      Icons.fitness_center_rounded,
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
                // Quick stats row
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.video_call_rounded,
                      label: '$upcomingCount upcoming',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    if (unreadCount > 0)
                      _StatChip(
                        icon: Icons.mark_unread_chat_alt_rounded,
                        label: '$unreadCount unread',
                        color: AppColors.warning,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Quick actions',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5)),
                const SizedBox(height: 12),
                // Action cards grid
                _ActionGrid(children: [
                  _ActionCard(
                    icon: Icons.chat_rounded,
                    label: 'Chat',
                    badge: unreadCount > 0 ? '$unreadCount' : null,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1769E0), Color(0xFF2196F3)],
                    ),
                    onTap: () =>
                        AppNavigation.pushNamed(context, AppRoutes.guruChats),
                  ),
                  _ActionCard(
                    icon: Icons.calendar_month_rounded,
                    label: 'Schedule',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                    ),
                    onTap: () => AppNavigation.pushNamed(
                        context, AppRoutes.guruScheduleCall),
                  ),
                  _ActionCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'My Requests',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFF8A65)],
                    ),
                    onTap: () => AppNavigation.pushNamed(
                        context, AppRoutes.guruMyRequests),
                  ),
                  _ActionCard(
                    icon: Icons.videocam_rounded,
                    label: 'Upcoming',
                    badge: upcomingCount > 0 ? '$upcomingCount' : null,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00695C), Color(0xFF26A69A)],
                    ),
                    onTap: () => AppNavigation.pushNamed(
                        context, AppRoutes.guruUpcomingCalls),
                  ),
                  _ActionCard(
                    icon: Icons.history_rounded,
                    label: 'Sessions',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF37474F), Color(0xFF78909C)],
                    ),
                    onTap: () => AppNavigation.pushNamed(
                        context, AppRoutes.guruSessions),
                  ),
                ]),
                const SizedBox(height: 24),
                // Trainer card
                _TrainerCard(cs: cs),
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

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: children,
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
              // Background icon watermark
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

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.cs});
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
            child: const Text('A',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aarav',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Your Trainer',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 1.5),
            ),
            child: const Icon(Icons.circle,
                size: 10, color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
