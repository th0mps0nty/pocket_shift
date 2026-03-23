import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/adaptive_option_picker.dart';
import '../../../core/widgets/adaptive_time_picker.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';
import '../domain/coin_style.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: SectionCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Settings need a reload.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(settingsControllerProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (settings) => ListView(
            children: [
              Text('Settings', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Make Pocket Shift feel like your pocket ritual.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _DailyCoinsCard(settings: settings),
              const SizedBox(height: 14),
              _CoinStyleCard(settings: settings),
              const SizedBox(height: 14),
              _PreferencesCard(settings: settings),
              const SizedBox(height: 14),
              _ReminderCard(settings: settings),
              const SizedBox(height: 14),
              _AboutCard(
                onTap: () => context.push('/settings/about'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyCoinsCard extends ConsumerWidget {
  const _DailyCoinsCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily coins', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Choose how many coins start in the left pocket each morning. New counts apply with your next fresh pocket.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('${settings.dailyCoinCount}', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  min: AppConstants.minDailyCoinCount.toDouble(),
                  max: AppConstants.maxDailyCoinCount.toDouble(),
                  divisions: AppConstants.maxDailyCoinCount - AppConstants.minDailyCoinCount,
                  label: '${settings.dailyCoinCount}',
                  value: settings.dailyCoinCount.toDouble(),
                  onChanged: (value) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateDailyCoinCount(value.round());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinStyleCard extends ConsumerWidget {
  const _CoinStyleCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coin style', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Start with classic pennies or swap in a different pocket-change feel.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Selected coin'),
            subtitle: Text(
              '${settings.coinStyle.label} • ${settings.coinStyle.description}',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final picked = await showAdaptiveOptionPicker<CoinStyle>(
                context: context,
                title: 'Choose a coin style',
                selectedValue: settings.coinStyle,
                options: CoinStyle.values
                    .map(
                      (style) => AdaptiveOption<CoinStyle>(
                        value: style,
                        title: style.label,
                        subtitle: style.description,
                      ),
                    )
                    .toList(),
              );
              if (picked == null) {
                return;
              }
              await ref.read(settingsControllerProvider.notifier).setCoinStyle(picked);
            },
          ),
        ],
      ),
    );
  }
}

class _PreferencesCard extends ConsumerWidget {
  const _PreferencesCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Haptics'),
            subtitle: const Text('A small tap when you move or undo a coin.'),
            value: settings.hapticsEnabled,
            onChanged: (value) {
              ref.read(settingsControllerProvider.notifier).setHapticsEnabled(value);
            },
          ),
          SwitchListTile.adaptive(
            title: const Text('Sound'),
            subtitle: const Text('A light coin landing sound when it drops into the pocket.'),
            value: settings.soundEnabled,
            onChanged: (value) {
              ref.read(settingsControllerProvider.notifier).setSoundEnabled(value);
            },
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLabel = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute),
    );

    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Daily reminder'),
            subtitle: const Text('A gentle nudge to check your pockets.'),
            value: settings.remindersEnabled,
            onChanged: (value) async {
              await ref
                  .read(settingsControllerProvider.notifier)
                  .setRemindersEnabled(value);
              if (context.mounted && value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Reminder saved. If notifications are unavailable here, Pocket Shift will quietly skip them.',
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            enabled: settings.remindersEnabled,
            title: const Text('Reminder time'),
            subtitle: Text(timeLabel),
            trailing: const Icon(Icons.schedule_rounded),
            onTap: settings.remindersEnabled
                ? () async {
                    final picked = await showAdaptivePocketTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.reminderHour,
                        minute: settings.reminderMinute,
                      ),
                    );
                    if (picked == null) {
                      return;
                    }
                    await ref.read(settingsControllerProvider.notifier).updateReminderTime(
                          hour: picked.hour,
                          minute: picked.minute,
                        );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About & credits', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Read the story behind Pocket Shift, the inspiration from counseling, and the full credit note.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Open About Pocket Shift'),
            subtitle: const Text('Story, purpose, and credits'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTap,
          ),
          const Divider(height: 18),
          Text(
            'Pocket Shift stores your sessions and settings on this device only. No account, no cloud sync, no hidden scorekeeping.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
