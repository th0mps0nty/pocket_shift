import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/platform_utils.dart';

Future<TimeOfDay?> showAdaptivePocketTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  if (!isCupertinoPlatform(Theme.of(context).platform)) {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  var selected = initialTime;

  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (popupContext) {
      final use24Hour = MediaQuery.of(popupContext).alwaysUse24HourFormat;
      final initialDate = DateTime(
        2026,
        1,
        1,
        initialTime.hour,
        initialTime.minute,
      );

      return Container(
        height: 320,
        padding: const EdgeInsets.only(top: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F6F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(popupContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(popupContext).pop(selected),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  'Reminder',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17302E),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: use24Hour,
                  initialDateTime: initialDate,
                  onDateTimeChanged: (value) {
                    selected = TimeOfDay(
                      hour: value.hour,
                      minute: value.minute,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
