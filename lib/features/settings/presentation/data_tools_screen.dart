import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/adaptive_secondary_scaffold.dart';
import '../../../core/widgets/section_card.dart';
import '../../game/application/session_controller.dart';
import '../../history/application/history_controller.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../application/settings_controller.dart';
import '../data/app_data_repository.dart';
import '../domain/app_export_bundle.dart';

final appExportBundleProvider = FutureProvider<AppExportBundle>(
  (ref) => ref.watch(appDataRepositoryProvider).buildExportBundle(),
);

class DataToolsScreen extends ConsumerStatefulWidget {
  const DataToolsScreen({super.key});

  @override
  ConsumerState<DataToolsScreen> createState() => _DataToolsScreenState();
}

class _DataToolsScreenState extends ConsumerState<DataToolsScreen> {
  bool _resetting = false;

  @override
  Widget build(BuildContext context) {
    final exportAsync = ref.watch(appExportBundleProvider);

    return AdaptiveSecondaryScaffold(
      title: 'Data tools',
      child: exportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: SectionCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Data tools need a reload.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(appExportBundleProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (bundle) => ListView(
          children: [
            Text(
              'Data tools',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Export what is stored locally or reset the app when you want a clean start.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _SummaryChip(
                        label: 'Sessions',
                        value: '${bundle.sessionCount}',
                      ),
                      _SummaryChip(
                        label: 'Moves noticed',
                        value: '${bundle.totalMoves}',
                      ),
                      _SummaryChip(
                        label: 'History days',
                        value: '${bundle.history.length}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    bundle.toPrettyJson(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _copyExport(bundle),
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copy JSON export'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ref.invalidate(appExportBundleProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Refresh snapshot'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset tools',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Progress reset keeps your settings. Full reset clears settings, history, reminders, and onboarding.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton(
                        onPressed: _resetting
                            ? null
                            : () => _confirmReset(fullReset: false),
                        child: const Text('Reset progress'),
                      ),
                      OutlinedButton(
                        onPressed: _resetting
                            ? null
                            : () => _confirmReset(fullReset: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF943F33),
                        ),
                        child: Text(_resetting ? 'Resetting...' : 'Full reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyExport(AppExportBundle bundle) async {
    await Clipboard.setData(ClipboardData(text: bundle.toPrettyJson()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export copied to clipboard.')),
    );
  }

  Future<void> _confirmReset({required bool fullReset}) async {
    final confirmed = await _showResetDialog(fullReset: fullReset);
    if (confirmed != true) {
      return;
    }

    setState(() => _resetting = true);
    final repository = ref.read(appDataRepositoryProvider);
    if (fullReset) {
      await repository.resetEverything();
      await ref.read(notificationServiceProvider).cancelDailyReminder();
    } else {
      await repository.resetProgressOnly();
    }

    ref.invalidate(appExportBundleProvider);
    ref.invalidate(settingsControllerProvider);
    ref.invalidate(sessionControllerProvider);
    ref.invalidate(historyTimelineProvider);
    ref.invalidate(onboardingControllerProvider);

    if (!mounted) {
      return;
    }

    setState(() => _resetting = false);
    if (fullReset) {
      context.go('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pocket progress reset. A fresh session will be ready.',
          ),
        ),
      );
    }
  }

  Future<bool?> _showResetDialog({required bool fullReset}) {
    final title = fullReset ? 'Full reset?' : 'Reset progress?';
    final message = fullReset
        ? 'This clears current progress, history, settings, reminders, and onboarding from this device.'
        : 'This clears the current session and history, but keeps your settings and reminder preferences.';
    final useCupertino = isCupertinoPlatform(Theme.of(context).platform);

    if (useCupertino) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(message),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: fullReset,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
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
        color: Colors.white.withValues(alpha: 0.72),
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
