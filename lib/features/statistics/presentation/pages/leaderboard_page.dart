import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/stats_cubit.dart';
import '../cubit/stats_state.dart';
import '../widgets/leaderboard_card.dart';
import '../../domain/entities/stats_entity.dart';

/// Leaderboard Page - Display global ranking
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load both leaderboard and user stats to get current user info
    final cubit = context.read<StatsCubit>();
    await cubit.getLeaderboard();

    // Get current user stats to find their ID
    final userStatsResult = await cubit.getUserStatsUseCase();
    userStatsResult.fold(
      (error) => null,
      (stats) => setState(() => _currentUserId = stats.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StatsCubit, StatsState>(
        builder: (context, state) {
          if (state is StatsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StatsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LeaderboardLoaded) {
            final leaderboard = state.leaderboard;

            if (leaderboard.isEmpty) {
              return _buildEmptyState();
            }

            // Find current user's entry
            LeaderboardEntryEntity? currentUserEntry;
            if (_currentUserId != null) {
              try {
                currentUserEntry = leaderboard.firstWhere(
                  (entry) => entry.userId == _currentUserId,
                );
              } catch (_) {
                // User not in leaderboard
              }
            }

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, currentUserEntry),
                  _buildPodium(leaderboard),
                  _buildLeaderboardList(leaderboard, currentUserEntry),
                ],
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, LeaderboardEntryEntity? currentUser) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        // title: const Text(
        //   // 'Leaderboard',
        //   // style: TextStyle(
        //   //   fontWeight: FontWeight.bold,
        //   //   color: Colors.white,
        //   // ),
        // ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade700,
                Colors.deepPurple.shade900,
              ],
            ),
          ),
          child: currentUser != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      const Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Rank: #${currentUser.rank}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${currentUser.totalPoints} points',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntryEntity> leaderboard) {
    if (leaderboard.length < 3) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final top3 = leaderboard.take(3).toList();
    // Arrange as: 2nd, 1st, 3rd (podium style)
    final arranged = [
      if (top3.length > 1) top3[1], // 2nd place
      top3[0], // 1st place
      if (top3.length > 2) top3[2], // 3rd place
    ];

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        color: Colors.grey.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: arranged.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final height = index == 1 ? 140.0 : 110.0; // 1st place taller
            final actualRank = user.rank;

            return Expanded(
              child: _buildPodiumPlace(user, actualRank, height),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPodiumPlace(
      LeaderboardEntryEntity user, int rank, double height) {
    Color color;
    IconData icon = Icons.emoji_events;

    if (rank == 1) {
      color = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      color = const Color(0xFFC0C0C0); // Silver
    } else {
      color = const Color(0xFFCD7F32); // Bronze
    }

    return Column(
      children: [
        // Medal icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 8),
        // Username
        Text(
          user.username,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Points
        Text(
          '${user.totalPoints} pts',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        // Podium block
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntryEntity> leaderboard,
      LeaderboardEntryEntity? currentUser) {
    // Skip top 3 since they're in podium
    final remainingUsers = leaderboard.length > 3
        ? leaderboard.sublist(3)
        : <LeaderboardEntryEntity>[];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            // Header
            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.format_list_numbered, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Rank ${remainingUsers.isNotEmpty ? "4" : "1"} - ${leaderboard.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final user = remainingUsers[index - 1];
          final isCurrentUser =
              _currentUserId != null && user.userId == _currentUserId;

          return LeaderboardCard(
            entry: user,
            isCurrentUser: isCurrentUser,
          );
        },
        childCount: remainingUsers.length + 1,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No rankings yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start studying to appear on the leaderboard!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
