// Forcing file re-analysis by Zapp (v3)
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
// Use relative imports for your own files
import 'task_list_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  // Helper to show a snackbar message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Handle user registration
  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage("Email and password cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    // Use email as username for simplicity, as required by the assignment
    final user = ParseUser.createUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _emailController.text.trim(), // Email
    );

    var response = await user.signUp();

    if (response.success) {
      // Registration successful, navigate to task list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskListPage()),
      );
    } else {
      // Show error message
      _showMessage(response.error!.message);
    }

    setState(() => _isLoading = false);
  }

  // Handle user login
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage("Email and password cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    final user = ParseUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      null, // Email is not needed for login, only username/password
    );

    var response = await user.login();

    if (response.success) {
      // Login successful, navigate to task list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaskListPage()),
      );
    } else {
      // Show error message
      _showMessage(response.error!.message);
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Task Manager',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              // Main Action Button (Login or Register)
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isLoginMode ? _handleLogin : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isLoginMode ? 'Login' : 'Register'),
                    ),
              const SizedBox(height: 16),
              // Toggle Button
              TextButton(
                onPressed: _isLoading ? null : _toggleMode,
                child: Text(
                  _isLoginMode
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
