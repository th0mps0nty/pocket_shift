import 'package:flutter/material.dart';

import '../../../core/widgets/adaptive_secondary_scaffold.dart';
import '../../../core/widgets/section_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveSecondaryScaffold(
      title: 'About Pocket Shift',
      child: ListView(
        children: [
          Text(
            'About Pocket Shift',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pocket Shift turns a simple counseling exercise into a gentle daily ritual for noticing negative thought patterns and creating space for a more grounded response.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          const SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why it exists'),
                SizedBox(height: 10),
                Text(
                  'The original exercise is wonderfully tactile: begin the day with coins in one pocket, then move one whenever you catch yourself sliding into negativity. It is not a punishment system. It is a pattern-noticing system. Each move is a small act of honesty, awareness, and perspective-shifting.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('A family-facing practice'),
                SizedBox(height: 10),
                Text(
                  'For your story, this came from counseling as a practical way to help your family become more aware of negative habits and gently steer the atmosphere toward something more positive. Pocket Shift keeps that spirit: calm, fast, private, and emotionally safe.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Credits'),
                SizedBox(height: 10),
                Text(
                  'With gratitude to Brett Froggatt of Second Chance Columbus for sharing the counseling exercise that inspired Pocket Shift.',
                ),
                SizedBox(height: 8),
                Text('Contact: brett@secondchancecolumbus.com'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pocket Shift principles'),
                SizedBox(height: 10),
                Text('Awareness over shame.'),
                SizedBox(height: 6),
                Text('Gentle repetition over perfection.'),
                SizedBox(height: 6),
                Text('Fresh pockets tomorrow.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
