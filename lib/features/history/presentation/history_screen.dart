import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../../../app/theme.dart';
import '../../game/domain/daily_session.dart';
import '../../game/domain/trigger_tag.dart';
import '../application/history_controller.dart';
import '../domain/history_timeline_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyTimelineProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: SectionCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('History needs a quick reload.', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(historyTimelineProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) => ListView(
            children: [
              Text('History', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'A gentle local record of the days you checked in with yourself.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              if (items.length == 1 && !items.first.session.hasCheckIn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: SectionCard(
                    child: Text(
                      'Your first tagged moves and reflections will start turning this list into something you can actually learn from.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _HistoryCard(
                    item: item,
                    onTap: () => context.push('/history/${item.session.id}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.onTap});

  final HistoryTimelineItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final session = item.session;
    final theme = Theme.of(context);

    return SectionCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.isCurrent ? 'Today' : PocketShiftDateUtils.formatSessionDate(session.date),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: item.isCurrent ? context.ps.badgeCurrent : context.ps.badgeClosed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      item.isCurrent ? 'In progress' : 'Closed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatChip(label: 'Started', value: '${session.startingCoins}'),
                _StatChip(label: 'Moved', value: '${session.movedCoins}'),
                _StatChip(label: 'Remaining', value: '${session.remainingCoins}'),
              ],
            ),
            const SizedBox(height: 14),
            Text(_messageForSession(session), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            if (session.topTrigger != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Top trigger: ${session.topTrigger!.label}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            if (session.hasReflection && session.reflection?.whatShowedUp != null)
              Text(
                session.reflection!.whatShowedUp!,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  String _messageForSession(DailySession session) {
    if (session.movedCoins == 0) {
      return 'Quiet day. The record still counts.';
    }
    if (session.remainingCoins == 0) {
      return 'A full pocket shift day. Fresh pockets tomorrow.';
    }
    return 'You noticed ${session.movedCoins} moment${session.movedCoins == 1 ? '' : 's'}. That counts.';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.ps.chipSurface, borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
