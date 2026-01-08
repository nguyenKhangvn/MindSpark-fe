import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import 'cubit/stats_cubit.dart';
import 'cubit/stats_state.dart';
import '../domain/entities/stats_entity.dart';
import '../domain/entities/weekly_progress_entity.dart';
import 'pages/leaderboard_page.dart';
import 'pages/achievements_page.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStatistics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh stats when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadStatistics();
    }
  }

  void _loadStatistics() {
    // Load stats + analytics in one state to avoid overwriting UI
    context.read<StatsCubit>().loadOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
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
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStatistics,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is StatsOverviewLoaded) {
            final stats = state.stats;
            final weeklyProgress = state.weeklyProgress;
            final totalThisWeek = weeklyProgress.fold<int>(
              0,
              (sum, day) => sum + day.cardsStudied,
            );
            const weeklyGoal = 200; // simple default goal
            final weeklyProgressPct =
                (totalThisWeek / weeklyGoal).clamp(0.0, 1.0).toDouble();

            return RefreshIndicator(
              onRefresh: () async => _loadStatistics(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderStats(context, stats),
                    const SizedBox(height: 16),

                    // Leaderboard & Achievements quick access
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            context,
                            title: 'Leaderboard',
                            subtitle: 'Global Ranking',
                            icon: Icons.leaderboard,
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => sl<StatsCubit>(),
                                    child: const LeaderboardPage(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            context,
                            title: 'Achievements',
                            subtitle: 'My Badges',
                            icon: Icons.emoji_events,
                            color: Colors.amber,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AchievementsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Learning progress summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learning Progress',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalThisWeek / $weeklyGoal cards this week',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: weeklyProgressPct,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      'Weekly Progress',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(context, weeklyProgress),
                    const SizedBox(height: 24),

                    Text(
                      'Study Activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildActivityHeatmap(context, state.activityHeatmap),
                    const SizedBox(height: 24),

                    Text(
                      'Top Performing Decks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildTopDecks(context, state.topDecks),
                  ],
                ),
              ),
            );
          }

          // If user isn't logged in yet (or not loaded), show a friendly hint
          return const Center(child: Text('No statistics available'));
        },
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context, UserStatsEntity stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Cards Learned',
                value: '${stats.cardsMastered}',
                color: AppColors.easy,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Accuracy',
                value: '${(stats.accuracy * 100).toInt()}%',
                color: AppColors.primary,
                icon: Icons.workspace_premium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: '🔥 Day Streak',
                value: '${stats.streak}',
                color: Colors.orange,
                icon: Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Total Points',
                value: '${stats.totalPoints}',
                color: Colors.purple,
                icon: Icons.stars,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(
      BuildContext context, List<WeeklyProgressEntity> weeklyData) {
    if (weeklyData.isEmpty) {
      return _buildPlaceholder('No data for this week');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: weeklyData.map((day) {
          final parts = day.date.split('-');
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          final dayName = [
            'Mon',
            'Tue',
            'Wed',
            'Thu',
            'Fri',
            'Sat',
            'Sun'
          ][date.weekday - 1];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    dayName,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (day.cardsStudied / 50).clamp(0.0, 1.0),
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '${day.cardsStudied} cards',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${day.accuracy.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: day.accuracy >= 80 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityHeatmap(
      BuildContext context, List<ActivityHeatmapEntity> heatmapData) {
    if (heatmapData.isEmpty) {
      return _buildPlaceholder('No activity data yet');
    }

    // Group by weeks (show last 12 weeks)
    final last90Days = heatmapData.take(90).toList();
    final weeks = <List<ActivityHeatmapEntity>>[];

    for (int i = 0; i < last90Days.length; i += 7) {
      weeks.add(last90Days.skip(i).take(7).toList());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last 90 days',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: weeks.map((week) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Column(
                    children: week.map((day) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getHeatmapColor(day.intensity),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Less',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(width: 4),
              ...List.generate(
                  5,
                  (i) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getHeatmapColor(i),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      )),
              const SizedBox(width: 4),
              const Text('More',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(int intensity) {
    switch (intensity) {
      case 0:
        return Colors.grey[200]!;
      case 1:
        return AppColors.primary.withOpacity(0.2);
      case 2:
        return AppColors.primary.withOpacity(0.4);
      case 3:
        return AppColors.primary.withOpacity(0.6);
      case 4:
        return AppColors.primary;
      default:
        return Colors.grey[200]!;
    }
  }

  Widget _buildTopDecks(BuildContext context, List<TopDeckEntity> topDecks) {
    if (topDecks.isEmpty) {
      return _buildPlaceholder('No deck performance data yet');
    }

    return Column(
      children: topDecks.map((deck) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deck.deckName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: deck.accuracy >= 80 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${deck.accuracy.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDeckStat(
                      'Cards', '${deck.cardsStudied}', Icons.credit_card),
                  const SizedBox(width: 16),
                  _buildDeckStat(
                      'Correct', '${deck.correctAnswers}', Icons.check_circle),
                  //   const SizedBox(width: 16),
                  //   _buildDeckStat(
                  //       'Time', '${deck.studyTimeMinutes}m', Icons.access_time),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeckStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // TODO: Remove these methods once backend provides detailed analytics
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.7),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildWeeklyChart(BuildContext context) {
    ...
  }

  Widget _buildActivityHeatmap(BuildContext context) {
    ...
  }

  Color _getHeatmapColor(int intensity) {
    ...
  }

  Widget _buildTopDecks(BuildContext context) {
    ...
  }
  */
}
