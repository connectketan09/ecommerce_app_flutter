import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:new_project/screens/login_screen.dart';
import 'package:new_project/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.diamond_outlined, // Changed to diamond for premium feel
              size: 80,
              color: AppColors.accent,
            ).animate().fade(duration: 800.ms).scale(delay: 200.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'LUXE MART',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.white,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 12),
            Text(
              'Premium Shopping Experience',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
