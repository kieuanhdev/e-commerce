import 'package:e_commerce/features/auth/presentation/widgets/auth_button.dart';
import 'package:e_commerce/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isEmailValid = true;

  String? get _emailErrorText {
    if (isEmailValid) return null;
    return "Not a valid email address. Should be your@email.com";
  }

  void _validateEmail(String value) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() => isEmailValid = regex.hasMatch(value));
  }

  void _sendResetEmail() {
    _validateEmail(emailController.text);
    if (!isEmailValid) return;
    context
        .read<AuthBloc>()
        .add(AuthForgotPasswordRequested(emailController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthForgotPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset link sent!')),
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
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Text(
                    "Forgot password",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hướng dẫn
              const Text(
                "Please, enter your email address.\nYou will receive a link to create a new password via email.",
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // Ô nhập email
              AuthTextField(
                label: 'Email',
                controller: emailController,
                isValid: isEmailValid,
                onChanged: _validateEmail,
              ),

              if (!isEmailValid)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 8),
                  child: Text(
                    _emailErrorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 30),

              // Nút gửi
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthForgotPasswordLoading;
                  return AuthButton(
                    text: isLoading ? "Sending..." : "Send",
                    onPressed: isLoading ? null : _sendResetEmail,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
