import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/sound_effects_service.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../../../app/theme.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/domain/coin_style.dart';
import '../application/session_controller.dart';
import '../domain/daily_session.dart';
import '../domain/trigger_tag.dart';
import 'widgets/coin_transfer_overlay.dart';
import 'widgets/pocket_card.dart';
import 'widgets/primary_coin_button.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with WidgetsBindingObserver {
  int _animationTrigger = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(sessionControllerProvider.notifier).refreshForToday());
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionControllerProvider);
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
        child: sessionAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _ErrorState(
            onRetry: () {
              ref.invalidate(settingsControllerProvider);
              ref.invalidate(sessionControllerProvider);
            },
          ),
          data: (session) => ListView(
            children: [
              _Header(session: session),
              if (kIsWeb) ...[
                const SizedBox(height: 18),
                const _WebPromoCard(),
              ],
              const SizedBox(height: 18),
              const _PurposeCard(),
              const SizedBox(height: 18),
              _PocketBoard(
                session: session,
                settings: settings ?? const AppSettings.defaults(),
                reducedMotion: reducedMotion,
                trigger: _animationTrigger,
                onMove: () => _moveCoin(settings, reducedMotion),
                onUndo: _undoMove,
                statusMessage: _statusMessage(session),
              ),
              const SizedBox(height: 18),
              _AwarenessCard(
                session: session,
                onOpenReflection: _openReflectionEditor,
              ),
              const SizedBox(height: 18),
              const _ContextCard(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _moveCoin(AppSettings? settings, bool reducedMotion) async {
    final moved = await ref.read(sessionControllerProvider.notifier).moveCoin();
    if (!mounted || !moved) {
      return;
    }

    setState(() {
      _animationTrigger += 1;
    });

    if (settings?.hapticsEnabled ?? true) {
      unawaited(HapticFeedback.lightImpact());
    }

    if (settings?.soundEnabled ?? true) {
      unawaited(
        ref
            .read(soundEffectsServiceProvider)
            .playCoinLanding(
              delay: reducedMotion
                  ? const Duration(milliseconds: 80)
                  : const Duration(milliseconds: 340),
            ),
      );
    }

    if (!mounted) {
      return;
    }

    if (!reducedMotion) {
      await Future<void>.delayed(const Duration(milliseconds: 140));
    }
    if (!mounted) {
      return;
    }
    await _promptForLastMoveDetails();
  }

  Future<void> _undoMove() async {
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    final undone = await ref
        .read(sessionControllerProvider.notifier)
        .undoLastMove();
    if (!mounted || !undone) {
      return;
    }

    if (settings?.hapticsEnabled ?? true) {
      await HapticFeedback.selectionClick();
    }
  }

  String _statusMessage(DailySession session) {
    if (session.remainingCoins == 0) {
      return 'Fresh pockets tomorrow.';
    }
    if (session.movedCoins == 0) {
      return 'A small shift is still a shift.';
    }
    if (session.movedCoins == 1) {
      return 'You noticed it. That counts.';
    }
    return 'You are building awareness one little flip at a time.';
  }

  Future<void> _promptForLastMoveDetails() async {
    final result = await showModalBottomSheet<_MoveCaptureResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MoveCaptureSheet(),
    );
    if (result == null) {
      return;
    }

    await ref
        .read(sessionControllerProvider.notifier)
        .annotateLastMove(triggerTag: result.triggerTag, note: result.note);
  }

  Future<void> _openReflectionEditor() async {
    final session = ref.read(sessionControllerProvider).valueOrNull;
    if (session == null) {
      return;
    }

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

    await ref
        .read(sessionControllerProvider.notifier)
        .saveReflection(
          whatShowedUp: result.whatShowedUp,
          whatHelped: result.whatHelped,
          forTomorrow: result.forTomorrow,
        );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session});

  final DailySession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pocket Shift', style: theme.textTheme.displayMedium),
        const SizedBox(height: 8),
        Text(
          'A gentle pocket ritual for noticing negative loops before they quietly steer the day.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Pill(
              icon: Icons.today_rounded,
              label: 'Today: ${session.startingCoins} coins',
            ),
            _Pill(
              icon: Icons.spa_outlined,
              label: '${session.remainingCoins} still in the left pocket',
            ),
          ],
        ),
      ],
    );
  }
}

