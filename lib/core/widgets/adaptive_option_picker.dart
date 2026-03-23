import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/platform_utils.dart';

class AdaptiveOption<T> {
  const AdaptiveOption({
    required this.value,
    required this.title,
    this.subtitle,
  });

  final T value;
  final String title;
  final String? subtitle;
}

Future<T?> showAdaptiveOptionPicker<T>({
  required BuildContext context,
  required String title,
  required List<AdaptiveOption<T>> options,
  T? selectedValue,
}) async {
  if (isCupertinoPlatform(Theme.of(context).platform)) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (popupContext) => CupertinoActionSheet(
        title: Text(title),
        actions: options
            .map(
              (option) => CupertinoActionSheetAction(
                onPressed: () => Navigator.of(popupContext).pop(option.value),
                isDefaultAction: option.value == selectedValue,
                child: Column(
                  children: [
                    Text(option.title),
                    if (option.subtitle case final subtitle?) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(popupContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          ...options.map(
            (option) => ListTile(
              title: Text(option.title),
              subtitle: option.subtitle == null ? null : Text(option.subtitle!),
              trailing: option.value == selectedValue
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(option.value),
            ),
          ),
        ],
      ),
    ),
  );
}
