enum TriggerTag {
  complaining,
  selfCriticism,
  impatience,
  rumination,
  partnerFeedback,
  workStress,
  sarcasm,
  overwhelm,
  other,
}

extension TriggerTagX on TriggerTag {
  String get storageValue => name;

  String get label {
    switch (this) {
      case TriggerTag.complaining:
        return 'Complaining';
      case TriggerTag.selfCriticism:
        return 'Self-criticism';
      case TriggerTag.impatience:
        return 'Impatience';
      case TriggerTag.rumination:
        return 'Rumination';
      case TriggerTag.partnerFeedback:
        return 'Partner feedback';
      case TriggerTag.workStress:
        return 'Work stress';
      case TriggerTag.sarcasm:
        return 'Sarcasm';
      case TriggerTag.overwhelm:
        return 'Overwhelm';
      case TriggerTag.other:
        return 'Other';
    }
  }

  String get helper {
    switch (this) {
      case TriggerTag.complaining:
        return 'A moment of venting or negative narration.';
      case TriggerTag.selfCriticism:
        return 'Talking to yourself more harshly than you would to someone else.';
      case TriggerTag.impatience:
        return 'A quick edge, snap, or frustration spike.';
      case TriggerTag.rumination:
        return 'Getting stuck replaying something heavy or negative.';
      case TriggerTag.partnerFeedback:
        return 'Someone close to you pointed out the shift.';
      case TriggerTag.workStress:
        return 'Pressure, deadlines, or work friction fed the moment.';
      case TriggerTag.sarcasm:
        return 'Sharp humor that signals a mood shift.';
      case TriggerTag.overwhelm:
        return 'Too much at once, mentally or emotionally.';
      case TriggerTag.other:
        return 'A different kind of trigger not covered above.';
    }
  }

  static TriggerTag? fromStorageValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    for (final tag in TriggerTag.values) {
      if (tag.storageValue == value) {
        return tag;
      }
    }
    return null;
  }
}
