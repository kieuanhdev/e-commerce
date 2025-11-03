import 'package:e_commerce/core/theme/app_colors.dart';
import 'package:e_commerce/core/theme/app_text_styles.dart';
import 'package:e_commerce/core/theme/app_sizes.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/admin/presentation/bloc/customers_bloc.dart';
import 'package:e_commerce/features/admin/presentation/pages/user_form_page.dart';
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

class _CustomersPageContent extends StatefulWidget {
  const _CustomersPageContent();

  @override
  State<_CustomersPageContent> createState() => _CustomersPageContentState();
}

class _CustomersPageContentState extends State<_CustomersPageContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppUser> _filterUsers(List<AppUser> users, String query) {
    if (query.isEmpty) {
      return users;
    }
    final lowerQuery = query.toLowerCase();
    return users.where((user) {
      final displayName = (user.displayName ?? '').toLowerCase();
      final email = user.email.toLowerCase();
      return displayName.contains(lowerQuery) || email.contains(lowerQuery);
    }).toList();
  }

  Future<void> _openUserForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider<CustomersBloc>.value(
          value: context.read<CustomersBloc>(),
          child: const UserFormPage(),
        ),
      ),
    );
    if (result == true) {
      context.read<CustomersBloc>().add(const LoadUsers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Khách hàng'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUserForm,
        label: const Text('Thêm người dùng'),
        icon: const Icon(Icons.add_rounded),
      ),
      body: BlocConsumer<CustomersBloc, CustomersState>(
        listener: (context, state) {
          if (state is CustomersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
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
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: AppSizes.spacingMD),
                  Text(
                    state.message,
                    style: AppTextStyles.text14.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingMD),
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
              return Column(
                children: [
                  // Search bar
                  _buildSearchBar(),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Chưa có người dùng nào',
                        style: AppTextStyles.text16.copyWith(color: AppColors.placeholder),
                      ),
                    ),
                  ),
                ],
              );
            }

            final filteredUsers = _filterUsers(state.users, _searchQuery);

            return Column(
              children: [
                // Search bar
                _buildSearchBar(),
                // Stats bar
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  color: AppColors.background,
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
                        color: AppColors.success,
                      ),
                      _StatCard(
                        label: 'Đã khóa',
                        value: state.users
                            .where((u) => u.isDisabled)
                            .length
                            .toString(),
                        icon: Icons.lock,
                        color: AppColors.error,
                      ),
                    ],
                  ),
                ),
                // Search results info
                if (_searchQuery.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMD, vertical: AppSizes.spacingSM),
                    color: AppColors.background,
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 16, color: AppColors.primary),
                        const SizedBox(width: AppSizes.spacingSM),
                        Text(
                          'Tìm thấy ${filteredUsers.length} kết quả cho "$_searchQuery"',
                          style: AppTextStyles.text11.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Users list
                Expanded(
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: AppColors.placeholder),
                              const SizedBox(height: AppSizes.spacingMD),
                              Text(
                                'Không tìm thấy người dùng nào',
                                style: AppTextStyles.text16.copyWith(
                                  color: AppColors.placeholder,
                                ),
                              ),
                              const SizedBox(height: AppSizes.spacingSM),
                              Text(
                                'Thử tìm kiếm với từ khóa khác',
                                style: AppTextStyles.text11.copyWith(
                                  color: AppColors.placeholder,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.spacingSM),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên hoặc email...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
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
          filled: true,
          fillColor: AppColors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
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
      elevation: AppSizes.cardElevation,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSM, vertical: AppSizes.spacingXS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          backgroundColor: user.isDisabled ? AppColors.placeholder : AppColors.primary,
          child: user.avatarUrl == null
              ? Text(
                  user.displayName?.isNotEmpty == true
                      ? user.displayName![0].toUpperCase()
                      : user.email[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.white),
                )
              : null,
        ),
        title: Text(
          user.displayName ?? user.email,
          style: AppTextStyles.text16.copyWith(
            fontWeight: FontWeight.bold,
            decoration: user.isDisabled
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: AppTextStyles.text14),
            if (user.phoneNumber != null) Text(user.phoneNumber!, style: AppTextStyles.text14),
            const SizedBox(height: AppSizes.spacingXS),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSM, vertical: 2),
                  decoration: BoxDecoration(
                    color: user.role == 'admin' ? Colors.purple[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Text(
                    user.role == 'admin' ? 'Admin' : 'Khách hàng',
                    style: AppTextStyles.text11.copyWith(
                      color: user.role == 'admin' ? Colors.purple[900] : Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.spacingSM),
                if (user.isDisabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingSM, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Text(
                      'Đã khóa',
                      style: AppTextStyles.text11.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              'Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt)}',
              style: AppTextStyles.text11.copyWith(color: AppColors.placeholder),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            user.isDisabled ? Icons.lock_open : Icons.lock,
            color: user.isDisabled ? AppColors.success : AppColors.error,
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
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isDisabled ? AppColors.success : AppColors.error,
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
        Icon(icon, color: color, size: AppSizes.iconLG),
        const SizedBox(height: AppSizes.spacingXS),
        Text(
          value,
          style: AppTextStyles.headline3.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.text11.copyWith(color: AppColors.placeholder),
        ),
      ],
    );
  }
}
