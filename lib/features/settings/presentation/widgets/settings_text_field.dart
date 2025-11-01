import 'package:flutter/material.dart';

class SettingsTextField extends StatelessWidget {
  const SettingsTextField(
    this.label,
    this.controller, {
    super.key,
    this.obscureText = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}


