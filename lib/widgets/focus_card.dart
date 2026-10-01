import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thigas_music/main.dart';
import 'package:thigas_music/models/focus_session.dart';

class FocusCard extends StatelessWidget {
  const FocusCard({super.key});
  @override
  Widget build(BuildContext context) {
    final focus = audioHandler.focusSession;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListenableBuilder(
        listenable: focus,
        builder: (context, _) {
          final session = focus.session;
          final remaining = (focus.remaining.inMilliseconds / 1000).ceil();
          final label = session.active
              ? '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')} '
                    '${session.phase == FocusPhase.paused ? '· pausado' : 'restantes'}'
              : '25 ou 50 minutos com sua música';
          return Material(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.push('/settings/focus'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.self_improvement_rounded,
                      size: 32,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo foco',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: colors.onPrimaryContainer),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: TextStyle(color: colors.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
