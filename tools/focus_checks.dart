import 'dart:async';

import '../lib/models/focus_session.dart';
import '../lib/utilities/focus_session_controller.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

Future<void> runFocusChecks() async {
  var now = DateTime.utc(2026, 10, 1, 12);
  Object? stored;
  var completions = 0;
  var starts = 0;
  final errors = <Object>[];
  final controller = FocusSessionController(
    read: () => stored,
    write: (snapshot) async {
      stored = Map.of(snapshot);
    },
    onComplete: () async {
      completions++;
    },
    onStart: () {
      starts++;
    },
    onChanged: () {},
    onError: (e, _) => errors.add(e),
    clock: () => now,
    scheduleTicks: false,
  );
  controller.restore();
  check(
    controller.session.phase == FocusPhase.idle,
    'Fresh installation is idle',
  );
  controller.start(const Duration(minutes: 25));
  now = now.add(const Duration(minutes: 7));
  controller.tick();
  check(
    controller.remaining == const Duration(minutes: 18),
    'Elapsed time uses deadline',
  );
  controller.pauseTimer();
  now = now.add(const Duration(hours: 1));
  check(
    controller.remaining == const Duration(minutes: 18),
    'Pause freezes remaining time',
  );
  await controller.flush();
  final pausedSnapshot = stored;
  controller.resumeTimer();
  now = now.add(const Duration(minutes: 19));
  controller.tick();
  controller.tick();
  check(
    controller.session.phase == FocusPhase.completed,
    'Delayed tick completes',
  );
  check(completions == 1, 'Completion happens exactly once');
  check(
    controller.remaining == Duration.zero,
    'Countdown never becomes negative',
  );
  controller.start(const Duration(minutes: 1), pauseMusicAtEnd: false);
  now = now.add(const Duration(minutes: 2));
  controller.tick();
  check(completions == 1, 'Music continues when pause-at-end is disabled');
  controller.start(const Duration(minutes: 50));
  controller.cancel();
  now = now.add(const Duration(hours: 2));
  controller.tick();
  check(completions == 1, 'Cancelled session cannot pause music');
  await controller.flush();
  check((stored as Map)['phase'] == 'idle', 'Latest cancellation persisted');
  stored = pausedSnapshot;
  controller.restore();
  check(
    controller.session.phase == FocusPhase.paused &&
        controller.remaining == const Duration(minutes: 18),
    'Paused session survives restart',
  );
  stored = FocusSession(
    phase: FocusPhase.running,
    deadline: now.subtract(const Duration(minutes: 1)),
  ).toMap();
  controller.restore();
  check(
    controller.session.phase == FocusPhase.completed && completions == 1,
    'Expired restoration does not repeat an audio action',
  );
  await controller.flush();
  stored = {'phase': 'running', 'durationMs': 'corrupt'};
  controller.restore();
  check(
    controller.session.phase == FocusPhase.idle,
    'Malformed persisted data resets safely',
  );
  for (final minutes in [0, 181]) {
    var rejected = false;
    try {
      controller.start(Duration(minutes: minutes));
    } on ArgumentError {
      rejected = true;
    }
    check(rejected, 'Out-of-range duration must be rejected');
  }
  check(starts == 4, 'Start and resume cancel competing sleep timers');
  check(errors.isEmpty, 'No hidden persistence errors');
  controller.dispose();

  final firstWrite = Completer<void>();
  final writes = <String>[];
  var count = 0;
  final serialized = FocusSessionController(
    read: () => null,
    write: (snapshot) async {
      if (count++ == 0) await firstWrite.future;
      writes.add(snapshot['phase'] as String);
    },
    onComplete: () async {},
    onStart: () {},
    onChanged: () {},
    onError: (e, _) => errors.add(e),
    clock: () => now,
    scheduleTicks: false,
  );
  serialized.start(const Duration(minutes: 25));
  serialized.cancel();
  await Future<void>.delayed(Duration.zero);
  check(writes.isEmpty, 'Later writes wait for the in-flight write');
  firstWrite.complete();
  await serialized.flush();
  check(
    writes.join(',') == 'running,idle',
    'Persistence preserves action order',
  );
  serialized.dispose();

  var reportedErrors = 0;
  final failing = FocusSessionController(
    read: () => null,
    write: (_) async => throw StateError('Disk full'),
    onComplete: () async => throw StateError('Audio unavailable'),
    onStart: () {},
    onChanged: () {},
    onError: (_, _) {
      reportedErrors++;
    },
    clock: () => now,
    scheduleTicks: false,
  );
  failing.start(const Duration(minutes: 1));
  await failing.flush();
  now = now.add(const Duration(minutes: 2));
  failing.tick();
  await failing.flush();
  check(
    reportedErrors == 3 && failing.session.phase == FocusPhase.completed,
    'Audio/storage failures are reported without breaking the state machine',
  );
  failing.dispose();

  // Exercise the actual periodic scheduler, not only manually driven ticks.
  final scheduledCompletion = Completer<void>();
  final scheduled = FocusSessionController(
    read: () => null,
    write: (_) async {},
    onComplete: () async {
      scheduledCompletion.complete();
    },
    onStart: () {},
    onChanged: () {},
    onError: (e, _) => errors.add(e),
    clock: () => now,
  );
  scheduled.start(const Duration(minutes: 1));
  now = now.add(const Duration(minutes: 2));
  await scheduledCompletion.future.timeout(const Duration(seconds: 3));
  check(
    scheduled.session.phase == FocusPhase.completed,
    'Periodic scheduler completes without a screen or manual tick',
  );
  scheduled.dispose();
}

Future<void> main() async {
  await runFocusChecks();
  print(
    'PASS: countdown, pause/resume, completion, cancellation, restoration, '
    'validation, serialized writes and error handling.',
  );
}
