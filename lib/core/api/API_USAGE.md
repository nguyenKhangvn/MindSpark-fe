# API Integration Guide

## Setup

### 1. Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### 2. Initialize API Provider

In your `main.dart`:

```dart
import 'package:mindspark/core/api/api_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Provider
  final apiProvider = ApiServiceProvider();
  await apiProvider.initialize();

  runApp(MyApp(apiProvider: apiProvider));
}

class MyApp extends StatelessWidget {
  final ApiServiceProvider apiProvider;

  const MyApp({Key? key, required this.apiProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ApiProvider(
      apiProvider: apiProvider,
      child: MaterialApp(
        title: 'MindSpark',
        home: HomePage(),
      ),
    );
  }
}
```

## Usage Examples

### Authentication

```dart
import 'package:mindspark/core/api/api_provider.dart';

class LoginScreen extends StatelessWidget {
  Future<void> _login(BuildContext context) async {
    final api = ApiProvider.of(context);

    try {
      final response = await api.auth.login(
        email: 'test@example.com',
        password: 'password123',
      );

      print('Logged in: ${response.user.username}');
      print('Token: ${response.accessToken}');

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } on UnauthorizedException catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    } catch (e) {
      print('Error: $e');
    }
  }
}
```

### Register New User

```dart
Future<void> _register(BuildContext context) async {
  final api = ApiProvider.of(context);

  try {
    final response = await api.auth.register(
      email: 'newuser@example.com',
      password: 'SecurePass123',
      username: 'newuser',
    );

    print('Registered: ${response.user.username}');

    // Navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    print('Registration failed: $e');
  }
}
```

### Get User Profile

```dart
Future<void> _loadProfile(BuildContext context) async {
  final api = ApiProvider.of(context);

  try {
    final user = await api.auth.getProfile();

    print('User: ${user.username} (${user.email})');
  } catch (e) {
    print('Failed to load profile: $e');
  }
}
```

### Logout

```dart
Future<void> _logout(BuildContext context) async {
  final api = ApiProvider.of(context);

  try {
    await api.auth.logout();

    // Navigate to login
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    print('Logout failed: $e');
  }
}
```

### Create a Deck

```dart
Future<void> _createDeck(BuildContext context) async {
  final api = ApiProvider.of(context);

  try {
    final deck = await api.decks.createDeck(
      name: 'Japanese Vocabulary',
      description: 'N5 Level Words',
      language: 'ja',
      isPublic: false,
    );

    print('Deck created: ${deck.id}');
    print('Name: ${deck.name}');
  } catch (e) {
    print('Failed to create deck: $e');
  }
}
```

### Get All Decks

```dart
Future<List<Deck>> _loadDecks(BuildContext context) async {
  final api = ApiProvider.of(context);

  try {
    final decks = await api.decks.getDecks();

    print('Loaded ${decks.length} decks');
    return decks;
  } catch (e) {
    print('Failed to load decks: $e');
    return [];
  }
}
```

### Create Flashcard

```dart
Future<void> _createCard(BuildContext context, String deckId) async {
  final api = ApiProvider.of(context);

  try {
    final card = await api.cards.createCard(
      deckId: deckId,
      front: 'こんにちは',
      back: 'Hello',
      kanji: '今日は',
    );

    print('Card created: ${card.id}');
  } catch (e) {
    print('Failed to create card: $e');
  }
}
```

### Get Due Cards for Study

```dart
Future<List<DueCard>> _getDueCards(BuildContext context, {String? deckId}) async {
  final api = ApiProvider.of(context);

  try {
    final dueCards = await api.study.getDueCards(deckId: deckId);

    print('${dueCards.length} cards due for review');
    return dueCards;
  } catch (e) {
    print('Failed to get due cards: $e');
    return [];
  }
}
```

### Review a Card

```dart
Future<void> _reviewCard(
  BuildContext context,
  String cardId,
  int quality, // 0-5
) async {
  final api = ApiProvider.of(context);

  try {
    final result = await api.study.reviewCard(
      cardId: cardId,
      quality: quality,
    );

    print('Next review: ${result.nextReview}');
    print('Interval: ${result.interval} days');
  } catch (e) {
    print('Failed to review card: $e');
  }
}
```

### Get Leaderboard

```dart
Future<List<LeaderboardEntry>> _loadLeaderboard(BuildContext context) async {
  final api = ApiProvider.of(context);

  try {
    final leaderboard = await api.stats.getLeaderboard(limit: 100);

    for (var entry in leaderboard) {
      print('#${entry.rank}: ${entry.username} - ${entry.totalPoints} pts');
    }

    return leaderboard;
  } catch (e) {
    print('Failed to load leaderboard: $e');
    return [];
  }
}
```

### Get User Statistics

```dart
Future<UserStats> _loadUserStats(BuildContext context, String userId) async {
  final api = ApiProvider.of(context);

  try {
    final stats = await api.stats.getUserStats(userId);

    print('Total decks: ${stats.totalDecks}');
    print('Cards studied: ${stats.cardsStudied}');
    print('Current streak: ${stats.currentStreak} days');

    return stats;
  } catch (e) {
    print('Failed to load stats: $e');
    rethrow;
  }
}
```

## Error Handling

All API calls can throw the following exceptions:

- `ApiException` - General API error
- `UnauthorizedException` - 401 Unauthorized (token expired/invalid)
- `NotFoundException` - 404 Resource not found
- `TimeoutException` - 504 Gateway timeout

Example error handling:

```dart
try {
  final result = await api.someMethod();
  // Handle success
} on UnauthorizedException catch (e) {
  // Redirect to login
  Navigator.pushReplacementNamed(context, '/login');
} on TimeoutException catch (e) {
  // Show timeout message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Request timed out. Please try again.')),
  );
} on ApiException catch (e) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.message}')),
  );
} catch (e) {
  // Handle unknown errors
  print('Unexpected error: $e');
}
```

## Configuration

### Change API URL

Edit `lib/core/api/api_client.dart`:

```dart
static const String baseUrl = 'https://your-api.com/api/v1';
```

For environment-specific URLs:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000/api/v1',
);
```

Then run with:

```bash
flutter run --dart-define=API_URL=https://your-api.com/api/v1
```

## Complete Example: Study Session

```dart
class StudySessionScreen extends StatefulWidget {
  final String deckId;

  const StudySessionScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  _StudySessionScreenState createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> {
  List<DueCard> _dueCards = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDueCards();
  }

  Future<void> _loadDueCards() async {
    final api = ApiProvider.of(context);

    try {
      final cards = await api.study.getDueCards(deckId: widget.deckId);
      setState(() {
        _dueCards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cards: $e')),
      );
    }
  }

  Future<void> _reviewCard(int quality) async {
    if (_currentIndex >= _dueCards.length) return;

    final api = ApiProvider.of(context);
    final card = _dueCards[_currentIndex];

    try {
      await api.study.reviewCard(
        cardId: card.id,
        quality: quality,
      );

      setState(() {
        _currentIndex++;
      });

      if (_currentIndex >= _dueCards.length) {
        // Session complete
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_dueCards.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No cards due for review!')),
      );
    }

    final card = _dueCards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Study Session (${_currentIndex + 1}/${_dueCards.length})'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.front,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              card.back,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _reviewCard(0),
                  child: Text('Again'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: () => _reviewCard(3),
                  child: Text('Good'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: () => _reviewCard(5),
                  child: Text('Easy'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```
