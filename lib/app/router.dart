import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/utils/platform_utils.dart';
import '../core/widgets/app_shell.dart';
import '../core/widgets/section_card.dart';
import '../core/widgets/soft_background.dart';
import '../features/game/application/session_controller.dart';
import '../features/game/presentation/game_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/data_tools_screen.dart';
import '../features/settings/presentation/reminder_copy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final appStartupProvider = FutureProvider<bool>((ref) async {
  final onboardingComplete = await ref.read(
    onboardingControllerProvider.future,
  );
  await ref.read(settingsControllerProvider.future);
  await ref.read(sessionControllerProvider.future);
  return onboardingComplete;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildAdaptivePage(
          context: context,
          state: state,
          child: const AppStartupGate(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _buildAdaptivePage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  context: context,
                  state: state,
                  child: const GameScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  context: context,
                  state: state,
                  child: const HistoryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => _buildAdaptivePage(
                  context: context,
                  state: state,
                  child: const SettingsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'about',
                    pageBuilder: (context, state) => _buildAdaptivePage(
                      context: context,
                      state: state,
                      child: const AboutScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'reminder-copy',
                    pageBuilder: (context, state) => _buildAdaptivePage(
                      context: context,
                      state: state,
                      child: const ReminderCopyScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'data-tools',
                    pageBuilder: (context, state) => _buildAdaptivePage(
                      context: context,
                      state: state,
                      child: const DataToolsScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class AppStartupGate extends ConsumerWidget {
  const AppStartupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        child: startup.when(
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Setting out today\'s pockets...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: SectionCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pocket Shift needs one more try.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We could not finish startup, but your data is still local. Try again and we will pick back up.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref.invalidate(onboardingControllerProvider);
                      ref.invalidate(settingsControllerProvider);
                      ref.invalidate(sessionControllerProvider);
                      ref.invalidate(appStartupProvider);
                    },
                    child: const Text('Retry startup'),
                  ),
                ],
              ),
            ),
          ),
          data: (onboardingComplete) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              context.go(onboardingComplete ? '/game' : '/onboarding');
            });

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

Page<void> _buildAdaptivePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  if (isCupertinoPlatform(Theme.of(context).platform)) {
    return CupertinoPage<void>(
      key: state.pageKey,
      name: state.name,
      child: child,
    );
  }

  return MaterialPage<void>(key: state.pageKey, name: state.name, child: child);
}
