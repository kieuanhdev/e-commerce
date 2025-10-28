import 'package:e_commerce/features/auth/presentation/widgets/auth_button.dart';
import 'package:e_commerce/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:e_commerce/features/auth/presentation/widgets/social_button_row.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'kieuanh.dev@gmail.com');
  final passwordController = TextEditingController();

  bool isEmailValid = true;

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
                obscureText: true,
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    context.push(
                      '/forgot',
                    ); // điều hướng sang trang Forgot Password
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text("Forgot your password?"),
                ),
              ),

              AuthButton(
                text: "LOGIN",
                onPressed: () {
                  // Xử lý login
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      context.push('/signup'); // điều hướng sang trang Sign Up
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
    );
  }
}
