import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';

/// Private class to wrap an event with a resolved participant name
/// This allows us to reuse the existing EventCard without modification
class EventWithResolvedName implements Event {
  final Event originalEvent;
  final String resolvedName;

  EventWithResolvedName({
    required this.originalEvent,
    required this.resolvedName,
  });

  // Forward all properties from the original event
  @override
  String get id => originalEvent.id;

  @override
  String get name => originalEvent.name;

  @override
  double get points => originalEvent.points;

  @override
  String get creatorId => originalEvent.creatorId;

  // Replace targetUser with our resolved name for display
  @override
  String get targetUser => resolvedName;

  @override
  DateTime get createdAt => originalEvent.createdAt;

  @override
  RuleType get type => originalEvent.type;

  @override
  String? get description => originalEvent.description;

  @override
  bool get isTeamMember => originalEvent.isTeamMember;
}
