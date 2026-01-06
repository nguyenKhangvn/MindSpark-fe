import 'package:flutter/material.dart';
import '../../domain/entities/stats_entity.dart';

/// Leaderboard Entry Card Widget
class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntryEntity entry;
  final bool isCurrentUser;

  const LeaderboardCard({
    Key? key,
    required this.entry,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser ? Colors.blue.shade300 : Colors.grey.shade200,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildRankBadge(),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.username,
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                  color: isCurrentUser ? Colors.blue.shade900 : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: _buildPointsBadge(),
      ),
    );
  }

  Widget _buildRankBadge() {
    Color badgeColor;
    Widget? icon;

    // Top 3 get special medals
    if (entry.rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
      icon = const Icon(Icons.emoji_events, color: Colors.white, size: 20);
    } else if (entry.rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
      icon = const Icon(Icons.emoji_events, color: Colors.white, size: 18);
    } else if (entry.rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
      icon = const Icon(Icons.emoji_events, color: Colors.white, size: 18);
    } else {
      badgeColor = Colors.grey.shade400;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: entry.rank <= 3
            ? [
                BoxShadow(
                  color: badgeColor.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: icon ??
            Text(
              '#${entry.rank}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: entry.rank < 100 ? 14 : 12,
              ),
            ),
      ),
    );
  }

  Widget _buildPointsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '${entry.totalPoints}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
