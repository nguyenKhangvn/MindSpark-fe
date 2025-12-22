import 'package:flutter/material.dart';
import 'api_test_login_screen.dart';
import 'api_test_deck_screen.dart';

/// Main test screen to access all API test screens
class ApiTestHomeScreen extends StatelessWidget {
  const ApiTestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindSpark API Tests'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backend Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Base URL: http://localhost:3000/api/v1'),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 12, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Make sure backend services are running'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Tests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Auth Service Test
          _TestCard(
            title: 'Authentication Service',
            description: 'Test login, register, and health check endpoints',
            icon: Icons.login,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApiTestLoginScreen(),
                ),
              );
            },
          ),

          // Deck Service Test
          _TestCard(
            title: 'Deck Service',
            description: 'Test CRUD operations for decks',
            icon: Icons.folder,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApiTestDeckScreen(),
                ),
              );
            },
          ),

          // Card Service Test
          _TestCard(
            title: 'Card Service',
            description: 'Test flashcard management (coming soon)',
            icon: Icons.credit_card,
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),

          // Study Service Test
          _TestCard(
            title: 'Study Service',
            description: 'Test study sessions and reviews (coming soon)',
            icon: Icons.school,
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),

          // Stats Service Test
          _TestCard(
            title: 'Stats Service',
            description: 'Test statistics and leaderboard (coming soon)',
            icon: Icons.bar_chart,
            color: Colors.red,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TestCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
