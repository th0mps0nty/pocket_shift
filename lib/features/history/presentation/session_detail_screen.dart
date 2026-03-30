import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../../game/application/session_controller.dart';
import '../../game/data/session_repository.dart';
import '../../game/domain/daily_session.dart';
import '../../game/domain/trigger_tag.dart';
import '../../insights/application/insights_controller.dart';
import '../application/history_controller.dart';

class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Session detail')),
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: sessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: SectionCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Session detail needs a reload.', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(sessionDetailProvider(sessionId)),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (session) {
            if (session == null) {
              return Center(
                child: SectionCard(
                  child: Text('We could not find that session.', style: Theme.of(context).textTheme.titleLarge),
                ),
              );
            }

            return ListView(
              children: [
                Text(
                  PocketShiftDateUtils.formatSessionDate(session.date),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  session.hasCheckIn
                      ? 'A closer look at the shifts you noticed that day.'
                      : 'A quiet day still counts. This view will grow as you tag moves and reflect.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DetailChip(label: 'Started', value: '${session.startingCoins}'),
                    _DetailChip(label: 'Moved', value: '${session.movedCoins}'),
                    _DetailChip(label: 'Remaining', value: '${session.remainingCoins}'),
                  ],
                ),
                const SizedBox(height: 14),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Move timeline', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      if (session.moves.isEmpty)
                        Text(
                          'No moves were recorded for this day.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        ...session.moves.map(
                          (move) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(top: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        PocketShiftDateUtils.formatCreatedAt(move.timestamp),
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        move.triggerTag?.label ?? 'Untagged shift',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      if (move.note != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          move.note!,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Reflection', style: Theme.of(context).textTheme.titleLarge),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _openReflectionEditor(context, ref, session),
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(session.hasReflection ? 'Edit reflection' : 'Add reflection'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!session.hasReflection)
                        Text(
                          'No reflection was saved for this day yet.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else ...[
                        _ReflectionLine(label: 'What showed up', value: session.reflection?.whatShowedUp),
                        _ReflectionLine(label: 'What helped', value: session.reflection?.whatHelped),
                        _ReflectionLine(label: 'For tomorrow', value: session.reflection?.forTomorrow),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _openReflectionEditor(BuildContext context, WidgetRef ref, DailySession session) async {
    final result = await showModalBottomSheet<_ReflectionDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReflectionEditorSheet(
        initialWhatShowedUp: session.reflection?.whatShowedUp,
        initialWhatHelped: session.reflection?.whatHelped,
        initialForTomorrow: session.reflection?.forTomorrow,
      ),
    );

    if (result == null) {
      return;
    }

    final repository = ref.read(sessionRepositoryProvider);
    final clock = ref.read(clockProvider);
    final updated = session.saveReflection(
      now: clock(),
      whatShowedUp: result.whatShowedUp,
      whatHelped: result.whatHelped,
      forTomorrow: result.forTomorrow,
    );
    final currentSession = await repository.loadCurrentSession();
    if (currentSession?.id == session.id) {
      await repository.saveCurrentSession(updated);
      ref.invalidate(sessionControllerProvider);
    } else {
      await repository.updateHistorySession(updated);
    }

    ref.invalidate(historyTimelineProvider);
    ref.invalidate(sessionDetailProvider(sessionId));
    ref.invalidate(weeklyInsightsProvider);
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: context.ps.chipSurface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ReflectionLine extends StatelessWidget {
  const _ReflectionLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(value ?? 'Not filled in.', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ReflectionDraft {
  const _ReflectionDraft({
    this.whatShowedUp,
    this.whatHelped,
    this.forTomorrow,
  });

  final String? whatShowedUp;
  final String? whatHelped;
  final String? forTomorrow;
}

class _ReflectionEditorSheet extends StatefulWidget {
  const _ReflectionEditorSheet({
    this.initialWhatShowedUp,
    this.initialWhatHelped,
    this.initialForTomorrow,
  });

  final String? initialWhatShowedUp;
  final String? initialWhatHelped;
  final String? initialForTomorrow;

  @override
  State<_ReflectionEditorSheet> createState() => _ReflectionEditorSheetState();
}

class _ReflectionEditorSheetState extends State<_ReflectionEditorSheet> {
  late final TextEditingController _whatShowedUpController = TextEditingController(
    text: widget.initialWhatShowedUp,
  );
  late final TextEditingController _whatHelpedController = TextEditingController(
    text: widget.initialWhatHelped,
  );
  late final TextEditingController _forTomorrowController = TextEditingController(
    text: widget.initialForTomorrow,
  );

  @override
  void dispose() {
    _whatShowedUpController.dispose();
    _whatHelpedController.dispose();
    _forTomorrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 12, 12, bottom + 12),
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit reflection', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'You can revise your reflection anytime from session detail.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _whatShowedUpController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'What showed up most today?'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _whatHelpedController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'What helped you reset?'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _forTomorrowController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'What do you want tomorrow to feel like?'),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          _ReflectionDraft(
                            whatShowedUp: _whatShowedUpController.text,
                            whatHelped: _whatHelpedController.text,
                            forTomorrow: _forTomorrowController.text,
                          ),
                        );
                      },
                      child: const Text('Save reflection'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
