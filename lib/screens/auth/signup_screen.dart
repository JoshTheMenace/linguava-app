import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      try {
        final response = await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );
        
        if (mounted) {
          // Check the actual Supabase response to determine flow
          if (response != null) {
            if (kDebugMode) {
              print('=== SIGNUP RESPONSE DEBUG ===');
              print('User ID: ${response.user?.id}');
              print('User email: ${response.user?.email}');
              print('User confirmed at: ${response.user?.emailConfirmedAt}');
              print('Session exists: ${response.session != null}');
              print('Session access token: ${response.session?.accessToken != null}');
              print('Response full: $response');
            }
            
            if (response.session != null && response.user != null) {
              // User is immediately authenticated (email confirmation disabled)
              if (kDebugMode) {
                print('FLOW: User authenticated immediately, going to home');
              }
              context.go(AppRoutes.home);
            } else if (response.user != null && response.session == null) {
              // Email confirmation required - user created but no session
              if (kDebugMode) {
                print('FLOW: Email confirmation required, showing message');
              }
              
              // Show immediate feedback with longer duration
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✅ Account created successfully!'),
                      Text('📧 Check ${_emailController.text.trim()} for confirmation link'),
                      Text('⚠️ Click the link in your email to activate your account'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 8),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Go to Login',
                    textColor: Colors.white,
                    onPressed: () {
                      context.go(AppRoutes.login);
                    },
                  ),
                ),
              );
            } else {
              // Unexpected state
              if (kDebugMode) {
                print('FLOW: Unexpected state, showing fallback message');
                print('User is null: ${response.user == null}');
                print('Session is null: ${response.session == null}');
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signup completed, please check your email'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          } else {
            // Supabase not configured - demo mode
            if (kDebugMode) {
              print('FLOW: Demo mode - no response from Supabase');
            }
            final authState = ref.read(authProvider);
            if (kDebugMode) {
              print('Auth state authenticated: ${authState.isAuthenticated}');
            }
            if (authState.isAuthenticated) {
              if (kDebugMode) {
                print('FLOW: Demo mode going to home');
              }
              context.go(AppRoutes.home);
            } else {
              if (kDebugMode) {
                print('FLOW: Demo mode showing completion message');
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demo signup completed'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign up failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
        ),
      );
    }
  }

  void _handleSkip() {
    context.go(AppRoutes.home);
  }

  void _handleGoogleSignUp() async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign up failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAppleSignUp() async {
    try {
      await ref.read(authProvider.notifier).signInWithApple();
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple sign up failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF121212),
              Color(0xFF1a1a1a),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap(20),
                  
                  _buildHeader(),
                  
                  const Gap(40),
                  
                  _buildSignupForm(),
                  
                  const Gap(24),
                  
                  _buildTermsCheckbox(),
                  
                  const Gap(32),
                  
                  _buildSignupButton(),
                  
                  const Gap(24),
                  
                  _buildDivider(),
                  
                  const Gap(24),
                  
                  _buildSocialButtons(),
                  
                  const Gap(32),
                  
                  _buildLoginPrompt(),
                  
                  const Gap(16),
                  
                  _buildSkipButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 48,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .fadeIn(duration: 600.ms),
        
        const Gap(24),
        
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        
        const Gap(8),
        
        Text(
          'Join thousands of learners worldwide',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your name';
            }
            if (value!.length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),
        
        const Gap(20),
        
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 1000.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),
        
        const Gap(20),
        
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a strong password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a password';
            }
            if (value!.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, and numbers';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 1200.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),
        
        const Gap(20),
        
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 1400.ms, duration: 600.ms)
            .slideX(begin: -0.3, end: 0),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1600.ms, duration: 600.ms);
  }

  Widget _buildSignupButton() {
    final authState = ref.watch(authProvider);
    
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : _handleSignup,
        child: authState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Create Account'),
      ),
    )
        .animate()
        .fadeIn(delay: 1800.ms, duration: 600.ms)
        .scale(delay: 1800.ms, duration: 400.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hint,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    )
        .animate()
        .fadeIn(delay: 2000.ms, duration: 600.ms);
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          label: 'Sign up with Google',
          onPressed: _handleGoogleSignUp,
        ),
        const Gap(12),
        _buildSocialButton(
          icon: Icons.apple,
          label: 'Sign up with Apple',
          onPressed: _handleAppleSignUp,
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 2200.ms, duration: 600.ms);
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final authState = ref.watch(authProvider);
    
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: authState.isLoading ? null : onPressed,
        icon: authState.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, size: 24),
        label: Text(label),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            context.go(AppRoutes.login);
          },
          child: const Text('Sign In'),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 2400.ms, duration: 600.ms);
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _handleSkip,
      child: Text(
        'Skip for now',
        style: TextStyle(
          color: AppColors.hint,
          decoration: TextDecoration.underline,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 2600.ms, duration: 600.ms);
  }
}