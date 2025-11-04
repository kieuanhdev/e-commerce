import 'package:e_commerce/features/auth/presentation/widgets/auth_button.dart';
import 'package:e_commerce/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:e_commerce/features/auth/presentation/widgets/social_button_row.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Tiêu đề
                  const Center(
                    child: Text(
                      "Đăng nhập",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Animation
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Lottie.asset(
                        'animations/Digital Designer.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  AuthTextField(
                    label: 'Email',
                    controller: emailController,
                    isValid: isEmailValid,
                    onChanged: (v) =>
                        setState(() => isEmailValid = v.contains('@')),
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    label: 'Mật khẩu',
                    controller: passwordController,
                    obscureText: isPasswordObscured,
                    isValid: isPasswordValid,
                    showValidationIcon: false,
                    errorText: isPasswordValid ? null : 'Mật khẩu phải có ít nhất 6 ký tự',
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
                      label: const Text("Quên mật khẩu?"),
                    ),
                  ),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AuthButton(
                        text: state is AuthLoading ? "Đang đăng nhập..." : "ĐĂNG NHẬP",
                        onPressed: state is AuthLoading ? null : _handleLogin,
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? "),
                      GestureDetector(
                        onTap: () {
                          context.push('/register'); // điều hướng sang trang Sign Up
                        },
                        child: const Text(
                          "Đăng ký",
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
                  const SizedBox(height: 20),
                ],
              ),
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
          content: Text('Vui lòng điền đầy đủ và đúng các trường bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
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
