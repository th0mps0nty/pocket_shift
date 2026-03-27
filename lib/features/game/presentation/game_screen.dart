import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/sound_effects_service.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
import '../../../app/theme.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/domain/coin_style.dart';
import '../application/session_controller.dart';
import '../domain/daily_session.dart';
import 'widgets/coin_transfer_overlay.dart';
import 'widgets/pocket_card.dart';
import 'widgets/primary_coin_button.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver {
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
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

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
              delay: reducedMotion ? const Duration(milliseconds: 80) : const Duration(milliseconds: 340),
            ),
      );
    }
  }

  Future<void> _undoMove() async {
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    final undone = await ref.read(sessionControllerProvider.notifier).undoLastMove();
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
            _Pill(icon: Icons.today_rounded, label: 'Today: ${session.startingCoins} coins'),
            _Pill(icon: Icons.spa_outlined, label: '${session.remainingCoins} still in the left pocket'),
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
          final stacked = constraints.maxWidth < 430 || MediaQuery.textScalerOf(context).scale(1) > 1.15;

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [_PurposeIcon(), SizedBox(height: 14), _PurposeCopy()],
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

class _PurposeIcon extends StatelessWidget {
  const _PurposeIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: context.ps.accentSurface, shape: BoxShape.circle),
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
          final layout = vertical ? PocketBoardLayout.vertical : PocketBoardLayout.horizontal;
          final pocketSpacing = vertical ? 12.0 : 14.0;

          return Container(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF294A70), Color(0xFF1C3550), Color(0xFF13263C)],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF89A9C7).withValues(alpha: 0.24)),
              boxShadow: const [BoxShadow(blurRadius: 28, offset: Offset(0, 16), color: Color(0x24152A42))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Today\'s jeans',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
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
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
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
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
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
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
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
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
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
          Text('A little context helps', style: Theme.of(context).textTheme.titleLarge),
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
        decoration: BoxDecoration(color: context.ps.chipSurface, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
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
            Text('Today\'s pockets need a quick refresh.', style: Theme.of(context).textTheme.titleLarge),
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
