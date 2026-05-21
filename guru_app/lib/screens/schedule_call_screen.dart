import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtf_shared/wtf_shared.dart';

class ScheduleCallScreen extends ConsumerStatefulWidget {
  const ScheduleCallScreen({super.key});

  @override
  ConsumerState<ScheduleCallScreen> createState() => _ScheduleCallScreenState();
}

class _ScheduleCallScreenState extends ConsumerState<ScheduleCallScreen> {
  final TextEditingController _noteController = TextEditingController();
  DateTime _scheduledFor = DateTime.now().add(const Duration(hours: 1));
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledFor,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _scheduledFor = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _scheduledFor.hour,
        _scheduledFor.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledFor),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _scheduledFor = DateTime(
        _scheduledFor.year,
        _scheduledFor.month,
        _scheduledFor.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
    });
    final error = await ref
        .read(callServiceProvider)
        .requestCall(
          scheduledFor: _scheduledFor,
          note: _noteController.text.trim(),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _submitting = false;
    });
    if (error != null) {
      AppFeedback.showSnackBar(context, error);
      return;
    }
    AppFeedback.showSnackBar(context, 'Call request sent to Aarav.');
    AppNavigation.replaceNamed(context, AppRoutes.guruMyRequests);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = 140 - _noteController.text.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Call')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Request a 1:1 video call with Aarav.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined),
                  title: const Text('Date'),
                  subtitle: Text(DateFormatters.date(_scheduledFor)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickDate,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Time'),
                  subtitle: Text(DateFormatters.time(_scheduledFor)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLength: 140,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              helperText: '$remaining characters left',
              labelText: 'Note for trainer',
              hintText: 'Share what you want to discuss',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: const Text('Send request'),
          ),
        ],
      ),
    );
  }
}
