import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:e_commerce/features/settings/presentation/bloc/settings_event.dart';
import 'package:e_commerce/features/settings/presentation/bloc/settings_state.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/settings/presentation/widgets/settings_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext blocContext) async {
    try {
      // Hiển thị dialog để chọn nguồn ảnh
      final ImageSource? source = await showDialog<ImageSource>(
        context: blocContext,
        builder: (context) => AlertDialog(
          title: const Text('Chọn ảnh từ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Chọn ảnh
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // Gửi event upload avatar
        blocContext.read<SettingsBloc>().add(UploadAvatarImage(imageFile: image));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(blocContext).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => sl<SettingsBloc>(), // Settings đã tự load trong constructor
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
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          
          // Xử lý UploadingAvatar state - hiển thị overlay loading
          AppUser? currentUser;
          bool isUploading = false;
          if (state is UploadingAvatar) {
            currentUser = state.user;
            isUploading = true;
          } else if (state is SettingsLoaded) {
            currentUser = state.user;
          }
          
          if (currentUser != null) {
            final user = currentUser;
            if (!_initialized) {
              _displayNameController.text = user.displayName ?? '';
              _initialized = true;
            }
            return Stack(
              children: [
                Scaffold(
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
                      child: GestureDetector(
                        onTap: () => _pickImage(context),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundImage:
                                  (user.avatarUrl != null &&
                                      user.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(user.avatarUrl!)
                                  : const AssetImage('images/avatar.png')
                                        as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => _pickImage(context),
                        child: const Text(
                          'Thay đổi avatar',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SettingsTextField("Display Name", _displayNameController),
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
                ),
                // Loading overlay khi đang upload
                if (isUploading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Đang upload avatar...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
