import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/adaptive_option_picker.dart';
import '../../../core/widgets/adaptive_time_picker.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../../../app/theme.dart';
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
                  Text('Settings need a reload.', style: Theme.of(context).textTheme.titleLarge),
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
                'Make Pocket Shift feel calm, familiar, and easy to return to.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _AppearanceCard(settings: settings),
              const SizedBox(height: 14),
              _DailyCoinsCard(settings: settings),
              const SizedBox(height: 14),
              _CoinStyleCard(settings: settings),
              const SizedBox(height: 14),
              _PreferencesCard(settings: settings),
              const SizedBox(height: 14),
              _ReminderCard(settings: settings),
              const SizedBox(height: 14),
              _ReminderCopyCard(settings: settings, onTap: () => context.push('/settings/reminder-copy')),
              const SizedBox(height: 14),
              _DataToolsCard(onTap: () => context.push('/settings/data-tools')),
              const SizedBox(height: 14),
              const _SupportCard(),
              const SizedBox(height: 14),
              _AboutCard(onTap: () => context.push('/settings/about')),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Support & privacy', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Keep support and privacy details easy to reach right from the app.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openExternal(context, AppConstants.supportUrl),
                icon: const Icon(Icons.support_agent_outlined),
                label: const Text('Open support'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openExternal(context, AppConstants.privacyUrl),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('Open privacy policy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openExternal(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (launched || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $url right now.')),
    );
  }
}

class _AppearanceCard extends ConsumerWidget {
  const _AppearanceCard({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Choose how Pocket Shift looks.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(value: AppThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(value: AppThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selected) {
                ref.read(settingsControllerProvider.notifier).setThemeMode(selected.first);
              },
            ),
          ),
        ],
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
            'Choose how many coins begin in the left pocket each morning. New counts apply with your next fresh pocket.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: context.ps.subtleSurface, borderRadius: BorderRadius.circular(20)),
                child: Text('${settings.dailyCoinCount}', style: Theme.of(context).textTheme.headlineMedium),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  min: AppConstants.minDailyCoinCount.toDouble(),
                  max: AppConstants.maxDailyCoinCount.toDouble(),
                  divisions: AppConstants.maxDailyCoinCount - AppConstants.minDailyCoinCount,
                  label: '${settings.dailyCoinCount}',
                  value: settings.dailyCoinCount.toDouble(),
                  onChanged: (value) {
                    ref.read(settingsControllerProvider.notifier).updateDailyCoinCount(value.round());
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
          Text('Use the pocket change that feels right for you.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Selected coin'),
            subtitle: Text('${settings.coinStyle.label} • ${settings.coinStyle.description}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final picked = await showAdaptiveOptionPicker<CoinStyle>(
                context: context,
                title: 'Choose a coin style',
                selectedValue: settings.coinStyle,
                options: CoinStyle.values
                    .map(
                      (style) =>
                          AdaptiveOption<CoinStyle>(value: style, title: style.label, subtitle: style.description),
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
            subtitle: const Text('A light pocket-change landing when the coin drops.'),
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
    final timeLabel = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute));

    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Daily reminder'),
            subtitle: const Text('A gentle nudge to check your pockets.'),
            value: settings.remindersEnabled,
            onChanged: (value) async {
              await ref.read(settingsControllerProvider.notifier).setRemindersEnabled(value);
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
                      initialTime: TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute),
                    );
                    if (picked == null) {
                      return;
                    }
                    await ref
                        .read(settingsControllerProvider.notifier)
                        .updateReminderTime(hour: picked.hour, minute: picked.minute);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _ReminderCopyCard extends StatelessWidget {
  const _ReminderCopyCard({required this.settings, required this.onTap});

  final AppSettings settings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reminder copy', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Customize the words that show up in your daily nudge.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.ps.subtleSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.ps.subtleBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(settings.reminderTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(settings.reminderBody, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit reminder copy'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataToolsCard extends StatelessWidget {
  const _DataToolsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data tools', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Export your local data or reset the app when you want a clean start.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Open data tools'),
            ),
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
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.info_outline_rounded),
              label: const Text('Open About'),
            ),
          ),
        ],
      ),
    );
  }
}
