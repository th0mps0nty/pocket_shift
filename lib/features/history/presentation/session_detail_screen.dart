import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../../game/domain/trigger_tag.dart';
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
                      Text('Reflection', style: Theme.of(context).textTheme.titleLarge),
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