class _PurposeCard extends StatelessWidget {
  const _PurposeCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked =
              constraints.maxWidth < 430 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.15;

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _PurposeIcon(),
                SizedBox(height: 14),
                _PurposeCopy(),
              ],
            );
          }

          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PurposeIcon(),
              SizedBox(width: 14),
              Expanded(child: _PurposeCopy()),
            ],
          );
        },
      ),
    );
  }
}

class _WebPromoCard extends StatelessWidget {
  const _WebPromoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasStoreUrl = AppConstants.iosAppStoreUrl.isNotEmpty;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.ps.accentSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  AppConstants.iosStoreAvailabilityLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                AppConstants.iosPriceLabel,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            hasStoreUrl
                ? 'Prefer the native mobile experience? Pocket Shift is now live on the App Store, and Android is coming soon while this web version stays free.'
                : 'Prefer the native mobile experience? Pocket Shift is coming soon to iPhone and Android, while this web version stays free.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 10),
          if (hasStoreUrl)
            OutlinedButton.icon(
              onPressed: () =>
                  _openExternal(context, AppConstants.iosAppStoreUrl),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open on the App Store'),
            )
          else ...[
            Text(
              'The direct App Store link will be added here once the listing is live.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not open $url right now.')));
  }
}

class _PurposeIcon extends StatelessWidget {
  const _PurposeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: context.ps.accentSurface,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lightbulb_outline_rounded),
    );
  }
}

