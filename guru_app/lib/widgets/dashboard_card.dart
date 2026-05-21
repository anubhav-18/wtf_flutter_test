import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.title, required this.icon});

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
