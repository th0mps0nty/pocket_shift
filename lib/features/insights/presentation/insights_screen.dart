import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../../game/domain/trigger_tag.dart';
import '../application/insights_controller.dart';
import '../domain/weekly_insights.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(weeklyInsightsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        child: insightsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: SectionCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Insights need a quick reload.', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(weeklyInsightsProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (insights) => ListView(
            children: [
              Text('Insights', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'A gentle weekly view of how often you checked in, what showed up, and where awareness is growing.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _InsightSummaryRow(insights: insights),
              const SizedBox(height: 14),
              _WeeklyChartCard(insights: insights),
              const SizedBox(height: 14),
              _TriggerBreakdownCard(insights: insights),
              const SizedBox(height: 14),
              _InsightContextCard(insights: insights),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightSummaryRow extends StatelessWidget {
  const _InsightSummaryRow({required this.insights});

  final WeeklyInsights insights;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryChip(label: 'Moves this week', value: '${insights.totalMoves}'),
        _SummaryChip(label: 'Days checked in', value: '${insights.daysCheckedIn}/7'),
        _SummaryChip(label: 'Current streak', value: '${insights.currentStreak}'),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.ps.chipSurface,
        borderRadius: BorderRadius.circular(20),
      ),
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

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({required this.insights});

  final WeeklyInsights insights;

  @override
  Widget build(BuildContext context) {
    final maxMoves = insights.days.fold<int>(0, (maxValue, day) {
      return day.movedCoins > maxValue ? day.movedCoins : maxValue;
    });

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This week', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            insights.hasMeaningfulData
                ? 'Your weekly pockets show how often you caught the shift.'
                : 'Make a few shifts or add a reflection this week and your pattern will start to appear here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 176,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: insights.days.map((day) {
                final fraction = maxMoves == 0 ? 0.0 : day.movedCoins / maxMoves;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${day.movedCoins}', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: fraction == 0 ? 0.04 : fraction.clamp(0.08, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: day.hasCheckIn
                                      ? Theme.of(context).colorScheme.primary
                                      : context.ps.subtleSurface,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(day.label, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriggerBreakdownCard extends StatelessWidget {
  const _TriggerBreakdownCard({required this.insights});

  final WeeklyInsights insights;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top triggers', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (insights.topTriggers.isEmpty)
            Text(
              'Tag a few shifts and your most common triggers will show up here.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...insights.topTriggers.map(
              (trigger) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(trigger.tag.label, style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    Text('${trigger.count}', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightContextCard extends StatelessWidget {
  const _InsightContextCard({required this.insights});

  final WeeklyInsights insights;

  @override
  Widget build(BuildContext context) {
    final average = insights.averageMoves.toStringAsFixed(1);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A supportive read', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            insights.hasMeaningfulData
                ? 'You averaged $average noticed shifts per day this week. The point is not perfection. The point is getting quicker at noticing.'
                : 'Pocket Shift works best when it helps you notice patterns, not judge yourself. Even a few check-ins start building that picture.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
