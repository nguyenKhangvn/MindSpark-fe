import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart';
import '../../core/api/services/auth_service.dart';
import '../../core/api/api_client.dart';

/// Example Login Screen to demonstrate API integration
/// This is a production-ready example with proper error handling
class ApiTestLoginScreen extends StatefulWidget {
  const ApiTestLoginScreen({super.key});

  @override
  State<ApiTestLoginScreen> createState() => _ApiTestLoginScreenState();
}

class _ApiTestLoginScreenState extends State<ApiTestLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    // Get service from dependency injection
    _authService = sl<AuthService>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
        _successMessage =
            'Login successful! Token: ${response.accessToken.substring(0, 20)}...';
      });
    } on UnauthorizedException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid credentials: $e';
      });
    } on TimeoutException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Request timeout: $e';
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'API Error: $e';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await _authService.healthCheck();

      setState(() {
        _isLoading = false;
        _successMessage =
            'Health Check OK: ${response['message'] ?? 'Service is healthy'}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Health check failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test - Login'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test API Integration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Backend: http://localhost:3000/api/v1',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Email field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // Login button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Test Login',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 12),

            // Health check button
            OutlinedButton(
              onPressed: _isLoading ? null : _testHealthCheck,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Test Health Check',
                style: TextStyle(fontSize: 16),
              ),
            ),

            // Success message
            if (_successMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
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
            ],

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Test instructions
            const Text(
              'Test Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInstruction('1. Make sure backend is running (port 3000)'),
            _buildInstruction(
                '2. Click "Test Health Check" to verify connection'),
            _buildInstruction('3. Enter email and password to test login'),
            _buildInstruction('4. Check success/error messages'),
            const SizedBox(height: 16),
            const Text(
              'Sample Test Data:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInstruction('Email: test@example.com'),
            _buildInstruction('Password: password123'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
