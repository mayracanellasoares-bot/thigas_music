enum FocusPhase { idle, running, paused, completed }

/// Wall-clock deadline: UI rebuilds and delayed timer callbacks do not lose time.
class FocusSession {
  const FocusSession({
    this.phase = FocusPhase.idle,
    this.duration = const Duration(minutes: 25),
    this.deadline,
    this.pausedRemaining = Duration.zero,
    this.pauseMusicAtEnd = true,
  });

  final FocusPhase phase;
  final Duration duration;
  final DateTime? deadline;
  final Duration pausedRemaining;
  final bool pauseMusicAtEnd;

  bool get active => phase == FocusPhase.running || phase == FocusPhase.paused;

  Duration remainingAt(DateTime now) {
    final value = switch (phase) {
      FocusPhase.running => deadline?.difference(now) ?? Duration.zero,
      FocusPhase.paused => pausedRemaining,
      FocusPhase.idle || FocusPhase.completed => Duration.zero,
    };
    if (value.isNegative) return Duration.zero;
    return value > duration ? duration : value;
  }

  double progressAt(DateTime now) => active
      ? (1 - remainingAt(now).inMilliseconds / duration.inMilliseconds).clamp(
          0.0,
          1.0,
        )
      : (phase == FocusPhase.completed ? 1 : 0);

  Map<String, Object?> toMap() => {
    'phase': phase.name,
    'durationMs': duration.inMilliseconds,
    'deadlineMs': deadline?.millisecondsSinceEpoch,
    'remainingMs': pausedRemaining.inMilliseconds,
    'pauseMusicAtEnd': pauseMusicAtEnd,
  };

  static FocusSession fromMap(Object? raw) {
    if (raw is! Map) return const FocusSession();
    final durationMs = raw['durationMs'];
    final remainingMs = raw['remainingMs'];
    final deadlineMs = raw['deadlineMs'];
    final pauseMusic = raw['pauseMusicAtEnd'];
    final phases = FocusPhase.values.where((p) => p.name == raw['phase']);
    if (phases.isEmpty ||
        durationMs is! int ||
        durationMs < 60000 ||
        durationMs > 10800000 ||
        remainingMs is! int ||
        remainingMs < 0 ||
        remainingMs > durationMs ||
        pauseMusic is! bool) {
      return const FocusSession();
    }
    final phase = phases.first;
    if (phase == FocusPhase.running &&
        (deadlineMs is! int ||
            deadlineMs < 0 ||
            deadlineMs > 8640000000000000)) {
      return const FocusSession();
    }
    return FocusSession(
      phase: phase,
      duration: Duration(milliseconds: durationMs),
      deadline: phase == FocusPhase.running
          ? DateTime.fromMillisecondsSinceEpoch(deadlineMs as int)
          : null,
      pausedRemaining: Duration(milliseconds: remainingMs),
      pauseMusicAtEnd: pauseMusic,
    );
  }
}