class _PurposeCopy extends StatelessWidget {
  const _PurposeCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why this exists', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          'Pocket Shift was inspired by a counseling exercise: start the day with coins in one pocket, then move one each time you catch a negative thought pattern. The point is not shame. The point is awareness, a pause, and a chance to shift the tone of the day.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _AwarenessCard extends StatelessWidget {
  const _AwarenessCard({required this.session, required this.onOpenReflection});

  final DailySession session;
  final Future<void> Function() onOpenReflection;

  @override
  Widget build(BuildContext context) {
    final taggedMoves = session.moves
        .where((move) => move.triggerTag != null)
        .length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today’s awareness',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            session.movedCoins == 0
                ? 'When you notice a shift, tag what was going on. Over time, your history and weekly insights will show patterns that are hard to see in the moment.'
                : 'Each move can hold a little context. Tagging what happened makes your weekly patterns more useful and more honest.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Pill(
                icon: Icons.label_outline_rounded,
                label: '$taggedMoves tagged shifts',
              ),
              _Pill(
                icon: Icons.insights_outlined,
                label: session.topTrigger == null
                    ? 'No top trigger yet'
                    : 'Top trigger: ${session.topTrigger!.label}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.ps.subtleSurface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.hasReflection
                      ? 'Today’s reflection'
                      : 'End-of-day reflection',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  session.hasReflection
                      ? session.reflection?.whatShowedUp ??
                            session.reflection?.whatHelped ??
                            session.reflection?.forTomorrow ??
                            'Reflection saved.'
                      : 'Capture what showed up, what helped, and what you want tomorrow to feel like.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () {
                    unawaited(onOpenReflection());
                  },
                  icon: const Icon(Icons.auto_stories_outlined),
                  label: Text(
                    session.hasReflection
                        ? 'Edit reflection'
                        : 'Add reflection',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PocketBoard extends StatelessWidget {
  const _PocketBoard({
    required this.session,
    required this.settings,
    required this.reducedMotion,
    required this.trigger,
    required this.onMove,
    required this.onUndo,
    required this.statusMessage,
  });

  final DailySession session;
  final AppSettings settings;
  final bool reducedMotion;
  final int trigger;
  final Future<void> Function() onMove;
  final Future<void> Function() onUndo;
  final String statusMessage;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical = constraints.maxWidth < 640 || textScale > 1.18;
          final layout = vertical
              ? PocketBoardLayout.vertical
              : PocketBoardLayout.horizontal;
          final pocketSpacing = vertical ? 12.0 : 14.0;

          return Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF294A70),
                  Color(0xFF1C3550),
                  Color(0xFF13263C),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFF89A9C7).withValues(alpha: 0.24),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 28,
                  offset: Offset(0, 16),
                  color: Color(0x24152A42),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Today\'s jeans',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Stack(
                  children: [
                    vertical
                        ? Column(
                            children: [
                              PocketCard(
                                label: 'Left pocket',
                                count: session.remainingCoins,
                                helper: session.remainingCoins > 0
                                    ? '${session.remainingCoins} still with you for the rest of today.'
                                    : 'Empty for today. Fresh pockets tomorrow.',
                                coinStyle: settings.coinStyle,
                                side: PocketSide.left,
                                compact: true,
                              ),
                              SizedBox(height: pocketSpacing),
                              PocketCard(
                                label: 'Right pocket',
                                count: session.movedCoins,
                                helper: session.movedCoins == 0
                                    ? 'Quiet so far. Awareness can still arrive later.'
                                    : 'Each coin marks a moment you noticed.',
                                coinStyle: settings.coinStyle,
                                side: PocketSide.right,
                                compact: true,
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: PocketCard(
                                  label: 'Left pocket',
                                  count: session.remainingCoins,
                                  helper: session.remainingCoins > 0
                                      ? '${session.remainingCoins} still with you for the rest of today.'
                                      : 'Empty for today. Fresh pockets tomorrow.',
                                  coinStyle: settings.coinStyle,
                                  side: PocketSide.left,
                                ),
                              ),
                              SizedBox(width: pocketSpacing),
                              Expanded(
                                child: PocketCard(
                                  label: 'Right pocket',
                                  count: session.movedCoins,
                                  helper: session.movedCoins == 0
                                      ? 'Quiet so far. Awareness can still arrive later.'
                                      : 'Each coin marks a moment you noticed.',
                                  coinStyle: settings.coinStyle,
                                  side: PocketSide.right,
                                ),
                              ),
                            ],
                          ),
                    Positioned.fill(
                      child: CoinTransferOverlay(
                        trigger: trigger,
                        reducedMotion: reducedMotion,
                        coinStyle: settings.coinStyle,
                        layout: layout,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                PrimaryCoinButton(
                  enabled: session.canMoveCoin,
                  coinLabel: settings.coinStyle.label.toLowerCase(),
                  onPressed: () {
                    unawaited(onMove());
                  },
                ),
                const SizedBox(height: 12),
                vertical
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusMessage,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: session.canUndo
                                ? () {
                                    unawaited(onUndo());
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            icon: const Icon(Icons.undo_rounded),
                            label: const Text('Undo last'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Text(
                              statusMessage,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: session.canUndo
                                ? () {
                                    unawaited(onUndo());
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.22),
                              ),
                            ),
                            icon: const Icon(Icons.undo_rounded),
                            label: const Text('Undo last'),
                          ),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A little context helps',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'This ritual came from counseling as a way to raise awareness around negative patterns before they shape the atmosphere of the day. Pocket Shift keeps that practice light and private so a tiny pause can become a meaningful shift.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _MoveCaptureResult {
  const _MoveCaptureResult({this.triggerTag, this.note});

  final TriggerTag? triggerTag;
  final String? note;
}

class _MoveCaptureSheet extends StatefulWidget {
  const _MoveCaptureSheet();

  @override
  State<_MoveCaptureSheet> createState() => _MoveCaptureSheetState();
}

class _MoveCaptureSheetState extends State<_MoveCaptureSheet> {
  final TextEditingController _noteController = TextEditingController();
  TriggerTag? _selectedTag;

  @override
  void dispose() {
    _noteController.dispose();
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
                Text(
                  'What triggered that shift?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a little context while the moment is still fresh. You can skip this if you just want the move recorded.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: TriggerTag.values.map((tag) {
                    final selected = tag == _selectedTag;
                    return ChoiceChip(
                      label: Text(tag.label),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedTag = selected ? null : tag;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Optional note',
                    hintText: 'What happened in that moment?',
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Skip'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          _MoveCaptureResult(
                            triggerTag: _selectedTag,
                            note: _noteController.text,
                          ),
                        );
                      },
                      child: const Text('Save details'),
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
  late final TextEditingController _whatShowedUpController =
      TextEditingController(text: widget.initialWhatShowedUp);
  late final TextEditingController _whatHelpedController =
      TextEditingController(text: widget.initialWhatHelped);
  late final TextEditingController _forTomorrowController =
      TextEditingController(text: widget.initialForTomorrow);

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
                Text(
                  'Reflect on today',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'A few sentences make the history and weekly insights much more useful later.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _whatShowedUpController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'What showed up most today?',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _whatHelpedController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'What helped you reset?',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _forTomorrowController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'What do you want tomorrow to feel like?',
                  ),
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

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.ps.chipSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SectionCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Today\'s pockets need a quick refresh.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'We could not load your current session, but your local data is still here. Try again and we will pick it back up.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
