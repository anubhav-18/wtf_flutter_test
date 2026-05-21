import 'package:flutter_test/flutter_test.dart';
import 'package:wtf_shared/wtf_shared.dart';

void main() {
  group('SessionLog duration calculation', () {
    test('positive duration calculates correctly', () {
      final start = DateTime(2025, 6, 1, 10, 0, 0);
      final end = DateTime(2025, 6, 1, 10, 35, 20);
      final expectedSec = end.difference(start).inSeconds; // 2120

      final log = SessionLog(
        id: 'log-001',
        memberId: 'member-dk',
        trainerId: 'trainer-aarav',
        startedAt: start,
        endedAt: end,
        durationSec: expectedSec,
      );

      expect(log.durationSec, equals(2120));
    });

    test('zero-duration when start equals end', () {
      final t = DateTime(2025, 6, 1, 10, 0);
      final log = SessionLog(
        id: 'log-002',
        memberId: 'member-dk',
        trainerId: 'trainer-aarav',
        startedAt: t,
        endedAt: t,
        durationSec: 0,
      );
      expect(log.durationSec, equals(0));
    });

    test('rating clamp — null rating produces no stars', () {
      final log = SessionLog(
        id: 'log-003',
        memberId: 'member-dk',
        trainerId: 'trainer-aarav',
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        durationSec: 60,
      );
      expect(log.rating, isNull);
    });

    test('rating of 5 is allowed', () {
      final log = SessionLog(
        id: 'log-004',
        memberId: 'member-dk',
        trainerId: 'trainer-aarav',
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        durationSec: 300,
        rating: 5,
      );
      expect(log.rating, equals(5));
    });

    test('SessionLog JSON round-trip preserves all fields', () {
      final original = SessionLog(
        id: 'log-005',
        memberId: 'member-dk',
        trainerId: 'trainer-aarav',
        startedAt: DateTime(2025, 7, 4, 9, 0),
        endedAt: DateTime(2025, 7, 4, 9, 45),
        durationSec: 2700,
        rating: 4,
        trainerNotes: 'Good form today.',
        memberNotes: 'Felt strong!',
      );

      final json = original.toJson();
      final restored = SessionLog.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.durationSec, equals(original.durationSec));
      expect(restored.rating, equals(original.rating));
      expect(restored.trainerNotes, equals(original.trainerNotes));
      expect(restored.memberNotes, equals(original.memberNotes));
    });
  });
}
