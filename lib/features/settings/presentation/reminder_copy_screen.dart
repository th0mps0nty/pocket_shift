import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/adaptive_secondary_scaffold.dart';
import '../../../core/widgets/section_card.dart';
import '../../../app/theme.dart';
import '../application/settings_controller.dart';

class ReminderCopyScreen extends ConsumerStatefulWidget {
  const ReminderCopyScreen({super.key});

  @override
  ConsumerState<ReminderCopyScreen> createState() => _ReminderCopyScreenState();
}

class _ReminderCopyScreenState extends ConsumerState<ReminderCopyScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return AdaptiveSecondaryScaffold(
      title: 'Reminder copy',
      child: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ReminderCopyError(onRetry: () => ref.invalidate(settingsControllerProvider)),
        data: (settings) {
          if (!_loaded) {
            _titleController.text = settings.reminderTitle;
            _bodyController.text = settings.reminderBody;
            _loaded = true;
          }

          return ListView(
            children: [
              Text('Reminder copy', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                'Write the gentle nudge you want to see each day. Keep it kind, short, and easy to receive.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preview', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
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
                          Text(
                            _titleController.text.trim().isEmpty
                                ? AppConstants.defaultReminderTitle
                                : _titleController.text.trim(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _bodyController.text.trim().isEmpty
                                ? AppConstants.defaultReminderBody
                                : _bodyController.text.trim(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
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
                    Text('Title', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _titleController,
                      maxLength: 40,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(hintText: 'Pocket Shift', border: OutlineInputBorder()),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text('Body', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _bodyController,
                      maxLength: 140,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Pause for a breath and notice what pocket today is in.',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(_saving ? 'Saving...' : 'Save reminder'),
                        ),
                        OutlinedButton(
                          onPressed: _saving ? null : _restoreDefaults,
                          child: const Text('Reset to defaults'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref
        .read(settingsControllerProvider.notifier)
        .updateReminderCopy(title: _titleController.text, body: _bodyController.text);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder copy updated.')));
  }

  Future<void> _restoreDefaults() async {
    await ref.read(settingsControllerProvider.notifier).resetReminderCopy();
    final settings = await ref.read(settingsControllerProvider.future);
    _titleController.text = settings.reminderTitle;
    _bodyController.text = settings.reminderBody;
    if (!mounted) {
      return;
    }
    setState(() {});
  }
}

class _ReminderCopyError extends StatelessWidget {
  const _ReminderCopyError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SectionCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reminder copy needs a quick reload.', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
