import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindspark/features/card/domain/entities/card_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/app_router.dart';
import '../cubit/deck_cubit.dart';
import '../cubit/deck_state.dart';
import '../../domain/entities/deck_entity.dart';
import '../../../card/presentation/cubit/card_cubit.dart';
import '../../../card/presentation/cubit/card_state.dart';

class DeckDetailScreen extends StatefulWidget {
  const DeckDetailScreen({super.key});

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  DeckEntity? _deck;
  // FIX: Thêm cờ đánh dấu để tránh gọi API nhiều lần
  bool _isDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // FIX: Chỉ load data nếu chưa load lần nào
    if (!_isDataLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is DeckEntity) {
        _deck = args;
        // Fetch cards for this deck
        context.read<CardCubit>().getCards(_deck!.id);
      }
      _isDataLoaded = true; // Đánh dấu đã load xong
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no deck provided, show error
    if (_deck == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deck Detail')),
        body: const Center(
          child: Text('No deck data provided'),
        ),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Signal dashboard to refresh when popping
        if (didPop) {
          // Already popped, can't do anything
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Pop with refresh signal
              Navigator.of(context).pop(true);
            },
          ),
          title: Text(_deck!.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                _showEditDeckDialog(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showDeleteDeckDialog(context);
              },
            ),
          ],
        ),
        body: BlocListener<DeckCubit, DeckState>(
          listener: (context, state) {
            if (state is DeckDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.of(context).pop(); // Go back after deletion
            } else if (state is DeckError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocListener<CardCubit, CardState>(
            listener: (context, cardState) {
              if (cardState is CardUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật thẻ thành công!')),
                );
              } else if (cardState is CardDeleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa thẻ!')),
                );
              } else if (cardState is CardError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cardState.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Column(
              children: [
                // Deck Info Header
                BlocBuilder<CardCubit, CardState>(
                  builder: (context, cardState) {
                    int totalCards = _deck!.cardCount;

                    if (cardState is CardsLoaded && cardState.summary != null) {
                      totalCards = cardState.summary!.total;
                    } else if (cardState is CardUpdated &&
                        cardState.summary != null) {
                      totalCards = cardState.summary!.total;
                    } else if (cardState is CardDeleted &&
                        cardState.summary != null) {
                      totalCards = cardState.summary!.total;
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$totalCards',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Total Cards',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Navigate to study and wait for result
                                    final shouldRefresh =
                                        await Navigator.pushNamed(
                                      context,
                                      AppRouter.study,
                                      arguments: _deck!.id,
                                    );

                                    // Refresh cards if study session completed
                                    if (shouldRefresh == true && mounted) {
                                      context
                                          .read<CardCubit>()
                                          .getCards(_deck!.id);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Study Now'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.createCard,
                                      arguments: _deck!.id,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Card'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Card List
                Expanded(
                  child: BlocBuilder<CardCubit, CardState>(
                    builder: (context, cardState) {
                      if (cardState is CardLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (cardState is CardError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${cardState.message}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<CardCubit>().getCards(_deck!.id);
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      List<CardEntity> cards = [];

                      if (cardState is CardsLoaded) {
                        cards = cardState.cards;
                      } else if (cardState is CardUpdated) {
                        cards = cardState.allCards;
                      } else if (cardState is CardDeleted) {
                        cards = cardState.remainingCards;
                      }

                      if (cards.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.credit_card_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No cards yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add cards to start learning',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.createCard,
                                    arguments: _deck!.id,
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Card'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          return _buildCardItem(context, cards[index], index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, dynamic card, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        title: Text(card.front),
        subtitle: Text(card.back),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            _showCardOptionsMenu(context, card);
          },
        ),
        onTap: () {
          _showCardPreview(context, card);
        },
      ),
    );
  }

  void _showEditDeckDialog(BuildContext context) {
    final nameController = TextEditingController(text: _deck!.name);
    final descController = TextEditingController(text: _deck!.description);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Deck'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Deck Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DeckCubit>().updateDeck(
                    id: _deck!.id,
                    name: nameController.text,
                    description: descController.text,
                  );
              // Update local deck info immediately for UI
              setState(() {
                _deck = DeckEntity(
                  id: _deck!.id,
                  name: nameController.text,
                  description: descController.text,
                  userId: _deck!.userId,
                  cardCount: _deck!.cardCount,
                  language: _deck!.language,
                  imageUrl: _deck!.imageUrl,
                  isPublic: _deck!.isPublic,
                  createdAt: _deck!.createdAt,
                  updatedAt: _deck!.updatedAt,
                );
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDeckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${_deck!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DeckCubit>().deleteDeck(_deck!.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCardOptionsMenu(BuildContext context, dynamic card) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Card'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showEditCardDialog(context, card);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Card',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(sheetContext);
                _showDeleteCardDialog(context, card);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCardDialog(BuildContext context, dynamic card) {
    final frontController = TextEditingController(text: card.front);
    final backController = TextEditingController(text: card.back);
    final kanjiController = TextEditingController(text: card.kanji ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kanjiController,
                decoration: const InputDecoration(
                  labelText: 'Kanji (Optional)',
                  hintText: 'e.g., 漢字',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: frontController,
                decoration: const InputDecoration(
                  labelText: 'Front (Reading)',
                  hintText: 'e.g., かんじ',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backController,
                decoration: const InputDecoration(
                  labelText: 'Back (Meaning)',
                  hintText: 'e.g., Chữ Hán',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final kanjiText = kanjiController.text.trim();
              context.read<CardCubit>().updateCard(
                    cardId: card.id,
                    front: frontController.text.trim(),
                    back: backController.text.trim(),
                    kanji: kanjiText.isEmpty ? null : kanjiText,
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCardDialog(BuildContext context, dynamic card) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text(
            'Are you sure you want to delete this card?\n\n"${card.front}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CardCubit>().deleteCard(card.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCardPreview(BuildContext context, dynamic card) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Front',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                card.front,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              const Text(
                'Back',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                card.back,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
