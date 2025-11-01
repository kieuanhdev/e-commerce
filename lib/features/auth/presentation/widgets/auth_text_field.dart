import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool isValid;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final Widget? suffixIcon;
  final bool showValidationIcon;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.isValid = true,
    this.onChanged,
    this.errorText,
    this.suffixIcon,
    this.showValidationIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: suffixIcon ?? (showValidationIcon && isValid
            ? const Icon(Icons.check, color: Colors.green)
            : null),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
