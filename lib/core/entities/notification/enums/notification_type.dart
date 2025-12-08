enum NotificationType {
  //TODO: add all ephemeral types
  dailyChallengeRequest('daily_challenge_request'),
  dailyChallengeApproved('daily_challenge_approved'),
  dailyChallengeReminder('daily_challenge_reminder'),
  ruleCompleted('rule_completed'),
  newRule('new_rule'),
  memoryAdded('memory_added'),
  appUpdate('app_update');

  const NotificationType(this.value);
  final String value;

  static NotificationType? fromString(String? value) {
    if (value == null) return null;
    try {
      return NotificationType.values.firstWhere(
        (type) => type.value == value,
      );
    } catch (e) {
      return null;
    }
  }

  bool get isEphemeral =>
      this == ruleCompleted ||
      this == newRule ||
      this == memoryAdded ||
      this == dailyChallengeReminder ||
      this == dailyChallengeApproved ||
      this == appUpdate;

  bool get isPersistent => !isEphemeral;
}
