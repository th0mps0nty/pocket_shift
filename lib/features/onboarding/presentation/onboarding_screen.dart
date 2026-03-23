import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/soft_background.dart';
import '../application/onboarding_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  static const _pages = [
    _OnboardingPageData(
      title: 'A counseling exercise, made pocket-sized.',
      body:
          'Pocket Shift was inspired by a simple practice: start the day with coins in one pocket and move one whenever you catch a negative spiral.',
      icon: Icons.favorite_border_rounded,
    ),
    _OnboardingPageData(
      title: 'This is about awareness, not punishment.',
      body:
          'One tap is enough. The goal is to notice the moment, pause, and make a little room for a kinder perspective.',
      icon: Icons.visibility_outlined,
    ),
    _OnboardingPageData(
      title: 'Fresh pockets tomorrow.',
      body:
          'Your history stays local, gentle, and private. With gratitude to Brett Froggatt for sharing the original exercise that inspired this app.',
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _pageIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _finish, child: const Text('Skip')),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _PageCard(page: page);
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _pageIndex == index ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _pageIndex == index
                        ? const Color(0xFF3A6E69)
                        : const Color(0xFF3A6E69).withValues(alpha: 0.18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLastPage ? _finish : _nextPage,
                child: Text(isLastPage ? 'Start shifting' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _nextPage() async {
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (!mounted) {
      return;
    }
    context.go('/game');
  }
}

class _PageCard extends StatelessWidget {
  const _PageCard({required this.page});

  final _OnboardingPageData page;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE2F0E7),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                    color: const Color(0xFF17302E).withValues(alpha: 0.08),
                  ),
                ],
              ),
              child: Icon(page.icon, size: 42, color: const Color(0xFF3A6E69)),
            ),
            const SizedBox(height: 24),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              page.body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
