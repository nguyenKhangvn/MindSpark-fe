class LeaderboardEntry {
  final String userId;
  final String username;
  final int totalPoints;
  final int cardsStudied;
  final int streak;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.totalPoints,
    required this.cardsStudied,
    required this.streak,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      totalPoints: json['totalPoints'] as int,
      cardsStudied: json['cardsStudied'] as int,
      streak: json['streak'] as int,
      rank: json['rank'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'totalPoints': totalPoints,
      'cardsStudied': cardsStudied,
      'streak': streak,
      'rank': rank,
    };
  }
}

class UserStats {
  final String userId;
  final int totalDecks;
  final int totalCards;
  final int cardsStudied;
  final int totalReviews;
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;
  final Map<String, int> achievements;

  UserStats({
    required this.userId,
    required this.totalDecks,
    required this.totalCards,
    required this.cardsStudied,
    required this.totalReviews,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.achievements,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String,
      totalDecks: json['totalDecks'] as int,
      totalCards: json['totalCards'] as int,
      cardsStudied: json['cardsStudied'] as int,
      totalReviews: json['totalReviews'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      totalPoints: json['totalPoints'] as int,
      achievements: Map<String, int>.from(json['achievements'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalDecks': totalDecks,
      'totalCards': totalCards,
      'cardsStudied': cardsStudied,
      'totalReviews': totalReviews,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalPoints': totalPoints,
      'achievements': achievements,
    };
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int points;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.points,
    required this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      points: json['points'] as int,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'points': points,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }
}

class Activity {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class DailyStats {
  final DateTime date;
  final int cardsReviewed;
  final int newCards;
  final int correctAnswers;
  final int totalTime; // in seconds
  final int points;

  DailyStats({
    required this.date,
    required this.cardsReviewed,
    required this.newCards,
    required this.correctAnswers,
    required this.totalTime,
    required this.points,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      cardsReviewed: json['cardsReviewed'] as int,
      newCards: json['newCards'] as int,
      correctAnswers: json['correctAnswers'] as int,
      totalTime: json['totalTime'] as int,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'cardsReviewed': cardsReviewed,
      'newCards': newCards,
      'correctAnswers': correctAnswers,
      'totalTime': totalTime,
      'points': points,
    };
  }
}
