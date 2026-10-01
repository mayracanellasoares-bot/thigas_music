import 'dart:async';

import '../models/focus_session.dart';

typedef FocusErrorHandler = void Function(Object error, StackTrace stack);

/// Owned by the audio handler, not by a page. Saves on transitions, not every tick.
class FocusSessionController {
  FocusSessionController({
    required Object? Function() read,
    required Future<void> Function(Map<String, Object?>) write,
    required Future<void> Function() onComplete,
    required void Function() onStart,
    required void Function() onChanged,
    required FocusErrorHandler onError,
    DateTime Function()? clock,
    bool scheduleTicks = true,
  }) : _read = read,
       _write = write,
       _onComplete = onComplete,
       _onStart = onStart,
       _onError = onError,
       _onChanged = onChanged,
       _clock = clock ?? DateTime.now,
       _scheduleTicks = scheduleTicks;

  final Object? Function() _read;
  final Future<void> Function(Map<String, Object?>) _write;
  final Future<void> Function() _onComplete;
  final void Function() _onStart;
  final void Function() _onChanged;
  final FocusErrorHandler _onError;
  final DateTime Function() _clock;
  final bool _scheduleTicks;
  Timer? _ticker;
  Future<void> _pendingWrites = Future.value();
  FocusSession _session = const FocusSession();

  FocusSession get session => _session;
  Duration get remaining => _session.remainingAt(_clock());
  double get progress => _session.progressAt(_clock());
  Future<void> flush() => _pendingWrites;

  void restore() {
    _ticker?.cancel();
    _ticker = null;
    try {
      _session = FocusSession.fromMap(_read());
      // Process death never restarts music or repeats a completion action.
      if (_session.phase == FocusPhase.running && remaining == Duration.zero) {
        _session = FocusSession(
          phase: FocusPhase.completed,
          duration: _session.duration,
          pauseMusicAtEnd: _session.pauseMusicAtEnd,
        );
        _persist();
      }
      _reschedule();
      _onChanged();
    } catch (error, stack) {
      _session = const FocusSession();
      _onError(error, stack);
      _onChanged();
    }
  }

  void start(Duration duration, {bool pauseMusicAtEnd = true}) {
    if (duration < const Duration(minutes: 1) ||
        duration > const Duration(minutes: 180)) {
      throw ArgumentError.value(duration, 'duration', 'Use 1 a 180 minutos.');
    }
    _onStart();
    _session = FocusSession(
      phase: FocusPhase.running,
      duration: duration,
      deadline: _clock().add(duration),
      pauseMusicAtEnd: pauseMusicAtEnd,
    );
    _changed();
  }

  void pauseTimer() {
    if (_session.phase != FocusPhase.running) return;
    final remainingTime = remaining;
    if (remainingTime == Duration.zero) {
      tick();
      return;
    }
    _session = FocusSession(
      phase: FocusPhase.paused,
      duration: _session.duration,
      pausedRemaining: remainingTime,
      pauseMusicAtEnd: _session.pauseMusicAtEnd,
    );
    _changed();
  }

  void resumeTimer() {
    if (_session.phase != FocusPhase.paused) return;
    _onStart();
    _session = FocusSession(
      phase: FocusPhase.running,
      duration: _session.duration,
      deadline: _clock().add(_session.pausedRemaining),
      pauseMusicAtEnd: _session.pauseMusicAtEnd,
    );
    _changed();
  }

  void cancel() {
    _session = FocusSession(
      duration: _session.duration,
      pauseMusicAtEnd: _session.pauseMusicAtEnd,
    );
    _changed();
  }

  void tick() {
    if (_session.phase != FocusPhase.running) return;
    if (remaining > Duration.zero) {
      _onChanged();
      return;
    }
    final shouldPause = _session.pauseMusicAtEnd;
    _session = FocusSession(
      phase: FocusPhase.completed,
      duration: _session.duration,
      pauseMusicAtEnd: shouldPause,
    );
    // Invoke audio action immediately, before any asynchronous persistence.
    if (shouldPause) unawaited(_completeSafely());
    _changed();
  }

  Future<void> _completeSafely() async {
    try {
      await _onComplete();
    } catch (error, stack) {
      _onError(error, stack);
    }
  }

  void _changed() {
    _reschedule();
    _persist();
    _onChanged();
  }

  void _reschedule() {
    _ticker?.cancel();
    _ticker = null;
    if (_scheduleTicks && _session.phase == FocusPhase.running) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    }
  }

  void _persist() {
    final snapshot = _session.toMap();
    // Serialize writes: a slow start write cannot overwrite a later cancellation.
    _pendingWrites = _pendingWrites.then((_) async {
      try {
        await _write(snapshot);
      } catch (error, stack) {
        _onError(error, stack);
      }
    });
  }

  void dispose() {
    _ticker?.cancel();
  }
}
