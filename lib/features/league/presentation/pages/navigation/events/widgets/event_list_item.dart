import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/features/league/domain/entities/event.dart';
import 'package:intl/intl.dart';

class EventListItem extends StatelessWidget {
  final Event event;

  const EventListItem({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = formatter.format(event.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPointsColor(event.points),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${event.points > 0 ? '+' : ''}${event.points}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPointsColor(int points) {
    if (points > 0) {
      return ColorPalette.success;
    } else if (points < 0) {
      return ColorPalette.error;
    } else {
      return Colors.grey;
    }
  }
}
