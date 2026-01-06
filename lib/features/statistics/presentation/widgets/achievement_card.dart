import 'package:flutter/material.dart';
import '../../domain/entities/stats_entity.dart';

/// Achievement Card Widget
class AchievementCard extends StatelessWidget {
  final AchievementEntity achievement;

  const AchievementCard({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: _buildIcon(),
        title: Text(
          achievement.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(achievement.description),
            const SizedBox(height: 4),
            Text(
              'Unlocked: ${_formatDate(achievement.unlockedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: achievement.notified
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;

    switch (achievement.achievementType) {
      case 'FIRST_DECK':
      case 'FIRST_CARD':
        iconData = Icons.star;
        color = Colors.amber;
        break;
      case 'MASTER_10_CARDS':
      case 'MASTER_100_CARDS':
      case 'MASTER_1000_CARDS':
        iconData = Icons.school;
        color = Colors.blue;
        break;
      case 'STREAK_7_DAYS':
      case 'STREAK_30_DAYS':
      case 'STREAK_100_DAYS':
        iconData = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case 'EARLY_BIRD':
        iconData = Icons.wb_sunny;
        color = Colors.yellow;
        break;
      case 'NIGHT_OWL':
        iconData = Icons.nightlight_round;
        color = Colors.indigo;
        break;
      case 'SPEED_DEMON':
        iconData = Icons.speed;
        color = Colors.red;
        break;
      case 'DEDICATED':
        iconData = Icons.emoji_events;
        color = Colors.purple;
        break;
      default:
        iconData = Icons.workspace_premium;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
