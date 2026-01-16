import 'package:flutter/material.dart';
import 'package:team_management_app_dev/data/services/auth_service.dart';
import '../main.dart';
import '../utils/constants.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> onLoginPressed() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Login stores token and userId in AuthService singleton
      await authService.login(
        nameController.text,
        passwordController.text,
      );

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.large,
                    ),
                    child: Icon(
                      Icons.groups,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Title
                  Text(
                    'Welcome Back!',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Login to manage your teams',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  
                  // Login Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      boxShadow: AppShadows.large,
                    ),
                    child: Column(
                      children: [
                        // Username field
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: AppColors.primary),
                            prefixIcon: Icon(Icons.person, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: BorderSide(color: AppColors.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // Password field
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: AppColors.primary),
                            prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: BorderSide(color: AppColors.divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              borderSide: BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              elevation: AppSpacing.elevationSm,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: AppTextStyles.button,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Register()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Register',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


