import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/screens/home_screen.dart';
import 'package:new_project/services/api_service.dart';
import 'package:new_project/utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'john@mail.com'); // Default for testing
  final _passwordController = TextEditingController(text: 'changeme'); // Default for testing
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For academic project/demo, assuming login gives us a token and we go to home
      // In a real app we'd save the token.
      final token = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(accessToken: token)), // Passing token simply
      ); // Pass token or manage user session
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Allow stretching for specific items or wrap in Center
              children: [
                const Icon(
                  Icons.diamond_outlined,
                  size: 60,
                  color: AppColors.primary,
                ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your shopping journey',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 48),

                // Form
                Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ).animate().fadeIn(delay: 400.ms).moveX(begin: -20, end: 0),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ).animate().fadeIn(delay: 500.ms).moveX(begin: -20, end: 0),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),

                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().shake(),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Login'),
                ).animate().fadeIn(delay: 700.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                    GestureDetector( // Using GestureDetector for text link behavior 
                      onTap: () {},
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
