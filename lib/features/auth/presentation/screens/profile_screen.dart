import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../statistics/presentation/cubit/stats_cubit.dart';
import '../../../statistics/presentation/cubit/stats_state.dart';
import '../../../deck/presentation/cubit/deck_cubit.dart';
import '../../../deck/presentation/cubit/deck_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    // Get user profile
    context.read<AuthCubit>().getProfile();

    // Get user stats
    final authState = context.read<AuthCubit>().state;
    String? userId;

    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    } else if (authState is ProfileLoaded) {
      userId = authState.user.id;
    }

    if (userId != null) {
      context.read<StatsCubit>().getUserStats();
    }

    // Get decks to count total
    context.read<DeckCubit>().getDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Navigate to login after logout
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.login,
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          String username = 'User';
          String email = 'user@example.com';

          if (authState is AuthAuthenticated) {
            username = authState.user.name;
            email = authState.user.email;
          } else if (authState is ProfileLoaded) {
            username = authState.user.name;
            email = authState.user.email;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header - Real data
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Cards - Real data from backend
                BlocBuilder<StatsCubit, StatsState>(
                  builder: (context, statsState) {
                    return BlocBuilder<DeckCubit, DeckState>(
                      builder: (context, deckState) {
                        int totalCards = 0;
                        int streak = 0;
                        int totalDecks = 0;

                        if (statsState is UserStatsLoaded) {
                          totalCards = statsState.stats.totalCards;
                          streak = statsState.stats.streak;
                        }

                        if (deckState is DecksLoaded) {
                          totalDecks = deckState.decks.length;
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.school_outlined,
                                value: '$totalCards',
                                label: 'Cards\nLearned',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.local_fire_department,
                                value: '$streak',
                                label: 'Day\nStreak',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.folder_outlined,
                                value: '$totalDecks',
                                label: 'Total\nDecks',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.workspace_premium,
                  title: 'Upgrade to Premium',
                  subtitle: 'Unlock all features',
                  color: AppColors.secondary,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Premium feature coming soon')),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Edit profile feature coming soon')),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: 'Study History',
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.statistics);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help feature coming soon')),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('MindSpark'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A powerful flashcard learning app'),
            SizedBox(height: 8),
            Text('Built with Flutter & Clean Architecture'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
