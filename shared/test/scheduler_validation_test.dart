import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  group('Scheduler conflict validation', () {
    DateTime nowPlus(int hours, [int minutes = 0]) =>
        DateTime.now().add(Duration(hours: hours, minutes: minutes));

    CallRequest makeRequest({
      required String id,
      required DateTime scheduledFor,
      CallRequestStatus status = CallRequestStatus.pending,
    }) {
      return CallRequest(
        id: id,
        memberId: 'member-dk',
        trainerId: 'trainer-aarav',
        scheduledFor: scheduledFor,
        requestedAt: DateTime.now(),
        status: status,
        note: '',
      );
    }

    bool hasConflict(
      List<CallRequest> existing,
      DateTime proposed,
      Duration window,
    ) {
      return existing.any((r) {
        if (r.status != CallRequestStatus.approved) return false;
        return (r.scheduledFor.difference(proposed).abs()) < window;
      });
    }

    test('no conflict when no existing approved requests', () {
      final existing = <CallRequest>[];
      final proposed = nowPlus(2);
      expect(hasConflict(existing, proposed, const Duration(hours: 1)), isFalse);
    });

    test('no conflict when approved request is far away (>1h)', () {
      final existing = [
        makeRequest(
          id: 'r1',
          scheduledFor: nowPlus(5),
          status: CallRequestStatus.approved,
        ),
      ];
      final proposed = nowPlus(2);
      expect(hasConflict(existing, proposed, const Duration(hours: 1)), isFalse);
    });

    test('detects conflict within 1-hour window', () {
      final base = nowPlus(3);
      final existing = [
        makeRequest(
          id: 'r1',
          scheduledFor: base,
          status: CallRequestStatus.approved,
        ),
      ];
      // Proposed is 30 minutes after existing — within window.
      final proposed = base.add(const Duration(minutes: 30));
      expect(hasConflict(existing, proposed, const Duration(hours: 1)), isTrue);
    });

    test('pending requests do NOT trigger conflict', () {
      final base = nowPlus(3);
      final existing = [
        makeRequest(
          id: 'r1',
          scheduledFor: base,
          status: CallRequestStatus.pending,
        ),
      ];
      final proposed = base.add(const Duration(minutes: 30));
      expect(hasConflict(existing, proposed, const Duration(hours: 1)), isFalse);
    });

    test('declined requests do NOT trigger conflict', () {
      final base = nowPlus(3);
      final existing = [
        makeRequest(
          id: 'r1',
          scheduledFor: base,
          status: CallRequestStatus.declined,
        ),
      ];
      final proposed = base.add(const Duration(minutes: 30));
      expect(hasConflict(existing, proposed, const Duration(hours: 1)), isFalse);
    });
  });

  group('CallRequest serialization', () {
    test('round-trips through toJson/fromJson', () {
      final original = CallRequest(
        id: 'req-001',
        memberId: 'member-dk',
        trainerId: 'trainer-aarav',
        scheduledFor: DateTime(2025, 6, 1, 14, 0),
        requestedAt: DateTime(2025, 5, 30, 9, 0),
        status: CallRequestStatus.approved,
        note: 'Focus on cardio',
      );

      final json = original.toJson();
      final restored = CallRequest.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.status, equals(original.status));
      expect(restored.note, equals(original.note));
    });
  });
}
