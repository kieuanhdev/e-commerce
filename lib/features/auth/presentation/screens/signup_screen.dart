import 'package:e_commerce/features/auth/presentation/widgets/auth_button.dart';
import 'package:e_commerce/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:e_commerce/features/auth/presentation/widgets/social_button_row.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController(text: 'kieuanh');
  final emailController = TextEditingController(text: 'kieuanh.dev@gmail.com');
  final passwordController = TextEditingController();

  bool isNameValid = true;
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
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text("Login"),
                ),
              ),
              const SizedBox(height: 16),

              AuthButton(
                text: "Sign up",
                onPressed: () {
                  // Xử lý sign up
                },
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
