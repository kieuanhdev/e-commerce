import 'package:e_commerce/features/auth/presentation/widgets/auth_button.dart';
import 'package:e_commerce/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

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

    // TODO: gọi API gửi link reset password
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Password reset link sent!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              AuthButton(text: "Send", onPressed: _sendResetEmail),
            ],
          ),
        ),
      ),
    );
  }
}
