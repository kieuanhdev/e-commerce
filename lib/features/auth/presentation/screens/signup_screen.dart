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
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  bool isNameValid = true;
  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool isConfirmPasswordValid = true;
  bool isPhoneValid = true;
  bool isPasswordObscured = true;
  bool isConfirmObscured = true;
  bool hasInteractedWithConfirm = false;

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
                      "Đăng ký",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  AuthTextField(
                    label: 'Họ và tên',
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
                      // Do not validate confirm here; only validate when user edits confirm field
                    }),
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    label: 'Nhập lại mật khẩu',
                    controller: confirmPasswordController,
                    obscureText: isConfirmObscured,
                    isValid: isConfirmPasswordValid,
                    showValidationIcon: false,
                    errorText: hasInteractedWithConfirm && !isConfirmPasswordValid ? 'Mật khẩu không khớp' : null,
                    suffixIcon: IconButton(
                      icon: Icon(isConfirmObscured ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => isConfirmObscured = !isConfirmObscured),
                    ),
                    onChanged: (v) => setState(() {
                      hasInteractedWithConfirm = true;
                      isConfirmPasswordValid = v == passwordController.text && isPasswordValid;
                    }),
                  ),
                  const SizedBox(height: 16),

                  AuthTextField(
                    label: 'Số điện thoại (Tùy chọn)',
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
                      label: const Text("Đăng nhập"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AuthButton(
                        text: state is AuthLoading ? "Đang đăng ký..." : "Đăng ký",
                        onPressed: state is AuthLoading ? null : _handleSignUp,
                      );
                    },
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

  void _handleSignUp() {
    // Validate form
    if (!isNameValid || !isEmailValid || !isPasswordValid || !isConfirmPasswordValid || !isPhoneValid) {
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

    if (confirmPasswordController.text != passwordController.text) {
      setState(() {
        isConfirmPasswordValid = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu không khớp'),
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
