import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';
import 'package:e_commerce/core/theme/app_sizes.dart';
import 'package:e_commerce/features/admin/presentation/bloc/customers_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  
  String _selectedRole = 'customer';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.placeholder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.placeholder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.spacingMD,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    if (!mounted) return;

    context.read<CustomersBloc>().add(
      CreateUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        role: _selectedRole,
      ),
    );

    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomersBloc, CustomersState>(
      listener: (context, state) {
        if (state is CustomersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is CustomersLoading) {
          // Handle loading state if needed
        } else if (state is CustomersLoaded) {
          // Success - close the page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã thêm người dùng thành công 🎉'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thêm Người dùng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Tên hiển thị', icon: Icons.person),
                  validator: (v) => v!.isEmpty ? 'Nhập tên hiển thị' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email', icon: Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Nhập email';
                    if (!v.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                TextFormField(
                  controller: _passwordController,
                  decoration: _inputDecoration(
                    'Mật khẩu',
                    icon: Icons.lock,
                  ).copyWith(
                    helperText: 'Tối thiểu 6 ký tự',
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (v!.isEmpty) return 'Nhập mật khẩu';
                    if (v.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('Số điện thoại', icon: Icons.phone),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingMD),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: _inputDecoration('Vai trò', icon: Icons.person_outline),
                  items: const [
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text('Khách hàng'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Quản trị viên'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSizes.spacingXL),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _save,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.person_add),
                  label: Text(
                    _isSubmitting ? 'Đang tạo...' : 'Thêm Người dùng',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingMD),
                    textStyle: AppTextStyles.text16.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

