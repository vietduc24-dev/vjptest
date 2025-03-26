import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import '../../../common/widgets/toast.dart';
import '../../authentication/cubit/login/login_cubit.dart';
import '../../authentication/cubit/login/login_state.dart';
import '../../../common/widgets/page_wrapper.dart';
import '../../../routes/app_router.dart';
import '../../../common/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      canPop: false,
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.user == null) {
            AppRouter.goToLogin(context);
          }
        },
        builder: (context, state) {
          final User? user = state.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Hồ sơ của bạn'),
              centerTitle: true,
              backgroundColor: Colors.blue[700],
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    context.read<LoginCubit>().logout();
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                // TODO: Implement refresh
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.blue[700]!, Colors.blue[600]!],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? Icon(Icons.person,
                                          size: 40, color: Colors.blue[700])
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.fullName ?? 'Chưa cập nhật tên',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.packageType ?? 'Tài khoản cơ bản',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Thông tin liên hệ
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thông tin cá nhân
                          const Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 8),
                            child: Text(
                              'Thông tin cá nhân',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                InfoTile(
                                  icon: Icons.person,
                                  label: 'Họ tên',
                                  value: user.fullName ?? 'Chưa cập nhật',
                                ),
                                const Divider(height: 1),
                                InfoTile(
                                  icon: Icons.email,
                                  label: 'Email',
                                  value: user.username,
                                ),
                                const Divider(height: 1),
                                InfoTile(
                                  icon: Icons.phone,
                                  label: 'Số điện thoại',
                                  value: user.phone ?? 'Chưa cập nhật',
                                ),
                                const Divider(height: 1),
                                InfoTile(
                                  icon: Icons.flag,
                                  label: 'Quốc tịch',
                                  value: user.nationality ?? 'Chưa cập nhật',
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Hành động nhanh
                          const Padding(
                            padding: EdgeInsets.only(left: 8, bottom: 8),
                            child: Text(
                              'Tính năng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              ActionCard(
                                icon: Icons.edit,
                                title: 'Chỉnh sửa',
                                description: 'Cập nhật thông tin cá nhân',
                                onTap: () {
                                  // TODO: Navigate to edit profile
                                },
                                color: Colors.blue[600]!,
                              ),
                              ActionCard(
                                icon: Icons.security,
                                title: 'Bảo mật',
                                description: 'Đổi mật khẩu và bảo mật',
                                onTap: () {
                                  // TODO: Navigate to security settings
                                },
                                color: Colors.indigo[400]!,
                              ),
                              ActionCard(
                                icon: Icons.settings,
                                title: 'Cài đặt',
                                description: 'Tùy chỉnh ứng dụng',
                                onTap: () {
                                  // TODO: Navigate to settings
                                },
                                color: Colors.green[600]!,
                              ),
                              ActionCard(
                                icon: Icons.help_outline,
                                title: 'Trợ giúp',
                                description: 'Hỗ trợ và hướng dẫn',
                                onTap: () {
                                  // TODO: Navigate to help
                                },
                                color: Colors.amber[700]!,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color color;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 