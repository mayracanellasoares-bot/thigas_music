import 'package:flutter_test/flutter_test.dart';

import '../tools/focus_checks.dart';

void main() {
  test(
    'Focus sessions handle time, restart and persistence correctly',
    runFocusChecks,
  );
}
