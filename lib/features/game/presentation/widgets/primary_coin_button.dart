import 'package:flutter/material.dart';

class PrimaryCoinButton extends StatelessWidget {
  const PrimaryCoinButton({
    super.key,
    required this.enabled,
    required this.coinLabel,
    required this.onPressed,
  });

  final bool enabled;
  final String coinLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled
          ? 'Move one $coinLabel coin from the left pocket to the right pocket'
          : 'No coins remain to move today',
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: const Icon(Icons.swipe_right_alt_rounded, size: 30),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flip one $coinLabel'),
                Text(
                  enabled ? 'You noticed it. That counts.' : 'Fresh pockets tomorrow.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
