import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _auth.signIn(_emailController.text, _passwordController.text);
      } else {
        await _auth.signUp(_emailController.text, _passwordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Sign up successful! Please check your email or login.')),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An unexpected error occurred')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.5 + _glowController.value * 0.3,
                      -0.3 + _glowController.value * 0.2,
                    ),
                    radius: 1.8,
                    colors: [
                      NebulaColors.accentPurple.withOpacity(0.15),
                      NebulaColors.bgDeep,
                      NebulaColors.bgDeep,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          // Subtle stars/dots
          ...List.generate(30, (i) {
            final rng = Random(i);
            return Positioned(
              left: rng.nextDouble() * 600,
              top: rng.nextDouble() * 800,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, _) {
                  final opacity = 0.1 +
                      0.4 * sin(_glowController.value * pi + i * 0.5).abs();
                  return Container(
                    width: 2 + rng.nextDouble() * 2,
                    height: 2 + rng.nextDouble() * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NebulaColors.accentCyan.withOpacity(opacity),
                    ),
                  );
                },
              ),
            );
          }),

          // Login card
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: NebulaColors.bgCard.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: NebulaColors.accentPurple.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NebulaColors.accentPurple.withOpacity(0.08),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo area
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              NebulaColors.accentPurple,
                              NebulaColors.accentCyan,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: NebulaColors.accentPurple.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            NebulaColors.accentPurple,
                            NebulaColors.accentCyan,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Nebula',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Secure Lead Intelligence Engine',
                        style: TextStyle(
                          fontSize: 13,
                          color: NebulaColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 36),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline_rounded),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 28),
                      _isLoading
                          ? const SizedBox(
                              height: 48,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: NebulaColors.accentPurple,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      NebulaColors.accentPurple,
                                      NebulaColors.accentBlue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: NebulaColors.accentPurple
                                          .withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _isLogin ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? 'Create an account'
                              : 'Already have an account? Sign in',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(
                          color: NebulaColors.borderSubtle.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          context.go('/dashboard');
                        },
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text(
                          'Continue as Guest · Demo Mode',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
