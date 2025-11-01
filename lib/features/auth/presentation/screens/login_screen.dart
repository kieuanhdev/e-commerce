import 'package:e_commerce/features/auth/presentation/widgets/auth_button.dart';
import 'package:e_commerce/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:e_commerce/features/auth/presentation/widgets/social_button_row.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: '123@gmail.com');
  final passwordController = TextEditingController();

  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool isPasswordObscured = true;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // Show loading indicator
        } else if (state is AuthAuthenticated) {
          // Navigate by role
          final isAdmin = state.user.role == 'admin';
          context.go(isAdmin ? '/admin/overview' : '/home');
        } else if (state is AuthFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              AuthTextField(
                label: 'Email',
                controller: emailController,
                isValid: isEmailValid,
                onChanged: (v) =>
                    setState(() => isEmailValid = v.contains('@')),
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Password',
                controller: passwordController,
                obscureText: isPasswordObscured,
                isValid: isPasswordValid,
                showValidationIcon: false,
                errorText: isPasswordValid ? null : 'Password must be at least 6 characters',
                suffixIcon: IconButton(
                  icon: Icon(isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => isPasswordObscured = !isPasswordObscured),
                ),
                onChanged: (v) => setState(() {
                  isPasswordValid = v.length >= 6;
                  passwordError = isPasswordValid ? null : 'Password must be at least 6 characters';
                }),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    context.push(
                      '/forgot-password',
                    ); // điều hướng sang trang Forgot Password
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text("Forgot your password?"),
                ),
              ),

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AuthButton(
                    text: state is AuthLoading ? "Logging in..." : "LOGIN",
                    onPressed: state is AuthLoading ? null : _handleLogin,
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      context.push('/register'); // điều hướng sang trang Sign Up
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const SocialButtonRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    // Validate form
    if (!isEmailValid || !isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Trigger login event
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        emailController.text.trim(),
        passwordController.text,
      ),
    );
  }
}
