import 'package:flutter/material.dart';
import 'package:thigas_music/main.dart';
import 'package:thigas_music/models/focus_session.dart';
import 'package:thigas_music/widgets/mini_player_bottom_space.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});
  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  final _minutesController = TextEditingController(text: '25');
  bool _pauseMusic = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final session = audioHandler.focusSession.session;
    _minutesController.text = session.duration.inMinutes.toString();
    _pauseMusic = session.pauseMusicAtEnd;
  }

  @override
  void dispose() {
    _minutesController.dispose();
    super.dispose();
  }

  void _start() {
    final minutes = int.tryParse(_minutesController.text.trim());
    if (minutes == null || minutes < 1 || minutes > 180) {
      setState(() => _error = 'Digite de 1 a 180 minutos.');
      return;
    }
    setState(() => _error = null);
    FocusManager.instance.primaryFocus?.unfocus();
    audioHandler.focusSession.start(
      Duration(minutes: minutes),
      pauseMusicAtEnd: _pauseMusic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final focus = audioHandler.focusSession;
    return Scaffold(
      appBar: AppBar(title: const Text('Modo foco')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListenableBuilder(
                listenable: focus,
                builder: (context, _) {
                  final session = focus.session;
                  final seconds = (focus.remaining.inMilliseconds / 1000)
                      .ceil();
                  final time =
                      '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
                      '${(seconds % 60).toString().padLeft(2, '0')}';
                  final status = switch (session.phase) {
                    FocusPhase.idle => 'Escolha seu tempo de concentração',
                    FocusPhase.running => 'Sessão em andamento',
                    FocusPhase.paused => 'Temporizador pausado',
                    FocusPhase.completed => 'Sessão concluída',
                  };
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Um tempo para você.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Escolha uma música ou playlist na biblioteca '
                        'e inicie sua sessão. O temporizador não inicia música sozinho.',
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.self_improvement_rounded,
                              size: 36,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(status, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                session.active
                                    ? time
                                    : (session.phase == FocusPhase.completed
                                          ? 'Concluído'
                                          : '${_minutesController.text} min'),
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colors.primary,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(
                              value: focus.progress,
                              semanticsLabel: 'Progresso da sessão de foco',
                              semanticsValue:
                                  '${(focus.progress * 100).round()} por cento',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!session.active) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final minutes in [25, 50, 90])
                              ChoiceChip(
                                label: Text('$minutes min'),
                                selected: _minutesController.text == '$minutes',
                                onSelected: (_) => setState(() {
                                  _minutesController.text = '$minutes';
                                  _error = null;
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _minutesController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() => _error = null),
                          onSubmitted: (_) => _start(),
                          decoration: InputDecoration(
                            labelText: 'Duração em minutos',
                            helperText: 'De 1 a 180 minutos',
                            errorText: _error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Pausar música ao terminar'),
                          value: _pauseMusic,
                          onChanged: (value) =>
                              setState(() => _pauseMusic = value),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _start,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            session.phase == FocusPhase.completed
                                ? 'Iniciar outra sessão'
                                : 'Iniciar sessão',
                          ),
                        ),
                      ] else ...[
                        FilledButton.icon(
                          onPressed: session.phase == FocusPhase.running
                              ? focus.pauseTimer
                              : focus.resumeTimer,
                          icon: Icon(
                            session.phase == FocusPhase.running
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            session.phase == FocusPhase.running
                                ? 'Pausar temporizador'
                                : 'Retomar temporizador',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: focus.cancel,
                          child: const Text('Encerrar sessão'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Pausar o temporizador não pausa a música. '
                        'Modo foco e timer para dormir usam sessões separadas: '
                        'iniciar um cancela o outro.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const MiniPlayerBottomSpace(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
