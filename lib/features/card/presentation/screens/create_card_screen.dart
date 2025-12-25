import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/card_cubit.dart';
import '../cubit/card_state.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _kanjiController = TextEditingController(); // Thêm controller cho kanji

  // Helper method để lấy deckId từ route arguments
  String? get _deckId {
    final args = ModalRoute.of(context)?.settings.arguments;
    print(
        'DEBUG: Route arguments - Type: ${args.runtimeType}, Value: $args'); // Debug
    if (args is String) {
      return args;
    }
    return null;
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _kanjiController.dispose(); // Dispose kanji controller
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final deckId = _deckId;
      print('DEBUG: Saving card with deckId: $deckId'); // Debug log

      if (deckId == null || deckId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No deck selected'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Call API to save card via Cubit
      final kanjiText = _kanjiController.text.trim();
      context.read<CardCubit>().createCard(
            deckId: deckId,
            front: _frontController.text.trim(),
            back: _backController.text.trim(),
            kanji: kanjiText.isNotEmpty ? kanjiText : null, // Gửi kanji nếu có
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Card'),
        actions: [
          BlocBuilder<CardCubit, CardState>(
            builder: (context, state) {
              final isLoading = state is CardLoading;
              return TextButton(
                onPressed: isLoading ? null : _handleSave,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: BlocListener<CardCubit, CardState>(
        listener: (context, state) {
          if (state is CardCreated) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card created successfully!')),
            );
          } else if (state is CardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kanji (Optional - For Japanese)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _kanjiController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Enter kanji if applicable (e.g., 漢字)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}), // Trigger preview update
                ),

                const SizedBox(height: 24),

                Text(
                  'Front Side (Question)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _frontController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter the question or term (e.g., かんじ)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the front side';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}), // Trigger preview update
                ),

                const SizedBox(height: 24),

                Text(
                  'Back Side (Answer)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _backController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Enter the answer or meaning (e.g., Hola)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the back side';
                    }
                    return null;
                  },
                  onChanged: (_) => setState(() {}), // Trigger preview update
                ),

                const SizedBox(height: 24),

                // TODO: Image Picker Button (future enhancement)
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image upload coming soon')),
                    );
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Add Image (Coming Soon)'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

                const SizedBox(height: 32),

                // Preview Section
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildPreviewCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final hasKanji = _kanjiController.text.trim().isNotEmpty;
    final frontText = _frontController.text.trim();
    final kanjiText = _kanjiController.text.trim();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiển thị Kanji nếu có
          if (hasKanji) ...[
            Text(
              kanjiText,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          // Hiển thị Front (Hiragana/Katakana)
          Text(
            frontText.isEmpty ? 'Front Side' : frontText,
            style: TextStyle(
              fontSize: hasKanji ? 20 : 24,
              fontWeight: hasKanji ? FontWeight.w500 : FontWeight.bold,
              color: frontText.isEmpty
                  ? Colors.grey[400]
                  : (hasKanji ? AppColors.textSecondary : AppColors.primary),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            _backController.text.trim().isEmpty
                ? 'Back Side'
                : _backController.text.trim(),
            style: TextStyle(
              fontSize: 20,
              color: _backController.text.trim().isEmpty
                  ? Colors.grey[400]
                  : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
