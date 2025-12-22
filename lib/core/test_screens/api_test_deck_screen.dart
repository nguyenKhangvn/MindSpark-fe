import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart';
import '../../core/api/services/deck_service.dart';

/// Example Deck List Screen to demonstrate API integration
/// Shows how to fetch and display data from the backend
class ApiTestDeckScreen extends StatefulWidget {
  const ApiTestDeckScreen({super.key});

  @override
  State<ApiTestDeckScreen> createState() => _ApiTestDeckScreenState();
}

class _ApiTestDeckScreenState extends State<ApiTestDeckScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _decks = [];

  late final DeckService _deckService;

  @override
  void initState() {
    super.initState();
    _deckService = sl<DeckService>();
    _loadDecks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final decks = await _deckService.getDecks();
      setState(() {
        _decks = decks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load decks: $e';
      });
    }
  }

  Future<void> _createDeck() async {
    if (_titleController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Title is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _deckService.createDeck(
        name: _titleController.text,
        description: _descriptionController.text,
      );

      _titleController.clear();
      _descriptionController.clear();

      // Reload decks
      await _loadDecks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deck created successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to create deck: $e';
      });
    }
  }

  Future<void> _deleteDeck(String deckId) async {
    try {
      await _deckService.deleteDeck(deckId);
      await _loadDecks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deck deleted successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete deck: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test - Decks'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDecks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Create deck form
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create New Deck',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createDeck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Create Deck',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

          // Deck list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _decks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No decks found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first deck above',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _decks.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final deck = _decks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  deck['title'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                deck['title'] ?? 'Untitled',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (deck['description'] != null)
                                    Text(deck['description']),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cards: ${deck['cardCount'] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDeck(deck['id']),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
