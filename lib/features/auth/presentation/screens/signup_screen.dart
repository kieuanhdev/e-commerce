import 'package:e_commerce/features/auth/presentation/widgets/auth_button.dart';
import 'package:e_commerce/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:e_commerce/features/auth/presentation/widgets/social_button_row.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController(text: 'kieuanh');
  final emailController = TextEditingController(text: 'kieuanh.dev@gmail.com');
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool isNameValid = true;
  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool isPhoneValid = true;

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
                    "Sign Up",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              AuthTextField(
                label: 'Name',
                controller: nameController,
                isValid: isNameValid,
                onChanged: (v) =>
                    setState(() => isNameValid = v.trim().isNotEmpty),
              ),
              const SizedBox(height: 16),

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
                obscureText: true,
                isValid: isPasswordValid,
                onChanged: (v) =>
                    setState(() => isPasswordValid = v.length >= 6),
              ),
              const SizedBox(height: 16),

              AuthTextField(
                label: 'Phone Number (Optional)',
                controller: phoneController,
                isValid: isPhoneValid,
                onChanged: (v) =>
                    setState(() => isPhoneValid = v.isEmpty || v.length >= 10),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    context.push('/login');
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text("Login"),
                ),
              ),
              const SizedBox(height: 16),

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return AuthButton(
                    text: state is AuthLoading ? "Signing up..." : "Sign up",
                    onPressed: state is AuthLoading ? null : _handleSignUp,
                  );
                },
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

  void _handleSignUp() {
    // Validate form
    if (!isNameValid || !isEmailValid || !isPasswordValid || !isPhoneValid) {
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

    // Trigger register event
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: nameController.text.trim(),
        phoneNumber: phoneController.text.trim().isEmpty 
            ? null 
            : phoneController.text.trim(),
      ),
    );
  }
}
