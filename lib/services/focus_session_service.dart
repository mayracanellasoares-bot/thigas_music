import 'package:flutter/foundation.dart';
import 'package:thigas_music/models/focus_session.dart';
import 'package:thigas_music/utilities/focus_session_controller.dart';

/// Flutter adapter. Timing and persistence are tested without native plugins.
class FocusSessionService extends ChangeNotifier {
  FocusSessionService({
    required Object? Function() read,
    required Future<void> Function(Map<String, Object?>) write,
    required Future<void> Function() onComplete,
    required VoidCallback onStart,
    required FocusErrorHandler onError,
  }) {
    _controller = FocusSessionController(
      read: read,
      write: write,
      onComplete: onComplete,
      onStart: onStart,
      onError: onError,
      onChanged: notifyListeners,
    );
  }

  late final FocusSessionController _controller;
  FocusSession get session => _controller.session;
  Duration get remaining => _controller.remaining;
  double get progress => _controller.progress;
  void restore() => _controller.restore();
  void start(Duration duration, {bool pauseMusicAtEnd = true}) =>
      _controller.start(duration, pauseMusicAtEnd: pauseMusicAtEnd);
  void pauseTimer() => _controller.pauseTimer();
  void resumeTimer() => _controller.resumeTimer();
  void cancel() => _controller.cancel();
  Future<void> flush() => _controller.flush();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
