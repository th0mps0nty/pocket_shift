import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/sound_effects_service.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/soft_background.dart';
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
              _PurposeCard(),
              const SizedBox(height: 18),
              SectionCard(
                padding: const EdgeInsets.all(14),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF27496D),
                        Color(0xFF1C3550),
                        Color(0xFF13263C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF89A9C7).withValues(alpha: 0.24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s jeans',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 256,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: PocketCard(
                                    label: 'Left pocket',
                                    count: session.remainingCoins,
                                    helper: session.remainingCoins > 0
                                        ? '${session.remainingCoins} still with you for the rest of today.'
                                        : 'Empty for today. Fresh pockets tomorrow.',
                                    coinStyle: settings?.coinStyle ?? const AppSettings.defaults().coinStyle,
                                    side: PocketSide.left,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: PocketCard(
                                    label: 'Right pocket',
                                    count: session.movedCoins,
                                    helper: session.movedCoins == 0
                                        ? 'Quiet so far. Awareness can still arrive later.'
                                        : 'Each coin marks a moment you noticed.',
                                    coinStyle: settings?.coinStyle ?? const AppSettings.defaults().coinStyle,
                                    side: PocketSide.right,
                                  ),
                                ),
                              ],
                            ),
                            CoinTransferOverlay(
                              trigger: _animationTrigger,
                              reducedMotion: reducedMotion,
                              coinStyle: settings?.coinStyle ?? const AppSettings.defaults().coinStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      PrimaryCoinButton(
                        enabled: session.canMoveCoin,
                        coinLabel: (settings?.coinStyle ?? const AppSettings.defaults().coinStyle)
                            .label
                            .toLowerCase(),
                        onPressed: () => _moveCoin(settings, reducedMotion),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _statusMessage(session),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: session.canUndo ? _undoMove : null,
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
                ),
              ),
              const SizedBox(height: 18),
              _ContextCard(),
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
        ref.read(soundEffectsServiceProvider).playCoinLanding(
              delay: reducedMotion
                  ? const Duration(milliseconds: 90)
                  : const Duration(milliseconds: 330),
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
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFE3EEE8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline_rounded),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why this exists', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Pocket Shift was inspired by a counseling exercise: start the day with coins in one pocket, then move one each time you catch a negative thought pattern. The point is not shame. The point is awareness, a pause, and a chance to shift the tone of the day.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('A little context helps', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'This practice came from counseling as a practical way to raise awareness and gently shift a family toward a more positive perspective. With gratitude to Brett Froggatt of Second Chance Columbus for sharing the exercise that inspired this app. Contact: brett@secondchancecolumbus.com.',
            style: Theme.of(context).textTheme.bodyMedium,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SectionCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pocket Shift hit a small snag.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Try reloading and we will bring today back into view.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }
}
