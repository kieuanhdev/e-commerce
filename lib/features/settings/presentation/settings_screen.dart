import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:e_commerce/features/settings/presentation/bloc/settings_event.dart';
import 'package:e_commerce/features/settings/presentation/bloc/settings_state.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/settings/presentation/widgets/settings_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _avatarUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => sl<SettingsBloc>()..add(LoadSettings()),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SettingsLoaded) {
            final user = state.user;
            if (!_initialized) {
              _displayNameController.text = user.displayName ?? '';
              _avatarUrlController.text = user.avatarUrl ?? '';
              _initialized = true;
            }
            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                backgroundColor: Colors.grey[50],
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
                centerTitle: false,
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      "PROFILE",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage:
                            (user.avatarUrl != null &&
                                user.avatarUrl!.isNotEmpty)
                            ? NetworkImage(user.avatarUrl!)
                            : const AssetImage('images/avatar.png')
                                  as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SettingsTextField("Display Name", _displayNameController),
                    const SizedBox(height: 12),
                    SettingsTextField("Avatar URL", _avatarUrlController),
                    const SizedBox(height: 24),
                    const Text(
                      "SECURITY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SettingsTextField("Mật khẩu hiện tại", _currentPasswordController, obscureText: true),
                    const SizedBox(height: 12),
                    SettingsTextField("Mật khẩu mới", _newPasswordController, obscureText: true),
                    const SizedBox(height: 12),
                    SettingsTextField("Xác nhận mật khẩu mới", _confirmPasswordController, obscureText: true),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final current = _currentPasswordController.text.trim();
                          final next = _newPasswordController.text.trim();
                          final confirm = _confirmPasswordController.text.trim();
                          if (next.isEmpty || current.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đủ mật khẩu')),);
                            return;
                          }
                          if (next != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),);
                            return;
                          }
                          context.read<SettingsBloc>().add(
                                ChangePasswordRequested(
                                  currentPassword: current,
                                  newPassword: next,
                                ),
                              );
                        },
                        child: const Text(
                          "Đổi mật khẩu",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<SettingsBloc>().add(
                            UpdateUserSettings(
                              displayName: _displayNameController.text.trim(),
                              avatarUrl: _avatarUrlController.text.trim(),
                            ),
                          );
                        },
                        child: const Text(
                          "Lưu thay đổi",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is SettingsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

}
