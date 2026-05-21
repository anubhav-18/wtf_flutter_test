import 'package:flutter/material.dart';

import '../services/dev_log_service.dart';

class DevPanelButton extends StatelessWidget {
  const DevPanelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'dev_panel',
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            final logs = DevLogService.latest20;
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'DevPanel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text('Env: HMS_ACCESS_KEY=****, HMS_SECRET=****'),
                  const SizedBox(height: 12),
                  const Text('Build: local debug'),
                  const Divider(),
                  for (final log in logs)
                    ListTile(
                      dense: true,
                      title: Text('${log.tag} ${log.message}'),
                      subtitle: Text(log.createdAt.toIso8601String()),
                    ),
                ],
              ),
            );
          },
        );
      },
      child: const Icon(Icons.more_vert),
    );
  }
}
