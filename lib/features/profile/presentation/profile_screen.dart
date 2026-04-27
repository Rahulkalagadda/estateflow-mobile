import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAT20alIQCrQTbC0mHFTAQmEhOWBXinHtsHo1eC76ljJd51Dmjp0cXI5PD4vVqKjbHJHaQAOmHmIiuYYqh1_mgIHMx719NWeyFbEzJKwY6yQ9iYd6NDLv9ynICvxpM2BKmI6DRn5WS3DDmQhSRVSfBjIajpXb3yjGaWGaRKH_In4ixjZzQzwhKijl65UkOuoxq56gM2dR9h9Dzbz4S0pGElZLsl8zZUEef9hdWribYzNof1K4DEZ3OoOUSXVsEEpMTfXwncaw0f_htV',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Alex Reed', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                const Text('Senior Real Estate Consultant', style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildBadge('Top Producer', AppColors.secondaryContainer.withValues(alpha: 0.3), AppColors.onSecondaryFixedVariant),
                    const SizedBox(width: 8),
                    _buildBadge('Platinum Tier', AppColors.primaryFixed, AppColors.onPrimaryFixed),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(context, 'Portfolio', '\$42.8M'),
                _buildStatCard(context, 'Active Leads', '124'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RESPONSE TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('1.2h', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const Icon(Icons.bolt, size: 32, color: AppColors.secondaryContainer),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings Sections
            _buildSettingsSection(
              context,
              title: 'Account Settings',
              items: [
                _buildSettingsItem(icon: Icons.person, iconBg: AppColors.primaryFixed, iconColor: AppColors.primary, title: 'Personal Information', subtitle: 'Update your details and contact info'),
                _buildSettingsItem(icon: Icons.lock, iconBg: AppColors.primaryFixed, iconColor: AppColors.primary, title: 'Password & Security', subtitle: 'Manage your credentials and 2FA'),
                if (ref.watch(authProvider).user?.role != 'EMPLOYEE')
                  _buildSettingsItem(
                    icon: Icons.diversity_3, 
                    iconBg: AppColors.secondaryContainer.withValues(alpha: 0.2), 
                    iconColor: AppColors.primary, 
                    title: 'Team Management', 
                    subtitle: 'Manage members and performance',
                    onTap: () => context.push('/profile/team'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSettingsSection(
              context,
              title: 'Preferences',
              items: [
                _buildSettingsItem(icon: Icons.dark_mode, iconBg: AppColors.tertiaryFixed, iconColor: AppColors.onTertiaryFixedVariant, title: 'Dark Mode', subtitle: 'Switch to high-contrast night view', isToggle: true),
                _buildSettingsItem(icon: Icons.notifications, iconBg: AppColors.tertiaryFixed, iconColor: AppColors.onTertiaryFixedVariant, title: 'Notifications', subtitle: 'Email, Push and SMS alerts'),
              ],
            ),
            const SizedBox(height: 24),

            _buildSettingsSection(
              context,
              title: 'Support & About',
              items: [
                _buildSettingsItem(icon: Icons.help, iconBg: AppColors.surfaceContainerHigh, iconColor: AppColors.onSurfaceVariant, title: 'Help Center', subtitle: 'Documentation and support tickets'),
                _buildSettingsItem(icon: Icons.description, iconBg: AppColors.surfaceContainerHigh, iconColor: AppColors.onSurfaceVariant, title: 'Terms of Service', subtitle: 'Legal information and privacy policy'),
              ],
            ),
            const SizedBox(height: 32),

            // Logout
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorContainer,
                foregroundColor: AppColors.onErrorContainer,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ESTATE LOGIC V2.4.0 • ENTERPRISE EDITION',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: textColor)),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isToggle = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            if (isToggle)
              Switch(value: false, onChanged: (v) {}, activeThumbColor: AppColors.primary)
            else
              const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}
