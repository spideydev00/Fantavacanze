import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model.dart';

class ProcessedChallenge {
  final DailyChallengeModel challenge;
  final bool isPrimary; // Is this a primary challenge (vs a substitute)
  final bool canRefresh; // Can this challenge be refreshed
  final int originalPrimaryIndex; // Original index of the primary challenge

  ProcessedChallenge({
    required this.challenge,
    required this.isPrimary,
    required this.canRefresh,
    required this.originalPrimaryIndex,
  });
}

class ChallengeProcessor {
  /// Process challenges to determine primary and substitute challenges
  static List<ProcessedChallenge> processChallenges(
      List<DailyChallengeModel> challenges) {
    // Return empty list if no challenges
    if (challenges.isEmpty) return [];

    // Sort challenges by position to maintain original order
    final sortedChallenges = List<DailyChallengeModel>.from(challenges)
      ..sort((a, b) => a.position.compareTo(b.position));

    // Extract primary and substitute challenges
    final List<DailyChallengeModel> primaryChallenges = [];
    final List<DailyChallengeModel> substituteChallenges = [];

    // First 3 positions (0-2) are primary challenges
    // Last 3 positions (3-5) are substitute challenges
    for (int i = 0; i < sortedChallenges.length; i++) {
      if (i < 3) {
        primaryChallenges.add(sortedChallenges[i]);
      } else {
        substituteChallenges.add(sortedChallenges[i]);
      }
    }

    // Create the final list of processed challenges
    final List<ProcessedChallenge> result = [];

    // Process primary challenges first (positions 0-2)
    for (int i = 0; i < primaryChallenges.length; i++) {
      final primaryChallenge = primaryChallenges[i];
      final substituteAvailable = i < substituteChallenges.length;

      // If this primary challenge has been refreshed, show its substitute
      if (primaryChallenge.isRefreshed && substituteAvailable) {
        final substitute = substituteChallenges[i];
        result.add(ProcessedChallenge(
          challenge: substitute,
          isPrimary: false,
          canRefresh: false, // Substitutes can't be refreshed
          originalPrimaryIndex: i,
        ));
      } else {
        // Show the primary challenge
        result.add(ProcessedChallenge(
          challenge: primaryChallenge,
          isPrimary: true,
          canRefresh:
              !primaryChallenge.isRefreshed && !primaryChallenge.isCompleted,
          originalPrimaryIndex: i,
        ));
      }
    }

    // Sort the result to keep completed challenges in their original position
    // This preserves the order for free users and prevents revealing new challenges
    result.sort((a, b) {
      // Primary sort by original index to maintain position
      final positionCompare =
          a.originalPrimaryIndex.compareTo(b.originalPrimaryIndex);

      // Secondary sort: completed challenges stay in place
      if (positionCompare == 0) {
        if (a.challenge.isCompleted && !b.challenge.isCompleted) {
          return 0; // Keep completed challenge in same position
        } else if (!a.challenge.isCompleted && b.challenge.isCompleted) {
          return 0; // Keep completed challenge in same position
        }
      }

      return positionCompare;
    });

    return result;
  }
}
