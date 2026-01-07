import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
// Đảm bảo các đường dẫn import này đúng với project của bạn
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_router.dart';
import '../../deck/presentation/cubit/deck_cubit.dart';
import '../../deck/presentation/cubit/deck_state.dart';
import '../../statistics/presentation/cubit/stats_cubit.dart';
import '../../statistics/presentation/cubit/stats_state.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// ĐÂY LÀ CLASS BẠN ĐANG TÌM:
class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    // 1. Load danh sách Deck
    context.read<DeckCubit>().getDecks();

    // 2. Load Stats - chỉ load nếu chưa có data (cache-first)
    final statsState = context.read<StatsCubit>().state;
    if (statsState is! UserStatsLoaded) {
      context.read<StatsCubit>().getUserStats();
    }
  }

  // --- [LOGIC MỚI] Hàm hiển thị Dialog tạo Deck ---
  void _showCreateDeckDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để đẩy lên khi bàn phím hiện
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Deck',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // Input Name
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Deck Name',
                    hintText: 'e.g., Japanese N5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.folder),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a deck name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Description
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Describe your deck...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Gọi Cubit để tạo Deck
                          // LƯU Ý: Đảm bảo DeckCubit có hàm createDeck
                          context.read<DeckCubit>().createDeck(
                                name: nameController.text.trim(),
                                description: descController.text.trim(),
                              );

                          // Tạm thời log ra console nếu chưa có hàm createDeck
                          print("Create deck: ${nameController.text}");

                          Navigator.pop(ctx);
                          // Refresh lại list sau khi tạo (nếu cần)
                          _loadDashboardData();
                        }
                      },
                      child: const Text('Create'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? _buildHomeTab(context)
          : _currentIndex == 1
              ? _buildStatsTab(context)
              : _buildProfileTab(context),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // debugger();
                Navigator.pushNamed(context, AppRouter.ocrResult);
              },
              backgroundColor: AppColors.secondary,
              icon: const Icon(Icons.camera_alt, color: Colors.black87),
              label: const Text(
                'Scan',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // 1. Header with profile
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // 2. [MỚI] Tiêu đề "My Decks" và nút (+)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Decks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  IconButton(
                    onPressed: () => _showCreateDeckDialog(context),
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.primary, size: 28),
                    tooltip: 'Create New Deck',
                  ),
                ],
              ),
            ),
          ),

          // 3. Danh sách Decks
          BlocBuilder<DeckCubit, DeckState>(
            builder: (context, deckState) {
              if (deckState is DeckLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (deckState is DeckError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${deckState.message}',
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDashboardData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (deckState is DecksLoaded) {
                if (deckState.decks.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No decks yet',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          // Nút tạo deck khi danh sách trống
                          ElevatedButton.icon(
                            onPressed: () => _showCreateDeckDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first Deck'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  // 1. Cộng thêm 80px vào bottom để thay thế cho SizedBox
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 16 + 80, // 16 padding gốc + 80 khoảng trống cho FAB
                  ),

                  // 2. Dùng thuộc tính 'sliver' (số ít) thay vì 'slivers'
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDeckCard(
                        context,
                        deckState.decks[index],
                      ),
                      childCount: deckState.decks.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    return const Center(child: Text('Statistics - Navigate to full screen'));
  }

  Widget _buildProfileTab(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, AppRouter.profile);
      setState(() {
        _currentIndex = 0;
      });
    });
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              String username = 'User';
              if (authState is AuthAuthenticated) {
                username = authState.user.name;
              } else if (authState is ProfileLoaded) {
                username = authState.user.name;
              }

              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),

          // Streak info
          Expanded(
            child: BlocBuilder<StatsCubit, StatsState>(
              builder: (context, statsState) {
                if (statsState is UserStatsLoaded) {
                  final stats = statsState.stats;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              color: Color(0xFFFF6B00), size: 24),
                          const SizedBox(width: 4),
                          Text(
                            '${stats.streak} Day Streak',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: AppColors.textPrimary, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.cardsMastered} cards learned',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Color(0xFFFF6B00), size: 24),
                        const SizedBox(width: 4),
                        Text(
                          'Loading...',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: AppColors.textPrimary, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCard(BuildContext context, dynamic deck) {
    final deckEntity = deck;
    final progress = deckEntity.cardCount > 0 ? 0.0 : 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.deckDetail,
            arguments: deckEntity,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder_outlined,
                    color: AppColors.primary, size: 28),
              ),
              const Spacer(),
              Text(
                deckEntity.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${deckEntity.cardCount} cards',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // const SizedBox(height: 12),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     LinearProgressIndicator(
              //       value: progress,
              //       backgroundColor: Colors.grey[200],
              //       color: AppColors.primary,
              //       minHeight: 6,
              //       borderRadius: BorderRadius.circular(3),
              //     ),
              //     // const SizedBox(height: 4),
              //     // Text(
              //     //   '${(progress * 100).toInt()}% mastered',
              //     //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //     //         fontSize: 11,
              //     //         color: AppColors.textSecondary,
              //     //       ),
              //     // ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, AppRouter.statistics);
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
