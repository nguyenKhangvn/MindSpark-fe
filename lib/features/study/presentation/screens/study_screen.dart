import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/di/injection_container.dart';
import '../cubit/study_cubit.dart';
import '../cubit/study_state.dart';
import '../../domain/entities/study_entity.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int currentCardIndex = 0;
  bool isFlipped = false;
  List<StudyEntity>? dueCards;
  final TtsService _ttsService = sl<TtsService>();

  @override
  void initState() {
    super.initState();
    // Fetch due cards from backend
    context.read<StudyCubit>().getDueCards();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  void _handleRating(int quality) {
    if (dueCards == null || dueCards!.isEmpty) return;

    final currentCard = dueCards![currentCardIndex];

    // Send review to backend (quality 0-5 for SM-2 algorithm)
    context.read<StudyCubit>().reviewCard(currentCard.card.id, quality);

    setState(() {
      if (currentCardIndex < dueCards!.length - 1) {
        currentCardIndex++;
        isFlipped = false;
      } else {
        // Session complete
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Study Session Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'You reviewed ${dueCards?.length ?? 0} cards',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<StudyCubit, StudyState>(
        listener: (context, state) {
          if (state is CardReviewed) {
            // Card reviewed successfully - UI already updated via setState
          } else if (state is StudyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StudyLoading && dueCards == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Loading...'),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is StudyError && dueCards == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Error'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StudyCubit>().getDueCards();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DueCardsLoaded) {
            dueCards = state.dueCards;
          }

          if (dueCards == null || dueCards!.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Study'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No cards due for review',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Come back later!',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          final totalCards = dueCards!.length;
          final currentCard = dueCards![currentCardIndex];

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('${currentCardIndex + 1}/$totalCards'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (currentCardIndex + 1) / totalCards,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              ),
            ),
            body: Column(
              children: [
                const Spacer(),

                // Flashcard
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isFlipped = !isFlipped;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCard(context, currentCard),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Hint or Rating Buttons
                if (!isFlipped)
                  const Text(
                    'Tap to reveal answer',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  )
                else
                  _buildRatingButtons(),

                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, StudyEntity studyCard) {
    final card = studyCard.card;

    return Container(
      key: ValueKey(isFlipped),
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isFlipped) ...[
            // Front side - Question với Kanji (nếu có)
            if (card.kanji != null && card.kanji!.isNotEmpty) ...[
              // Hiển thị Kanji (chữ chính)
              Text(
                card.kanji!,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Hiển thị Hiragana/Katakana (cách đọc) nhỏ hơn
              Text(
                card.front,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // Nếu không có Kanji, chỉ hiển thị front (Hiragana/Katakana)
              Text(
                card.front,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 32),
              onPressed: () {
                // Text-to-Speech tiếng Nhật - đọc từ front (cách đọc)
                _ttsService.speakJapanese(card.front);
              },
              color: AppColors.primary,
            ),
          ] else ...[
            // Back side - Answer
            Text(
              card.back,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 28),
                  onPressed: () {
                    // Text-to-Speech tiếng Việt
                    _ttsService.speakVietnamese(card.back);
                  },
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildRatingButton(
            label: 'Again',
            color: AppColors.hard,
            icon: Icons.close,
            onTap: () => _handleRating(1), // Quality 0 - Complete blackout
          ),
          const SizedBox(width: 8),
          _buildRatingButton(
            label: 'Hard',
            color: AppColors.medium,
            icon: Icons.sentiment_neutral,
            onTap: () =>
                _handleRating(2), // Quality 2 - Incorrect but easy recall
          ),
          const SizedBox(width: 8),
          _buildRatingButton(
            label: 'Good',
            color: AppColors.primary,
            icon: Icons.sentiment_satisfied,
            onTap: () =>
                _handleRating(3), // Quality 4 - Correct after hesitation
          ),
          const SizedBox(width: 8),
          _buildRatingButton(
            label: 'Easy',
            color: AppColors.easy,
            icon: Icons.sentiment_very_satisfied,
            onTap: () => _handleRating(4), // Quality 5 - Perfect response
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
