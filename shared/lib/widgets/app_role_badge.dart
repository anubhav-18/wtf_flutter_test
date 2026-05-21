import 'package:flutter/material.dart';

import '../models/user.dart';

class AppRoleBadge extends StatelessWidget {
  const AppRoleBadge({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${user.role.label} • ${user.name}',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
