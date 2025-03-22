import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import '../../../common/widgets/toast.dart';
import '../../authentication/cubit/login/login_cubit.dart';
import '../../authentication/cubit/login/login_state.dart';
import '../../../common/widgets/page_wrapper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      canPop: false,
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final User? user = state.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? const Icon(Icons.business, size: 30)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.companyName ?? 'Company Name',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.packageType ?? 'Basic Package',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            // Contact Info
                            InfoRow(
                              icon: Icons.person,
                              label: 'Full Name',
                              value: user.fullName ?? 'Not set',
                            ),
                            const SizedBox(height: 12),
                            InfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: user.username,
                            ),
                            const SizedBox(height: 12),
                            InfoRow(
                              icon: Icons.phone,
                              label: 'Phone',
                              value: user.phone ?? 'Not set',
                            ),
                            const SizedBox(height: 12),
                            InfoRow(
                              icon: Icons.flag,
                              label: 'Nationality',
                              value: user.nationality ?? 'Not set',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        ActionCard(
                          icon: Icons.edit,
                          title: 'Edit Profile',
                          onTap: () {
                            // TODO: Navigate to edit profile
                          },
                        ),
                        ActionCard(
                          icon: Icons.assessment,
                          title: 'Reports',
                          onTap: () {
                            // TODO: Navigate to reports
                          },
                        ),
                        ActionCard(
                          icon: Icons.settings,
                          title: 'Settings',
                          onTap: () {
                            // TODO: Navigate to settings
                          },
                        ),
                        ActionCard(
                          icon: Icons.help,
                          title: 'Help',
                          onTap: () {
                            // TODO: Navigate to help
                          },
                        ),
                      ],
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

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 