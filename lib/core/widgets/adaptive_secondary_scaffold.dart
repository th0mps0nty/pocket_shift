import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/platform_utils.dart';
import 'soft_background.dart';

class AdaptiveSecondaryScaffold extends StatelessWidget {
  const AdaptiveSecondaryScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(Theme.of(context).platform)) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          previousPageTitle: 'Settings',
        ),
        child: SoftBackground(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: child,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: Colors.transparent,
      body: SoftBackground(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: child,
      ),
    );
  }
}
