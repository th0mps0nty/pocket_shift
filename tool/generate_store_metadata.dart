import 'dart:convert';
import 'dart:io';

void main() {
  final root = Directory.current;
  final sourceFile = File('${root.path}/store_metadata/source.json');
  final source =
      jsonDecode(sourceFile.readAsStringSync()) as Map<String, dynamic>;

  final appName = source['appName'] as String;
  final tagline = source['tagline'] as String;
  final coreValue = source['coreValue'] as String;
  final audience = source['audience'] as String;
  final features = (source['features'] as List<dynamic>).cast<String>();
  final keywords = (source['keywords'] as List<dynamic>).cast<String>();
  final apple = source['apple'] as Map<String, dynamic>;
  final google = source['google'] as Map<String, dynamic>;
  final credits = source['credits'] as Map<String, dynamic>;
  final privacy = source['privacy'] as Map<String, dynamic>;
  final releaseNotes = (source['releaseNotes'] as List<dynamic>).cast<String>();

  final appStoreDescription = [
    '$appName is a calm, supportive micro-habit app built around a simple counseling exercise: begin the day with coins in one pocket, then move one each time you notice yourself slipping into a negative loop.',
    '',
    'The goal is not shame. The goal is awareness. Each coin becomes a small pause, a moment of honesty, and a chance to shift the tone of the day before it spreads any further.',
    '',
    'Why people use Pocket Shift:',
    ...features.map((feature) => '- $feature'),
    '',
    'Pocket Shift is especially meaningful for $audience',
    '',
    'Design principles:',
    '- Awareness over shame',
    '- Gentle repetition over perfection',
    '- Private, local-first reflection',
    '- Fast enough to use in the moment',
    '',
    credits['attribution'] as String,
    'Public attribution contact currently listed: ${credits['contact'] as String}',
    '',
    privacy['summary'] as String,
  ].join('\n');

  final playDescription = [
    tagline,
    '',
    coreValue,
    '',
    'Pocket Shift helps you:',
    ...features.map((feature) => '- $feature'),
    '',
    'Made for $audience',
    '',
    'Local-first privacy:',
    privacy['summary'] as String,
    '',
    'Principles:',
    '- Awareness over shame',
    '- A small shift is still a shift',
    '- Fresh pockets tomorrow',
  ].join('\n');

  final appStoreMarkdown =
      '''# App Store Connect Draft

## Name
$appName

## Subtitle
${apple['subtitle'] as String}

## Promotional Text
${apple['promotionalText'] as String}

## Keywords
${keywords.join(', ')}

## Primary Category
${apple['category'] as String}

## Secondary Category
${apple['secondaryCategory'] as String}

## Description
$appStoreDescription

## What's New
${releaseNotes.map((note) => '- $note').join('\n')}

## Support URL
Provide production support URL before submission.

## Marketing URL
Optional. Add if a public landing page is created.

## Privacy Summary
${privacy['summary'] as String}

## Screenshot Copy Ideas
- Notice it. Flip one coin.
- A small shift is still a shift.
- Fresh pockets tomorrow.
- Gentle reminders. Local history. Zero shame.
''';

  final playMarkdown =
      '''# Google Play Draft

## App Name
$appName

## Short Description
${google['shortDescription'] as String}

## Full Description
$playDescription

## Category
${google['category'] as String}

## Release Notes
${releaseNotes.map((note) => '- $note').join('\n')}

## Contact Email
Provide production support email before submission.

## Data Safety Working Notes
- Data stored locally on device: yes
- Personal account required: no
- Data shared with third parties: no
- Analytics SDK included: no
- Cloud sync included: no

## Graphic Copy Ideas
- Catch the spiral earlier.
- One pocket. One coin. One pause.
- Calm, private awareness for everyday negativity.
''';

  File('${root.path}/store_metadata/generated/app_store_connect.md')
    ..createSync(recursive: true)
    ..writeAsStringSync(appStoreMarkdown);
  File('${root.path}/store_metadata/generated/play_store.md')
    ..createSync(recursive: true)
    ..writeAsStringSync(playMarkdown);

  stdout.writeln('Generated store metadata drafts.');
}
