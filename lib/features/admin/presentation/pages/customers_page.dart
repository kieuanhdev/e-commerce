import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/admin/presentation/bloc/customers_bloc.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AdminCustomersPage extends StatelessWidget {
  const AdminCustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CustomersBloc>()..add(const LoadUsers()),
      child: const _CustomersPageContent(),
    );
  }
}

class _CustomersPageContent extends StatelessWidget {
  const _CustomersPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Khách hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddUserDialog(context),
            tooltip: 'Thêm người dùng mới',
          ),
        ],
      ),
      body: BlocConsumer<CustomersBloc, CustomersState>(
        listener: (context, state) {
          if (state is CustomersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomersInitial || state is CustomersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomersError && state is! CustomersLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CustomersBloc>().add(const LoadUsers());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is CustomersLoaded) {
            if (state.users.isEmpty) {
              return const Center(
                child: Text('Chưa có người dùng nào'),
              );
            }

            return Column(
              children: [
                // Stats bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(
                        label: 'Tổng số',
                        value: state.users.length.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      _StatCard(
                        label: 'Hoạt động',
                        value: state.users
                            .where((u) => !u.isDisabled)
                            .length
                            .toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      _StatCard(
                        label: 'Đã khóa',
                        value: state.users
                            .where((u) => u.isDisabled)
                            .length
                            .toString(),
                        icon: Icons.lock,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                // Users list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return _UserCard(user: user);
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRole = 'customer';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thêm người dùng mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu *',
                  border: OutlineInputBorder(),
                  helperText: 'Tối thiểu 6 ký tự',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Khách hàng')),
                  DropdownMenuItem(value: 'admin', child: Text('Quản trị viên')),
                ],
                onChanged: (value) {
                  if (value != null) selectedRole = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty ||
                  passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng điền đầy đủ thông tin'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              context.read<CustomersBloc>().add(
                    CreateUser(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                      displayName: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                      role: selectedRole,
                    ),
                  );

              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang tạo người dùng...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(
                  user.displayName?.isNotEmpty == true
                      ? user.displayName![0].toUpperCase()
                      : user.email[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )
              : null,
          backgroundColor: user.isDisabled ? Colors.grey : Colors.blue,
        ),
        title: Text(
          user.displayName ?? user.email,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: user.isDisabled
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (user.phoneNumber != null) Text(user.phoneNumber!),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.role == 'admin' ? Colors.purple[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role == 'admin' ? 'Admin' : 'Khách hàng',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.role == 'admin' ? Colors.purple[900] : Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (user.isDisabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Đã khóa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              'Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            user.isDisabled ? Icons.lock_open : Icons.lock,
            color: user.isDisabled ? Colors.green : Colors.red,
          ),
          onPressed: () {
            _showToggleStatusDialog(context, user);
          },
          tooltip: user.isDisabled ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
        ),
      ),
    );
  }

  void _showToggleStatusDialog(BuildContext context, AppUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(user.isDisabled ? 'Mở khóa tài khoản?' : 'Khóa tài khoản?'),
        content: Text(
          user.isDisabled
              ? 'Bạn có chắc chắn muốn mở khóa tài khoản của ${user.displayName ?? user.email}?'
              : 'Bạn có chắc chắn muốn khóa tài khoản của ${user.displayName ?? user.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CustomersBloc>().add(ToggleUserStatus(user.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    user.isDisabled
                        ? 'Đang mở khóa tài khoản...'
                        : 'Đang khóa tài khoản...',
                  ),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isDisabled ? Colors.green : Colors.red,
            ),
            child: Text(user.isDisabled ? 'Mở khóa' : 'Khóa'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
